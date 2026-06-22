//
//  SettingsPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit

protocol SettingsPresenter {
    func showPaywoll()
}

final class SettingsPresenterImpl: SettingsPresenter {

    weak var view: SettingsViewProtocol?
    let router: AppRouterProtocol

    init(view: SettingsViewProtocol?,
         router: AppRouterProtocol
    ) {
        self.view = view
        self.router = router
    }

    func showPaywoll() {
        router.showPaywall()
    }
}
