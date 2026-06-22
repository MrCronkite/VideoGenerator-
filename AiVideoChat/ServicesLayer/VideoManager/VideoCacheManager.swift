//
//  VideoCacheManager.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import Foundation
import AVFoundation


final class VideoCacheManager {

    static let shared = VideoCacheManager()
    private init() {
        try? FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
    }

    // MARK: Storage

    private let cacheDirectory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("VideoCache", isDirectory: true)
    }()

    /// Активные loader-ы по ключу URL — гарантирует что на один и тот же
    /// видео-URL не уйдёт два параллельных сетевых запроса одновременно
    private var activeLoaders: [String: VideoAssetLoader] = [:]
    private let lock = NSLock()

    // MARK: Public

    /// Возвращает готовый AVPlayerItem с подключённым кэширующим resource loader.
    /// Если файл уже полностью на диске — отдаёт его напрямую, без resource loader вообще.
    func playerItem(for url: URL) -> AVPlayerItem {
        let localFileURL = cacheFileURL(for: url)

        if FileManager.default.fileExists(atPath: localFileURL.path) {
            // Файл уже целиком на диске — играем напрямую, максимально быстро
            return AVPlayerItem(url: localFileURL)
        }

        let key = url.absoluteString

        lock.lock()
        let loader: VideoAssetLoader
        if let existing = activeLoaders[key] {
            loader = existing
        } else {
            loader = VideoAssetLoader(originalURL: url, localFileURL: localFileURL) { [weak self] in
                self?.lock.lock()
                self?.activeLoaders.removeValue(forKey: key)
                self?.lock.unlock()
            }
            activeLoaders[key] = loader
        }
        lock.unlock()

        let asset = loader.makeAsset()
        return AVPlayerItem(asset: asset)
    }

    func clearCache(for url: URL) {
        try? FileManager.default.removeItem(at: cacheFileURL(for: url))
    }

    func clearAllCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func cacheSize() -> Int64 {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }

        return files.reduce(Int64(0)) { total, fileURL in
            let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
            return total + Int64(size ?? 0)
        }
    }

    // MARK: Private

    private func cacheFileURL(for url: URL) -> URL {
        let hashed = url.absoluteString.sha256Like()
        return cacheDirectory.appendingPathComponent(hashed).appendingPathExtension("mp4")
    }
}

// MARK: — Asset Loader (один на один URL, переживает несколько ячеек)

/// Обрабатывает один конкретный видео-URL: проксирует запросы AVPlayer на сеть,
/// раздаёт уже скачанные байты всем ожидающим запросам, и пишет итоговый файл на диск.
private final class VideoAssetLoader: NSObject, AVAssetResourceLoaderDelegate, URLSessionDataDelegate {

    private let originalURL: URL
    private let localFileURL: URL
    private let onFinished: () -> Void

    private let customScheme = "videocache"
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?

    private var buffer = Data()
    private var contentLength: Int64 = 0
    private var pendingRequests = Set<AVAssetResourceLoadingRequest>()
    private let requestsLock = NSLock()

    init(originalURL: URL, localFileURL: URL, onFinished: @escaping () -> Void) {
        self.originalURL = originalURL
        self.localFileURL = localFileURL
        self.onFinished = onFinished
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    func makeAsset() -> AVURLAsset {
        var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: false)
        components?.scheme = customScheme
        let interceptedURL = components?.url ?? originalURL

        let asset = AVURLAsset(url: interceptedURL)
        asset.resourceLoader.setDelegate(self, queue: .global(qos: .userInitiated))
        return asset
    }

    // MARK: AVAssetResourceLoaderDelegate

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {

        requestsLock.lock()
        pendingRequests.insert(loadingRequest)
        requestsLock.unlock()

        if dataTask == nil {
            startDownload()
        } else {
            fulfill(loadingRequest)
        }

        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        didCancel loadingRequest: AVAssetResourceLoadingRequest
    ) {
        requestsLock.lock()
        pendingRequests.remove(loadingRequest)
        requestsLock.unlock()
    }

    // MARK: Networking

    private func startDownload() {
        var request = URLRequest(url: originalURL)
        request.setValue("bytes=0-", forHTTPHeaderField: "Range")
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let httpResponse = response as? HTTPURLResponse {
            contentLength = httpResponse.expectedContentLength

            requestsLock.lock()
            let requests = pendingRequests
            requestsLock.unlock()

            requests.forEach { fillContentInfo($0, response: httpResponse) }
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        requestsLock.lock()
        let requests = pendingRequests
        requestsLock.unlock()

        requests.forEach { fulfill($0) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer { onFinished() }

        if error == nil {
            try? buffer.write(to: localFileURL)
        }

        requestsLock.lock()
        let requests = pendingRequests
        pendingRequests.removeAll()
        requestsLock.unlock()

        requests.forEach { request in
            if let error {
                request.finishLoading(with: error)
            } else {
                request.finishLoading()
            }
        }
    }

    // MARK: Fulfilling requests

    private func fillContentInfo(_ request: AVAssetResourceLoadingRequest, response: HTTPURLResponse) {
        guard let info = request.contentInformationRequest else { return }
        info.contentType = response.mimeType
        info.contentLength = contentLength
        info.isByteRangeAccessSupported = true
    }

    private func fulfill(_ request: AVAssetResourceLoadingRequest) {
        guard let dataRequest = request.dataRequest else { return }

        let offset = Int(dataRequest.requestedOffset)
        let length = dataRequest.requestedLength

        guard buffer.count > offset else { return }

        let available = min(buffer.count - offset, length)
        guard available > 0 else { return }

        let chunk = buffer.subdata(in: offset..<(offset + available))
        dataRequest.respond(with: chunk)

        if buffer.count >= offset + length {
            requestsLock.lock()
            pendingRequests.remove(request)
            requestsLock.unlock()
            request.finishLoading()
        }
    }

    deinit {
        dataTask?.cancel()
        session.invalidateAndCancel()
    }
}

// MARK: — Helpers

private extension String {
    /// Простой стабильный хэш для имени файла кэша (без необходимости импортировать CryptoKit)
    func sha256Like() -> String {
        var hash: UInt64 = 5381
        for byte in self.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return String(hash, radix: 16)
    }
}
