//
//  InfoOverlayView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 22.06.2026.
//

import UIKit


final class InfoOverlayView: UIView {

    private var dismissOnBackgroundTap: Bool = true

    private let dimmingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.18, alpha: 1)
        v.layer.cornerRadius = 18
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let textLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubviews(dimmingView, cardView)

        cardView.addSubviews(iconView, textLabel)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 60),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -60),
            cardView.widthAnchor.constraint(equalToConstant: 239),

            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            iconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),

            textLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            textLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        dimmingView.addGestureRecognizer(tap)

        alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }

    func show(
        in parentView: UIView,
        icon: UIImage?,
        text: String,
        dismissOnBackgroundTap: Bool = true
    ) {
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        iconView.image = icon
        textLabel.text = text

        parentView.addSubviews(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
        ])

        parentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.cardView.transform = .identity
        }
    }

    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.alpha = 0
                self.cardView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            },
            completion: { _ in
                self.removeFromSuperview()
                completion?()
            }
        )
    }

    @objc private func backgroundTapped() {
        guard dismissOnBackgroundTap else { return }
        hide()
    }
}

