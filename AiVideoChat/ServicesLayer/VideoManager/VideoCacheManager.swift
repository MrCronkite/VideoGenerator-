//
//  VideoCacheManager.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import Foundation
import AVFoundation

actor VideoCacheManager {

    static let shared = VideoCacheManager()

    private var preparationTasks: [String: Task<URL, Never>] = [:]
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

    func clearUnused() {
        for task in preparationTasks.values {
            task.cancel()
        }
        preparationTasks.removeAll()
        subscriberCounts.removeAll()
    }

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
                return url
            }
        }

        guard !Task.isCancelled else { return rawURL }

        do {
            try await VideoTranscoder.downscale(
                sourceURL: rawURL,
                outputURL: finalURL,
                maxDimension: 230
            )
            try? FileManager.default.removeItem(at: rawURL)
            return finalURL
        } catch {
            return rawURL
        }
    }

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

    private func cacheFileURL(for url: URL) -> URL {
        let hashed = url.absoluteString.sha256Like()

        return cacheDirectory
            .appendingPathComponent(hashed)
            .appendingPathExtension("mp4")
    }

    private func rawCacheFileURL(for url: URL) -> URL {
        let hashed = url.absoluteString.sha256Like()

        return cacheDirectory
            .appendingPathComponent(hashed + "-raw")
            .appendingPathExtension("mp4")
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
