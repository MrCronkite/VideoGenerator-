//
//  CategoryTemplatesCell.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit

final class CategoryTemplatesCell: UICollectionViewCell {

    static let reuseIdentifier = "CategoryTemplatesCell"

    private let label = UILabel()

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            R.Colors.blueGradient.cgColor,
            R.Colors.pinkGradient.cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        label.font = .systemFont(
            ofSize: 15,
            weight: .medium
        )
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.isHidden = true

        contentView.addSubviews(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer.isHidden = true
        contentView.backgroundColor = R.Colors.darkBrown
        label.textColor = .white.withAlphaComponent(0.5)
    }

    func configure(title: String, selected: Bool) {
        label.text = title

        if selected {
            contentView.backgroundColor = .clear
            gradientLayer.isHidden = false
        } else {
            gradientLayer.isHidden = true
            contentView.backgroundColor = R.Colors.darkBrown
        }

        label.textColor = selected
            ? .white
            : .white.withAlphaComponent(0.5)
    }
}
