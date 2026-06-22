//
//  PaywallProduct.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import ApphudSDK
import StoreKit
import UIKit


enum PurchaseError: Error, LocalizedError {
    case productNotFound
    case purchaseFailed(Error)
    case restoreFailed(Error)
    case noProductsLoaded
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .productNotFound:       return "Product not found"
        case .purchaseFailed(let e): return "Purchase error: \(e.localizedDescription)"
        case .restoreFailed(let e):  return "Recovery error: \(e.localizedDescription)"
        case .noProductsLoaded:      return "Products not loaded."
        case .userCancelled:         return "Cancelled by the user."
        }
    }
}
