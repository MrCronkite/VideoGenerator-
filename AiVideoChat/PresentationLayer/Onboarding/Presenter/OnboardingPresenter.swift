//
//  OnboardingPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol OnboardingPresenter: AnyObject {
   func showPaywall()
}

final class OnboardingPresenterImpl: OnboardingPresenter {
    weak var view: OnboardingProtocol?
    private let router: AppRouterProtocol

    init(
        view: OnboardingProtocol,
        router: AppRouterProtocol
    ) {
        self.view = view
        self.router = router
    }


    func showPaywall() {
        router.hasSeenOnboarding = true 
        router.showPaywall()
    }
}
