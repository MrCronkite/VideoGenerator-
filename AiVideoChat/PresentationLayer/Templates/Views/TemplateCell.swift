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
    private var statusObserver: NSKeyValueObservation?

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

        statusObserver?.invalidate()
        statusObserver = nil

        playerLayer.player = nil
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

    deinit {
        statusObserver?.invalidate()
    }
}


