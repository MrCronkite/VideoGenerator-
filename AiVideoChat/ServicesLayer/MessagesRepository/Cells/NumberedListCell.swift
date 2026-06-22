//
//  NumberedListCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

final class NumberedListCell: UICollectionViewCell {

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

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.numberOfLines = 1
        l.textColor = .white
        return l
    }()


    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}


extension NumberedListCell {

    private func setupUI() {

        contentView.addSubviews(bubbleView)
        bubbleView.addSubviews(stackView, titleLabel)

        NSLayoutConstraint.activate([

            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -40
            ),

            titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with items: [String]) {

        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        for (index, text) in items.enumerated() {
            stackView.addArrangedSubview(
                makeRow(
                    number: index + 1,
                    text: text
                )
            )
        }
    }

    func makeRow(
        number: Int,
        text: String
    ) -> UIView {

        let container = UIView()

        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        numberLabel.textColor = R.Colors.pinkGradient

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.font = .systemFont(ofSize: 16)
        textLabel.textColor = .white

        let rowStack = UIStackView(
            arrangedSubviews: [
                numberLabel,
                textLabel
            ]
        )

        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 8

        container.addSubviews(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: container.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            numberLabel.widthAnchor.constraint(equalToConstant: 20)
        ])

        return container
    }
}

extension NumberedListCell: ConfigurableCell {
    func configure(with message: ChatMessage) {
        titleLabel.text = message.text
        configure(with: message.list)
    }
}
