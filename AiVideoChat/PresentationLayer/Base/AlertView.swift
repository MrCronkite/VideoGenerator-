//
//  AlertView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 21.06.2026.
//

import UIKit


final class CustomAlertView: BaseView {

    private var onConfirm: (() -> Void)?

    private let dimmingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.16, alpha: 1)
        v.layer.cornerRadius = 20
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        iv.image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config)
        iv.tintColor = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Something went wrong."
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(white: 0.7, alpha: 1)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("OK", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.65, green: 0.55, blue: 0.98, alpha: 1)
        b.layer.cornerRadius = 14
        return b
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubviews(dimmingView, cardView)

        cardView.addSubviews(
            iconView,
            titleLabel,
            messageLabel,
            confirmButton
        )

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            cardView.widthAnchor.constraint(equalToConstant: 280),

            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            iconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            confirmButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            confirmButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 46),
            confirmButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
        ])

        confirmButton.addTarget(
            self,
            action: #selector(confirmTapped),
            for: .touchUpInside
        )

        alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }

    func show(
        in parentView: UIView,
        message: String,
        onConfirm: (() -> Void)? = nil
    ) {
        self.onConfirm = onConfirm
        messageLabel.text = message

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

    @objc private func confirmTapped() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.alpha = 0
                self.cardView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            },
            completion: { _ in
                self.removeFromSuperview()
                self.onConfirm?()
            }
        )
    }
}


