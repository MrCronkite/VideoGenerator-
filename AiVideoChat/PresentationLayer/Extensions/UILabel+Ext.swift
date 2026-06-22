//
//  UILabel+Ext.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

extension UILabel {
    func applyGradientText(colors: [UIColor]) {
        layoutIfNeeded()

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return }
        gradientLayer.render(in: context)

        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else { return }

        textColor = UIColor(patternImage: gradientImage)
    }
}
