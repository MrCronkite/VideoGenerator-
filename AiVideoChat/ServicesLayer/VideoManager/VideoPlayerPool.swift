//
//  VideoPlayerPool.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 22.06.2026.
//

import UIKit
import AVFoundation

final class VideoPlayerPool {

    static let shared = VideoPlayerPool()

    private var players: [URL: AVPlayer] = [:]
    private var accessOrder: [URL] = []
    private let maxPlayers = 12

    func player(for url: URL) -> AVPlayer {
        if let existing = players[url] {
            touch(url)
            return existing
        }

        evictIfNeeded()

        let item = VideoCacheManager.shared.playerItem(for: url)
        let player = AVPlayer(playerItem: item)

        player.isMuted = true
        player.actionAtItemEnd = .none
        player.automaticallyWaitsToMinimizeStalling = false

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        players[url] = player
        accessOrder.append(url)

        return player
    }

    private func touch(_ url: URL) {
        accessOrder.removeAll { $0 == url }
        accessOrder.append(url)
    }

    private func evictIfNeeded() {
        while players.count >= maxPlayers, let oldest = accessOrder.first {
            removePlayer(for: oldest)
        }
    }

    private func removePlayer(for url: URL) {
        guard let player = players[url] else { return }
        player.pause()
        if let item = player.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
        }
        players.removeValue(forKey: url)
        accessOrder.removeAll { $0 == url }
    }

    func clearAll() {
        accessOrder.forEach { removePlayer(for: $0) }
    }
}

