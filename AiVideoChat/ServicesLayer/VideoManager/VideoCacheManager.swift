//
//  VideoCacheManager.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import Foundation
import AVFoundation

import Foundation
import AVFoundation

import Foundation
import AVFoundation

actor VideoCacheManager {

    static let shared = VideoCacheManager()

    /// Подготовка (скачка + транскод) видео в процессе, по ключу URL.
    /// Если несколько ячеек одновременно запросят один и тот же URL —
    /// все они дождутся одного и того же Task, а не запустят процесс
    /// заново каждая для себя.
    private var preparationTasks: [String: Task<URL, Never>] = [:]

    /// Сколько ячеек сейчас держат интерес к каждому URL.
    private var subscriberCounts: [String: Int] = [:]

    private let cacheDirectory: URL = {
        let base = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]

        return base.appendingPathComponent(
            "VideoCache",
            isDirectory: true
        )
    }()

    init() {
        try? FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
    }

    /// Возвращает плеер-айтем, который указывает ТОЛЬКО на уже готовый
    /// локальный файл — уменьшенную (порезанную) версию, если транскод
    /// успешен, либо на raw-кэш как fallback, если транскод не удался.
    ///
    /// В отличие от предыдущей версии здесь нет прогрессивного стрима
    /// full-HD оригинала через AVAssetResourceLoader: вызов дожидается
    /// полной загрузки и транскода, и только потом возвращает item. Это
    /// значит, что видео с самого первого показа уже порезанное — никогда
    /// не проигрывается тяжёлый оригинал даже временно.
    ///
    /// ВАЖНО: каждый вызов должен быть сбалансирован вызовом
    /// `releaseInterest(for:)`, когда ячейка больше не нуждается в этом видео.
    func playerItem(for url: URL) async -> AVPlayerItem {

        let key = url.absoluteString
        subscriberCounts[key, default: 0] += 1

        let finalURL = cacheFileURL(for: url)
        if FileManager.default.fileExists(atPath: finalURL.path) {
            return AVPlayerItem(url: finalURL)
        }

        let localURL = await prepare(url: url, key: key)
        return AVPlayerItem(url: localURL)
    }

    /// Вызывать, когда ячейка больше не нуждается в этом видео
    /// (prepareForReuse, смена URL, dealloc ячейки). Если это был последний
    /// подписчик — незавершённая подготовка (скачка/транскод) отменяется,
    /// чтобы не тратить сеть/CPU на видео, которое уже никто не ждёт.
    func releaseInterest(for url: URL) {
        let key = url.absoluteString
        guard let count = subscriberCounts[key] else { return }

        let updated = count - 1
        if updated <= 0 {
            subscriberCounts.removeValue(forKey: key)
            preparationTasks[key]?.cancel()
        } else {
            subscriberCounts[key] = updated
        }
    }

    /// Полностью сбросить все незавершённые подготовки (например, при
    /// memory warning). Уже готовые файлы на диске не трогает.
    func clearUnused() {
        for task in preparationTasks.values {
            task.cancel()
        }
        preparationTasks.removeAll()
        subscriberCounts.removeAll()
    }

    // MARK: - Private

    private func prepare(url: URL, key: String) async -> URL {
        if let existing = preparationTasks[key] {
            return await existing.value
        }

        let rawURL = rawCacheFileURL(for: url)
        let finalURL = cacheFileURL(for: url)

        let task = Task<URL, Never> {
            await self.downloadAndTranscode(url: url, rawURL: rawURL, finalURL: finalURL)
        }
        preparationTasks[key] = task

        let result = await task.value
        preparationTasks.removeValue(forKey: key)
        return result
    }

    private func downloadAndTranscode(url: URL, rawURL: URL, finalURL: URL) async -> URL {
        if !FileManager.default.fileExists(atPath: rawURL.path) {
            do {
                try await downloadRaw(from: url, to: rawURL)
            } catch {
                // Скачать не удалось (или отменили) — отдаём прямой URL,
                // AVPlayer попробует прогрузить его сам, без кэша.
                return url
            }
        }

        guard !Task.isCancelled else { return rawURL }

        do {
            // Подберите maxDimension под реальный размер ячейки * UIScreen.scale —
            // 480 здесь просто разумный дефолт для небольших grid-превью.
            try await VideoTranscoder.downscale(
                sourceURL: rawURL,
                outputURL: finalURL,
                maxDimension: 480
            )
            // raw больше не нужен — экономим место на диске.
            try? FileManager.default.removeItem(at: rawURL)
            return finalURL
        } catch {
            // Транскод не обязателен для работы плеера — отдаём хотя бы
            // оригинал из кэша, чем ничего.
            return rawURL
        }
    }

    /// Качает файл целиком через системный download-task — данные сразу
    /// льются на диск во временный файл (без накопления в памяти), затем
    /// просто переносим во `localURL`.
    private func downloadRaw(from url: URL, to localURL: URL) async throws {
        let (tempURL, response) = try await URLSession.shared.download(from: url)

        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            try? FileManager.default.removeItem(at: tempURL)
            throw URLError(.badServerResponse)
        }

        try? FileManager.default.removeItem(at: localURL)
        try FileManager.default.moveItem(at: tempURL, to: localURL)
    }

    /// Путь к финальному (уменьшенному) кэшу — то, что отдаём предпочтительно.
    private func cacheFileURL(for url: URL) -> URL {
        let hashed = url.absoluteString.sha256Like()

        return cacheDirectory
            .appendingPathComponent(hashed)
            .appendingPathExtension("mp4")
    }

    /// Путь к raw-кэшу (оригинальное разрешение, как пришло с сервера).
    /// Используется как промежуточный шаг до транскода и как fallback,
    /// если транскод не удался.
    private func rawCacheFileURL(for url: URL) -> URL {
        let hashed = url.absoluteString.sha256Like()

        return cacheDirectory
            .appendingPathComponent(hashed + "-raw")
            .appendingPathExtension("mp4")
    }
}


private final class VideoAssetLoader: NSObject, AVAssetResourceLoaderDelegate, URLSessionDataDelegate {

    private let originalURL: URL
    private let localFileURL: URL

    private let customScheme = "videocache"
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?

    /// Сколько ячеек сейчас держат интерес к этому видео.
    /// Мутируется только из VideoCacheManager (actor), так что отдельная
    /// синхронизация для самого счётчика не нужна.
    var subscriberCount: Int = 0

    private var writeHandle: FileHandle?
    private var readHandle: FileHandle?

    /// Сколько байт уже физически записано на диск. Заменяет старый
    /// `buffer: Data`, который держал в памяти весь файл целиком —
    /// теперь в памяти живёт только текущий читаемый чанк.
    private var writtenBytes: Int64 = 0

    private var contentLength: Int64 = -1
    private var pendingRequests: [AVAssetResourceLoadingRequest] = []
    private let requestsLock = NSLock()

    private var isCancelled = false

    var onFinish: (() -> Void)?

    init(
        originalURL: URL,
        localFileURL: URL
    ) {
        self.originalURL = originalURL
        self.localFileURL = localFileURL
        super.init()

        session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: nil
        )
    }

    func makeAsset() -> AVURLAsset {
        var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: false)
        components?.scheme = customScheme
        let interceptedURL = components?.url ?? originalURL

        let asset = AVURLAsset(url: interceptedURL)
        asset.resourceLoader.setDelegate(self, queue: .global(qos: .userInitiated))
        return asset
    }

    func makePlayerItem() -> AVPlayerItem {
        let asset = makeAsset()
        return AVPlayerItem(asset: asset)
    }

    // MARK: - AVAssetResourceLoaderDelegate

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {

        requestsLock.lock()
        pendingRequests.append(loadingRequest)
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
        pendingRequests.removeAll { $0 == loadingRequest }
        requestsLock.unlock()
    }

    // MARK: - Download

    private func startDownload() {
        FileManager.default.createFile(atPath: localFileURL.path, contents: nil)
        writeHandle = try? FileHandle(forWritingTo: localFileURL)
        readHandle = try? FileHandle(forReadingFrom: localFileURL)

        var request = URLRequest(url: originalURL)
        request.setValue("bytes=0-", forHTTPHeaderField: "Range")
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }

    /// Отменить загрузку и корректно завершить все ожидающие запросы с ошибкой,
    /// чтобы AVPlayerItem не застрял в вечном "ожидании данных".
    func cancel() {
        guard !isCancelled else { return }
        isCancelled = true

        dataTask?.cancel()
        session.finishTasksAndInvalidate()

        requestsLock.lock()
        let requests = pendingRequests
        pendingRequests.removeAll()
        requestsLock.unlock()

        let error = NSError(
            domain: "VideoAssetLoader",
            code: -999,
            userInfo: [NSLocalizedDescriptionKey: "Cancelled"]
        )
        requests.forEach { $0.finishLoading(with: error) }

        try? writeHandle?.close()
        try? readHandle?.close()
        writeHandle = nil
        readHandle = nil
    }

    // MARK: - URLSessionDataDelegate

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

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard !isCancelled else { return }

        writeHandle?.write(data)
        writtenBytes += Int64(data.count)

        requestsLock.lock()
        let requests = pendingRequests
        requestsLock.unlock()

        requests.forEach { fulfill($0) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.onFinish?()
            }
        }

        try? writeHandle?.close()
        writeHandle = nil

        guard !isCancelled else { return }

        requestsLock.lock()
        let requests = pendingRequests
        pendingRequests.removeAll()
        requestsLock.unlock()

        requests.forEach { request in
            if let error {
                request.finishLoading(with: error)
            } else {
                fulfill(request) // добираем последний хвост данных, если остался
                request.finishLoading()
            }
        }
    }

    // MARK: - Fulfilling requests

    private func fillContentInfo(_ request: AVAssetResourceLoadingRequest, response: HTTPURLResponse) {
        guard let info = request.contentInformationRequest else { return }
        info.contentType = response.mimeType
        info.contentLength = contentLength
        info.isByteRangeAccessSupported = true
    }

    private func fulfill(_ request: AVAssetResourceLoadingRequest) {
        guard let dataRequest = request.dataRequest, let readHandle else { return }

        // currentOffset — позиция, докуда AVFoundation уже получила данные
        // ИМЕННО для этого запроса. AVFoundation сама сдвигает её после
        // каждого успешного respond(with:). Брать requestedOffset вместо
        // currentOffset — баг из исходной версии: тогда на каждый network-чанк
        // данные пересчитывались бы заново от начала запроса (O(n²) копий
        // плюс дублирующиеся байты, отправленные в AVFoundation повторно).
        let currentOffset = Int64(dataRequest.currentOffset)

        guard writtenBytes > currentOffset else { return }
        let availableFromCurrent = writtenBytes - currentOffset

        let remainingWanted: Int64
        if dataRequest.requestsAllDataToEndOfResource {
            remainingWanted = .max
        } else {
            let requestedOffset = Int64(dataRequest.requestedOffset)
            let requestedLength = Int64(dataRequest.requestedLength)
            remainingWanted = (requestedOffset + requestedLength) - currentOffset
        }

        let bytesToRead = Int(min(remainingWanted, availableFromCurrent))
        guard bytesToRead > 0 else { return }

        do {
            try readHandle.seek(toOffset: UInt64(currentOffset))
            guard let chunk = try readHandle.read(upToCount: bytesToRead), !chunk.isEmpty else { return }
            dataRequest.respond(with: chunk)
        } catch {
            return
        }

        let isFinished: Bool
        if dataRequest.requestsAllDataToEndOfResource {
            isFinished = contentLength > 0 && Int64(dataRequest.currentOffset) >= contentLength
        } else {
            let requestedOffset = Int64(dataRequest.requestedOffset)
            let requestedLength = Int64(dataRequest.requestedLength)
            isFinished = Int64(dataRequest.currentOffset) >= requestedOffset + requestedLength
        }

        if isFinished {
            requestsLock.lock()
            pendingRequests.removeAll { $0 == request }
            requestsLock.unlock()
            request.finishLoading()
        }
    }

    deinit {
        cancel()
    }
}

private extension String {
    func sha256Like() -> String {
        var hash: UInt64 = 5381
        for byte in self.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return String(hash, radix: 16)
    }
}
