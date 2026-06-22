//
//  HistoryChatCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit

final class HistoryChatCell: UITableViewCell {

    static let id = "HistoryChatCell"

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.image = R.Images.iconTalk
        iv.tintColor = .label
        return iv
    }()

    let containerView = UIView()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        return lb
    }()

    private let timeLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12)
        lb.textColor = .white.withAlphaComponent(0.5)
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        containerView.addSubviews(iconView, titleLabel, timeLabel)
        contentView.addSubviews(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
        ])

        containerView.backgroundColor = R.Colors.darkBrown
        contentView.backgroundColor = .clear
        containerView.layer.cornerRadius = 24
        contentView.clipsToBounds = true
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with model: ChatInfo) {
        titleLabel.text = model.lastMessagePreview

        if let date = model.updatedAt.toDolaDate() {
            timeLabel.text = date.timeString()
        } else {
            timeLabel.text = ""
        }
    }
}





