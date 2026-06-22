//
//  SubscriptionCardView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit
import StoreKit

final class SubscriptionCardView: BaseView {

    var onTap: (() -> Void)?
    let product: Product

    private let containerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor
        return v
    }()

    private let gradientBorderLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [R.Colors.blueGradient.cgColor, R.Colors.pinkGradient.cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 20
        g.opacity = 0
        return g
    }()

    private let gradientBorderMask: CAShapeLayer = {
        let m = CAShapeLayer()
        m.fillColor = UIColor.clear.cgColor
        m.strokeColor = UIColor.white.cgColor
        m.lineWidth = 1.5
        return m
    }()

    private let periodLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = UIColor(hex: "F0EEF8")
        return l
    }()

    private let badgeLabel: UILabel = {
        let l = UILabel()
        l.text = "SAVE 80%"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let badgeView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        return v
    }()

    private let weeklyPriceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hex: "F0EEF8")
        l.textAlignment = .right
        return l
    }()

    private let fullPriceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hex: "9B9BB5")
        l.textAlignment = .right
        return l
    }()

    init(product: Product) {
        self.product = product
        super.init(frame: .zero)
        setupUI()
        configure()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = containerView.bounds
        gradientBorderMask.frame = containerView.bounds
        gradientBorderMask.path = UIBezierPath(
            roundedRect: containerView.bounds.insetBy(dx: 0.75, dy: 0.75),
            cornerRadius: 20
        ).cgPath

        DispatchQueue.main.async {
            self.badgeView.applyHorizontalGradient(
                startColor: R.Colors.blueGradient,
                endColor:R.Colors.pinkGradient
            )
        }
    }

    private func setupUI() {
        addSubviews(containerView)
        containerView.layer.addSublayer(gradientBorderLayer)
        gradientBorderLayer.mask = gradientBorderMask

        badgeView.addSubviews(badgeLabel)

        containerView.addSubviews(
            periodLabel,
            badgeView,
            weeklyPriceLabel,
            fullPriceLabel
        )

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 72),

            periodLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            periodLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),

            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -16),
            badgeLabel.topAnchor.constraint(equalTo: badgeView.topAnchor, constant: 6),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: -6),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 16),

            badgeView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            badgeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            weeklyPriceLabel.leadingAnchor.constraint(equalTo: periodLabel.trailingAnchor, constant: 3),
            weeklyPriceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),

            fullPriceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            fullPriceLabel.topAnchor.constraint(equalTo: weeklyPriceLabel.bottomAnchor, constant: 6),
        ])
    }

    private func configure() {
        let period = product.subscription?.subscriptionPeriod

        let isYearly = period?.unit == .year

        switch period?.unit {
        case .year:
            periodLabel.text = "Yearly"

        case .month:
            periodLabel.text = "Monthly"

        case .week:
            periodLabel.text = "Weekly"

        default:
            periodLabel.text = product.displayName
        }

        let fullPrice = product.displayPrice

        let weeklyPrice = weeklyPriceString()

        weeklyPriceLabel.text = "\(weeklyPrice)/week"

        fullPriceLabel.text = "\(fullPrice)"

        badgeLabel.isHidden = !isYearly
        badgeView.isHidden = !isYearly

        setSelected(false)
    }

    private func weeklyPriceString() -> String {
        guard let period = product.subscription?.subscriptionPeriod else {
            return product.displayPrice
        }

        let weeklyPrice: Decimal

        switch period.unit {
        case .week:
            weeklyPrice = product.price

        case .month:
            weeklyPrice = product.price / 4

        case .year:
            weeklyPrice = product.price / 52

        default:
            weeklyPrice = product.price
        }

        return weeklyPrice.formatted(
            .currency(code: product.priceFormatStyle.currencyCode)
        )
    }

    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            if selected {
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.gradientBorderLayer.opacity = 1
            } else {
                self.gradientBorderLayer.opacity = 0
                self.containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor
            }
        }
    }

    @objc private func tapped() { onTap?() }
}
