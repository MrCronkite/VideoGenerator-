//
//  ActionGridCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol ActionGridDelegate: AnyObject {
    func didSelect(action: ActionType)
}

final class ActionGridCell: UICollectionViewCell {

    private let actionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.numberOfLines = 1
        l.textColor = .white
        return l
    }()

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = R.Colors.darkBrown.withAlphaComponent(0.5)
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner,
            .layerMinXMinYCorner
        ]
        return v
    }()

    private let gridStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    private var actionItem: [ActionItem] = []

    weak var delegate: ActionGridDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        bubbleView.addSubviews(gridStack, actionLabel)
        contentView.addSubviews(bubbleView)

        contentView.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),

            gridStack.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: 24),
            gridStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            gridStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            gridStack.widthAnchor.constraint(equalToConstant: 310),
            gridStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16),

            actionLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 24),
            actionLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            actionLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16)
        ])
    }
}

extension ActionGridCell {

    func configure(with items: [ActionItem]) {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        actionItem = items
        items.enumerated().forEach { i, item in
            gridStack.addArrangedSubview(makeRow(
                item: item,
                index: i
            ))
        }
    }

    private func makeRow(
        item: ActionItem,
        index: Int
    ) -> UIView {

        let container = UIView()
        container.backgroundColor = R.Colors.darkBrown
        container.layer.cornerRadius = 24

        let icon = UIImageView(image: item.icon)
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = item.title
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.textColor = .white

        let subtitle = UILabel()
        subtitle.text = item.subtitle
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.textColor = .white.withAlphaComponent(0.5)

        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.axis = .vertical
        textStack.spacing = 4

        container.addSubviews(icon, textStack)

        container.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            container.heightAnchor.constraint(equalToConstant: 72)
        ])

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(actionTapped(_:))
        )
        container.tag = index
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true

        return container
    }


    @objc
    private func actionTapped(
        _ gesture: UITapGestureRecognizer
    ) {
        guard
            let view = gesture.view
        else { return }

        let action = actionItem[view.tag]
        delegate?.didSelect(action: action.type)
    }
}

extension ActionGridCell: ConfigurableCell {
    func configure(with message: ChatMessage) {
        actionLabel.text = message.text
        configure(with: message.actions ?? [])
    }
}
