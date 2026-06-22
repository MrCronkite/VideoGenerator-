//
//  TypingIndicatorCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

final class TypingIndicatorCell: UICollectionViewCell {

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

    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 5
        sv.alignment = .center
        return sv
    }()

    private var dots: [UIView] = []
    private var dotGradientLayers: [CAGradientLayer] = []

    /// Набор цветов, между которыми циклически переливается каждая точка
    private let gradientPalette: [CGColor] = [
        R.Colors.blueGradient.cgColor,
        R.Colors.pinkGradient.cgColor,
        R.Colors.blueGradient.cgColor // замыкаем цикл для плавного бесконечного повтора
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDots()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnimating()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, dot) in dots.enumerated() {
            dotGradientLayers[index].frame = dot.bounds
        }
    }
}

extension TypingIndicatorCell {

    func setupUI() {
        contentView.addSubviews(stack)

        contentView.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func setupDots() {
        for i in 0..<3 {
            let dot = UIView()
            dot.layer.cornerRadius = 5
            dot.clipsToBounds = true

            dot.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 10),
                dot.heightAnchor.constraint(equalToConstant: 10)
            ])

            // Градиентный слой внутри каждой точки — именно его colors будем анимировать
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [gradientPalette[0], gradientPalette[1]]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            dot.layer.addSublayer(gradientLayer)

            // Затухание прозрачности — оставлено как было
            let opacity = CAKeyframeAnimation(keyPath: "opacity")
            opacity.values = [0.5, 1.0, 0.5]
            opacity.duration = 0.6
            opacity.repeatCount = .infinity
            opacity.beginTime = CACurrentMediaTime() + Double(i) * 0.15
            dot.layer.add(opacity, forKey: "fade")

            stack.addArrangedSubview(dot)
            dots.append(dot)
            dotGradientLayers.append(gradientLayer)
        }
    }

    func startAnimating() {

        stopAnimating()

        for (index, dot) in dots.enumerated() {

            // Пульсация масштаба — оставлена как было
            let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleAnimation.values = [1.0, 1.4, 1.0]
            scaleAnimation.keyTimes = [0, 0.5, 1]
            scaleAnimation.duration = 0.6
            scaleAnimation.repeatCount = .infinity
            scaleAnimation.beginTime = CACurrentMediaTime() + Double(index) * 0.15
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            dot.layer.add(scaleAnimation, forKey: "pulse")

            // Смена градиента — переливается между цветами палитры по кругу
            let gradientAnimation = CAKeyframeAnimation(keyPath: "colors")
            gradientAnimation.values = [
                [gradientPalette[0], gradientPalette[1]],
                [gradientPalette[1], gradientPalette[2]],
                [gradientPalette[0], gradientPalette[1]]
            ]
            gradientAnimation.keyTimes = [0, 0.5, 1]
            gradientAnimation.duration = 1.2
            gradientAnimation.repeatCount = .infinity
            gradientAnimation.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            gradientAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            gradientAnimation.isRemovedOnCompletion = false
            dotGradientLayers[index].add(gradientAnimation, forKey: "gradientShift")
        }
    }

    func stopAnimating() {
        dots.forEach {
            $0.layer.removeAnimation(forKey: "pulse")
            $0.transform = .identity
        }
        dotGradientLayers.forEach {
            $0.removeAnimation(forKey: "gradientShift")
        }
    }
}
