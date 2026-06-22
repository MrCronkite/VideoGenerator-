//
//  PaywallViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit
import ApphudSDK
import StoreKit

protocol PaywallViewProtocol: AnyObject {
    func showProducts(_ products: [Product])
    func showLoading(_ isLoading: Bool)
    func showError(_ message: String)
}


final class PaywallViewController: BaseController, PaywallViewProtocol {

    private var products: [Product] = []
    private var selectedProduct: Product?
    private var subscriptionCards: [SubscriptionCardView] = []

    var presenter: PaywallPresenter!

    // MARK: — UI

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(R.Images.iconClose, for: .normal)
        b.alpha = 0
        return b
    }()


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.text = "Create anything \nyou want"
        l.font = .systemFont(ofSize: 34, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let featuresStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        return s
    }()

    private let subscriptionsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        return s
    }()

    private let smallIconButton: UIButton = {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = R.Images.iconClock
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        config.baseForegroundColor = .white.withAlphaComponent(0.5)

        var titleAttr = AttributedString("Cancel Anytime")
        titleAttr.font = .systemFont(ofSize: 12, weight: .medium)
        config.attributedTitle = titleAttr
        config.contentInsets = .zero

        b.configuration = config
        return b
    }()

    private let subscribeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Unlock now", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 24
        return b
    }()

    private let bottomLinksStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .equalSpacing
        return s
    }()

    private let privacyButton = PaywallViewController.makeLinkButton(
        title: "Privacy Policy"
    )

    private let restoreButton = PaywallViewController.makeLinkButton(
        title: "Restore Purchases"
    )

    private let termsButton = PaywallViewController.makeLinkButton(
        title: "Terms of Use"
    )

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        return s
    }()

    // MARK: — Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadProducts()

        scheduleCloseButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        subscribeButton.applyHorizontalGradient(
            startColor: R.Colors.blueGradient,
            endColor: R.Colors.pinkGradient
        )
    }

    // MARK: — Setup

    override func setupView() {
        super.setupView()
        view.backgroundColor = R.Colors.bgColor

        bottomLinksStack.addArrangedSubview(privacyButton)
        bottomLinksStack.addArrangedSubview(restoreButton)
        bottomLinksStack.addArrangedSubview(termsButton)

        view.addSubviews(
            closeButton,
            contentStack,
            bottomLinksStack,
            subscribeButton,
            smallIconButton,
            subscriptionsStack,
            featuresStack,
            titleLabel
        )

        view.activate([
            contentStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: view.widthAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            bottomLinksStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomLinksStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomLinksStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subscribeButton.bottomAnchor.constraint(equalTo: bottomLinksStack.topAnchor, constant: -16),
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),

            smallIconButton.heightAnchor.constraint(equalToConstant: 30),
            smallIconButton.widthAnchor.constraint(equalToConstant: 150),
            smallIconButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            smallIconButton.bottomAnchor.constraint(equalTo: subscribeButton.topAnchor, constant: -16),

            subscriptionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscriptionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subscriptionsStack.bottomAnchor.constraint(equalTo: smallIconButton.topAnchor, constant: -32),

            featuresStack.widthAnchor.constraint(equalToConstant: 290),
            featuresStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            featuresStack.bottomAnchor.constraint(equalTo: subscriptionsStack.topAnchor, constant: -32),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: featuresStack.topAnchor, constant: -32)
        ])

        setupFeatureRows()
    }

    private func setupFeatureRows() {
        let features: [(UIImage?, String)] = [
            (R.Images.iconTalk, "Get results in seconds"),
            (R.Images.iconWrite, "Turn any text into better writing"),
            (R.Images.iconUnderstand, "Simplify complex information"),
            (R.Images.iconVideo, "Create content with AI templates")
        ]

        features.forEach { icon, text in
            featuresStack
                .addArrangedSubview(FeatureRowView(
                    icon: icon,
                    text: text
                ))
        }
    }

    override func setupBehavior() {
        super.setupBehavior()

        closeButton.addTarget(
            self,
            action: #selector(closeTapped),
            for: .touchUpInside
        )

        subscribeButton.addTarget(
            self,
            action: #selector(subscribeTapped),
            for: .touchUpInside
        )

        restoreButton.addTarget(
            self,
            action: #selector(restoreTapped),
            for: .touchUpInside
        )
    }

    func showProducts(_ products: [Product]) {
        applyProducts(products)
    }

    func showLoading(_ isLoading: Bool) {
        isLoading
        ? showLoadingIndicator()
        : hideLoadingIndicator()
    }

    func showError(_ message: String) {
        showAlert(message: message)
    }

    // MARK: — Actions

    @objc
    private func closeTapped() {
        presenter.close()
    }

    @objc
    private func subscribeTapped() {
        guard let product = selectedProduct else { return }
        presenter.purchase(product)
    }

    @objc
    private func restoreTapped() {
        presenter.restore()
    }

    // MARK: — Close button delay

    private func scheduleCloseButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1
            }
        }
    }

    // MARK: — Products

    func applyProducts(_ products: [Product]) {
        self.products = products
        subscriptionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        subscriptionCards.removeAll()

        products.forEach { product in
            let card = SubscriptionCardView(product: product)
            card.onTap = { [weak self] in self?.selectProduct(product) }
            subscriptionsStack.addArrangedSubview(card)
            subscriptionCards.append(card)
        }

        let defaultProduct = products.first {
            $0.subscription?.subscriptionPeriod.unit == .year
        } ?? products.first

        if let defaultProduct {
            selectProduct(defaultProduct)
        }
    }

    private func selectProduct(_ product: Product) {
        selectedProduct = product
        subscriptionCards.forEach {
            $0.setSelected($0.product.id == product.id)
        }
    }

    // MARK: — Layout helpers


    private static func makeLinkButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        b.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
        return b
    }
}




