//
//  OutgoingMessageCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

final class OutgoingMessageCell: UICollectionViewCell {

    private let bubbleView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        return v
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .white
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.bubbleView.applyHorizontalGradient(
                startColor: R.Colors.blueGradient,
                endColor: R.Colors.pinkGradient
            )
        }
    }

    private func setupUI() {
        contentView.addSubviews(bubbleView)
        bubbleView.addSubviews(messageLabel)

        activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 40),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
        ])
    }
}

extension OutgoingMessageCell: ConfigurableCell {
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
    }
}
