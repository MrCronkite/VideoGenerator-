//
//  LoadingView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit

final class LoadingView: BaseView {

    private var isAnimating: Bool = false

    private let indicator = UIActivityIndicatorView()
    private let containerView = UIView()

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            R.Colors.blueGradient.cgColor,
            R.Colors.pinkGradient.cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let maskLayer = CALayer()
    private var displayLink: CADisplayLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        displayLink?.invalidate()
    }
}

extension LoadingView {

    override func setupView() {
        super.setupView()
        addSubviews(containerView)
        containerView.addSubviews(indicator)

        containerView.layer.addSublayer(gradientLayer)
        gradientLayer.mask = maskLayer
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 80),
            containerView.heightAnchor.constraint(equalToConstant: 80),

            indicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            indicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            indicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            indicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = R.Colors.darkBrown
        containerView.layer.cornerRadius = 15
        indicator.style = .medium
        indicator.color = .white
        self.backgroundColor = R.Colors.bgDark.withAlphaComponent(0.3)
        self.isUserInteractionEnabled = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.gradientLayer.frame = self.indicator.frame
            self.maskLayer.frame = self.indicator.bounds
        }
    }
}

extension LoadingView {

    func start() {
        guard !isAnimating else { return }

        isAnimating = true
        indicator.startAnimating()
        indicator.isHidden = true

        startMaskUpdates()

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        })
    }

    func finish() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.indicator.stopAnimating()
            self.stopMaskUpdates()
            self.isAnimating = false
        })
    }
}

private extension LoadingView {

    func startMaskUpdates() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateMask))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopMaskUpdates() {
        displayLink?.invalidate()
        displayLink = nil
        maskLayer.contents = nil
    }

    @objc
    func updateMask() {
        guard let snapshot = indicator.layer.snapshotImage() else { return }
        maskLayer.contents = snapshot
    }
}

private extension CALayer {
    func snapshotImage() -> CGImage? {
        let wasHidden = isHidden
        isHidden = false

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
            isHidden = wasHidden
        }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
}
