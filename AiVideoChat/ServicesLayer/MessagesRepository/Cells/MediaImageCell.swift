//
//  MediaImageCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

final class MediaImageCell: UICollectionViewCell {

    // MARK: - UI

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = R.Colors.darkBrown
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner,
            .layerMinXMinYCorner
        ]
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0.1, alpha: 1)
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubviews(bubbleView)
        bubbleView.addSubviews(imageView)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),

            imageView.topAnchor.constraint(equalTo: bubbleView.topAnchor , constant: 16),
            imageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16)
        ])

        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }
}

extension MediaImageCell: ConfigurableCell {
    func configure(with message: ChatMessage) {
        imageView.image = message.image
    }
}
