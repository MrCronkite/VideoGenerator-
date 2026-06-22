//
//  DropdownMenuView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 21.06.2026.
//

import UIKit

final class DropdownMenuView: UIView {

    private var options: [String] = []
    private var onSelect: ((String) -> Void)?

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.16, alpha: 1)
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.35
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        return v
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .fillEqually
        return s
    }()

    private let dimmingView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private static let menuWidth: CGFloat = 175
    private static let rowHeight: CGFloat = 44

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubviews(dimmingView)
        addSubviews(containerView)
        containerView.addSubviews(stackView)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        dimmingView.addGestureRecognizer(dismissTap)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
    }

    func show(
        in parentView: UIView,
        anchorView: UIView,
        options: [String],
        selected: String?,
        onSelect: @escaping (String) -> Void
    ) {
        self.options = options
        self.onSelect = onSelect

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, option) in options.enumerated() {
            let row = makeRow(title: option, isSelected: option == selected, isLast: index == options.count - 1)
            stackView.addArrangedSubview(row)
        }

        parentView.addSubviews(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
        ])

        let menuHeight = CGFloat(options.count) * Self.rowHeight + 12

        let anchorFrame = anchorView.convert(anchorView.bounds, to: parentView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: anchorFrame.maxY - 150),
            containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: anchorFrame.minX - 43),
            containerView.widthAnchor.constraint(equalToConstant: Self.menuWidth),
            containerView.heightAnchor.constraint(equalToConstant: menuHeight),
        ])

        parentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }

    private func makeRow(title: String, isSelected: Bool, isLast: Bool) -> UIView {
        let row = UIView()
        row.heightAnchor.constraint(equalToConstant: Self.rowHeight).isActive = true

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: isSelected ? .semibold : .regular)
        label.textColor = .white

        row.addSubviews(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
        ])

        if isSelected {
            label.applyGradientText(
                colors: [
                    R.Colors.blueGradient,
                    R.Colors.pinkGradient
                ]
            )
        }

        if !isLast {
            let separator = UIView()
            separator.backgroundColor = .white.withAlphaComponent(0.06)
            row.addSubviews(separator)
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                separator.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                separator.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1),
            ])
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
        row.addGestureRecognizer(tap)
        row.tag = options.firstIndex(of: title) ?? 0
        row.isUserInteractionEnabled = true

        return row
    }

    @objc private func rowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        let selectedOption = options[row.tag]

        dismiss { [weak self] in
            self?.onSelect?(selectedOption)
        }
    }

    @objc private func dismissTapped() {
        dismiss()
    }

    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.alpha = 0
                self.containerView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            },
            completion: { _ in
                self.removeFromSuperview()
                completion?()
            }
        )
    }
}
