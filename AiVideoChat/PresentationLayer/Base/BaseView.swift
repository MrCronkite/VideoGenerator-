//
//  BaseView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addConstraintViews()
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addConstraintViews()
        configureAppearance()
    }
}

@objc extension BaseView {
    func setupView() {}

    func addConstraintViews() {}

    func configureAppearance() {}
}
