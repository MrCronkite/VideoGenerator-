//
//  AppDelegate.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let pm = PurchaseManager()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        pm.initialize(
            apiKey: "app_FmCjFTwjWpcLSafxT8vCDeVffJyfFS",
            userID: nil
        )

        return true

    }
}

