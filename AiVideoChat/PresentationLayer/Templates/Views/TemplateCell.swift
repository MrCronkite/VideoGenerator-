//
//  TemplateCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit
import AVFoundation
import CachingPlayerItem


final class TemplateCell: UICollectionViewCell {

    static let reuseIdentifier = "TemplateCell"

    private let playerLayer = AVPlayerLayer()

    private var currentURL: URL?
    private var playbackTask: Task<Void, Never>?
    private var player: AVPlayer?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = R.Colors.darkBrown

        playerLayer.videoGravity = .resizeAspectFill
        contentView.layer.addSublayer(playerLayer)

        contentView.addSubviews(titleLabel, loadingIndicator)

        contentView.activate([
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(with template: Template) {
        guard let url = URL(string: template.previewSmall) else { return }

        titleLabel.text = template.name

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


