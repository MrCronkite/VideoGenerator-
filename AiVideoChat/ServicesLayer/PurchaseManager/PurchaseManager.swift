//
//  PurchaseManager.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import ApphudSDK
import StoreKit

@MainActor
protocol PurchaseManagerProtocol: AnyObject {
    var isPremium: Bool { get }

    func initialize(apiKey: String, userID: String?)
    func loadProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws -> Bool
    func restorePurchases() async throws -> Bool
    func checkPremiumStatus() -> Bool
}


final class PurchaseManager: PurchaseManagerProtocol {

    init() {}

    // MARK: — Properties
    var isPremium: Bool {
        Apphud.hasPremiumAccess()
    }

    @MainActor
    func initialize(apiKey: String, userID: String? = nil) {
        Apphud.start(apiKey: apiKey)

        if let userID {
            Apphud.updateUserID(userID)
        }

        print("✅ AppHud initialized")
    }

    @MainActor
    func loadProducts() async throws -> [Product] {
        let products = try await Apphud.fetchProducts()
        return products
    }

    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            guard let apphudProduct = Apphud.apphudProductFor(product) else {
                continuation.resume(throwing: PurchaseError.noProductsLoaded)
                return
            }
            Apphud.purchase(apphudProduct) { result in
                if let error = result.error {
                    if (error as NSError).code == SKError.paymentCancelled.rawValue {
                        continuation.resume(throwing: PurchaseError.userCancelled)
                    } else {
                        continuation.resume(throwing: PurchaseError.purchaseFailed(error))
                    }
                    return
                }

                let isActive =
                result.subscription?.isActive() == true ||
                result.nonRenewingPurchase?.isActive() == true

                continuation.resume(returning: isActive)
            }
        }
    }

    // MARK: — Restore
    @MainActor
    func restorePurchases() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            Apphud.restorePurchases { result in
                if let error = result.error {
                    continuation.resume(
                        throwing: PurchaseError.restoreFailed(error)
                    )
                    return
                }

                let hasAccess = Apphud.hasPremiumAccess()

                if hasAccess {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(
                        throwing: PurchaseError.restoreFailed(
                            NSError(
                                domain: "Apphud",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "No active subscriptions found."
                                ]
                            )
                        )
                    )
                }
            }
        }
    }

    // MARK: — Check Status
    @MainActor
    func checkPremiumStatus() -> Bool {
        Apphud.hasPremiumAccess()
    }
}


