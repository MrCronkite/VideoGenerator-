//
//  FeatureCardView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 22.06.2026.
//

import UIKit

final class FeatureCardView: UIView {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(
        icon: UIImage?,
        title: String,
        subtitle: String
    ) {
        super.init(frame: .zero)

        layer.cornerRadius = 24
        clipsToBounds = true
        backgroundColor = UIColor(
            white: 1,
            alpha: 0.08
        )

        iconView.image = icon
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(
            ofSize: 18,
            weight: .semibold
        )
        titleLabel.textColor = .white

        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )
        subtitleLabel.textColor = .white.withAlphaComponent(0.7)

        addSubviews(
            iconView,
            titleLabel,
            subtitleLabel
        )

        activate([

            iconView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),

            iconView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 16
            ),

            iconView.widthAnchor.constraint(
                equalToConstant: 36
            ),

            iconView.heightAnchor.constraint(
                equalToConstant: 36
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),

            titleLabel.topAnchor.constraint(
                equalTo: iconView.bottomAnchor,
                constant: 12
            ),

            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),

            subtitleLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
