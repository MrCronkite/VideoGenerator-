//
//  UIView+Ext.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit
import Lottie

extension UIView {

    func addSubviews(
        _ views: UIView...
    ) {
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func removeGradient() {
        layer
            .sublayers?
            .first(
                where: { $0.name == "horizontalGradientLayer" }
            )?
            .removeFromSuperlayer()
    }

    func activate(
        _ constraints: [NSLayoutConstraint]
    ) {
        NSLayoutConstraint.activate(constraints)
    }

    func applyHorizontalGradient(
        startColor: UIColor,
        endColor: UIColor
    ) {
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.frame = bounds

        gradient.cornerRadius = layer.cornerRadius
        gradient.maskedCorners = layer.maskedCorners

        layer.insertSublayer(gradient, at: 0)
    }

    func setupAnimation(name: String) {
        let animationView = LottieAnimationView(name: name)
        animationView.frame = self.bounds
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        self.addSubview(animationView)
        animationView.play()
    }
}

extension UIViewController {

    func addGradientBlurBackground() {

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = false

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemPink.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.addSublayer(gradientLayer)

        let blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterial)
        )
        blurView.translatesAutoresizingMaskIntoConstraints = false

        gradientView.addSubview(blurView)

        container.addSubview(gradientView)

        view.insertSubview(container, at: 0)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 350),

            gradientView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 500),
            gradientView.heightAnchor.constraint(equalToConstant: 250),

            blurView.topAnchor.constraint(equalTo: gradientView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor)
        ])

        gradientView.transform = CGAffineTransform(rotationAngle: .pi / 9) // ~20°

        gradientView.layoutIfNeeded()

        gradientLayer.frame = CGRect(
            origin: .zero,
            size: CGSize(width: 500, height: 250)
        )

        gradientView.layer.cornerRadius = 120
        gradientView.clipsToBounds = true

        gradientLayer.cornerRadius = 120
    }
}
