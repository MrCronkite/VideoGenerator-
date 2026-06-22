//
//  PaywallPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit
import ApphudSDK
import StoreKit

protocol PaywallPresenter: AnyObject {
    func loadProducts()
    func purchase(_ product: Product)
    func restore()
    func close()
}

final class PaywallPresenterImpl: PaywallPresenter {

    weak var view: PaywallViewProtocol?
    private let purchaseManager: PurchaseManagerProtocol
    private let router: AppRouterProtocol

    init(
        view: PaywallViewProtocol,
        router: AppRouterProtocol,
        purchaseManager: PurchaseManagerProtocol
    ) {
        self.view = view
        self.router = router
        self.purchaseManager = purchaseManager
    }

    func loadProducts() {
        view?.showLoading(true)

        Task { @MainActor in
            let products = try await purchaseManager.loadProducts()
            view?.showLoading(false)

            guard !products.isEmpty else {
                view?.showError("No products found.")
                return
            }

            view?.showProducts(products)
        }
    }

    func purchase(_ product: Product) {
        view?.showLoading(true)

        Task { @MainActor in
            do {
                let success = try await purchaseManager.purchase(product)
                view?.showLoading(false)

                if success {
                    close()
                } else {
                    view?.showError("Failed to activate subscription.")
                }
            } catch PurchaseError.userCancelled {
                view?.showLoading(false)
            } catch {
                view?.showLoading(false)
                view?.showError(error.localizedDescription)
            }
        }
    }

    func restore() {
        view?.showLoading(true)

        Task { @MainActor in
            do {
                let restored = try await purchaseManager.restorePurchases()
                view?.showLoading(false)

                if restored {
                    close()
                } else {
                    view?.showError("No active subscriptions found.")
                }
            } catch {
                view?.showLoading(false)
                view?.showError(error.localizedDescription)
            }
        }
    }

    func close() {
        router.showMain()
    }
}
