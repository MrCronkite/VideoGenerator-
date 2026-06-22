//
//  IncomingMessageCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

final class IncomingMessageCell: UICollectionViewCell {

    // MARK: — UI

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

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.numberOfLines = 1
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .white
        l.numberOfLines = 0
        return l
    }()

    private var messageTopConstraint: NSLayoutConstraint!

    // MARK: — Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    // MARK: — Setup

    private func setupUI() {
        contentView.addSubviews(bubbleView)

        bubbleView.addSubviews(greetingLabel)
        bubbleView.addSubviews(messageLabel)

        messageTopConstraint = messageLabel.topAnchor.constraint(
            equalTo: greetingLabel.bottomAnchor,
            constant: 0
        )

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),

            greetingLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            messageTopConstraint,

            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16),
        ])
    }
}

extension IncomingMessageCell: ConfigurableCell {
    func configure(with message: ChatMessage) {
        if message.isFirst {
            greetingLabel.text = "Hey! I’m your AI assistant"
            messageLabel.text = message.text

            greetingLabel.applyGradientText(colors: [
                R.Colors.blueGradient,
                R.Colors.pinkGradient
            ])

            messageTopConstraint.constant = 26
        } else {
            messageTopConstraint.constant = 0
            greetingLabel.text = nil
            messageLabel.text = message.text
        }

        layoutIfNeeded()
    }
}
