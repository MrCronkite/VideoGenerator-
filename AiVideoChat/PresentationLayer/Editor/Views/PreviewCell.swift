//
//  PreviewCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit
import AVFoundation

final class PreviewCell: UICollectionViewCell {

    static let reuseIdentifier = "PreviewCell"

    private let playerLayer = AVPlayerLayer()
    private var currentURL: URL?
    private var playbackTask: Task<Void, Never>?
    private var player: AVPlayer?

    // MARK: — Loading indicator

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = -1
        return indicator
    }()

    private var statusObserver: NSKeyValueObservation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cancelPlayback()
        currentURL = nil

        loadingIndicator.stopAnimating()
    }

    func configure(with template: Template) {

        guard let url = URL(string: template.previewSmall) else { return }

        if currentURL == url { return }

        cancelPlayback()
        currentURL = url

        playbackTask = Task(priority: .utility) { [weak self] in
            guard let self, self.currentURL == url else { return }

            let item = await VideoCacheManager.shared.playerItem(for: url)

            guard self.currentURL == url else {
                await VideoCacheManager.shared.releaseInterest(for: url)
                return
            }

            await MainActor.run {
                guard self.currentURL == url else { return }

                let player = AVPlayer(playerItem: item)
                player.isMuted = true
                player.actionAtItemEnd = .none
                player.automaticallyWaitsToMinimizeStalling = false

                self.player = player
                self.playerLayer.player = player
                player.play()
            }
        }
    }

    func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = R.Colors.darkBrown

        playerLayer.videoGravity = .resizeAspectFill
        contentView.layer.addSublayer(playerLayer)

        contentView.addSubviews(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func cancelPlayback() {
        playbackTask?.cancel()
        playbackTask = nil

        if let url = currentURL {
            Task { await VideoCacheManager.shared.releaseInterest(for: url) }
        }

        player?.pause()
        playerLayer.player = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    func pausePlayback() {
        player?.pause()
    }

    func resumePlaybackIfNeeded() {
        guard currentURL != nil else { return }
        player?.play()
    }
}
