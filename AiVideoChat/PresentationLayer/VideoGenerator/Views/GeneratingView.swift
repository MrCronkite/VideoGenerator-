//
//  GeneratingView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 21.06.2026.
//

import UIKit
import Lottie

final class GeneratingView: BaseView {

    private let cardView = UIView()

    private let textLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.text = "Generating…"
        return l
    }()

    private let subtextLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .white.withAlphaComponent(0.5)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.text = "We’re creating the best result for you"
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        cardView.setupAnimation(name: "loader")
    }

    override func setupView() {
        super.setupView()
        addSubviews(
            cardView,
            textLabel,
            subtextLabel
        )
    }

    override func addConstraintViews() {
        super.addConstraintViews()
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 316),
            cardView.heightAnchor.constraint(equalToConstant: 316),

            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -115),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            subtextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8),
            subtextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
