//
//  AppStorage.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 23.06.2026.
//

import UIKit

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

enum AppStorageKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
}

