//
//  FeatureRowView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit

final class FeatureRowView: BaseView {

    init(icon: UIImage?, text: String) {
        super.init(frame: .zero)

        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0

        addSubviews(iconView, label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
