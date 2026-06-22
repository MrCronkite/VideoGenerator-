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

        statusObserver?.invalidate()
        statusObserver = nil

        playerLayer.player = nil
        currentURL = nil

        loadingIndicator.stopAnimating()
    }

    func configure(with template: Template) {

        guard let url = URL(string: template.previewSmall) else { return }
        if currentURL == url { return }
        currentURL = url

        loadingIndicator.startAnimating()

        let player = VideoPlayerPool.shared.player(for: url)
        playerLayer.player = player

        statusObserver = player.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard item.status == .readyToPlay else { return }
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
        }

        player.play()
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

    deinit {
        statusObserver?.invalidate()
    }
}
