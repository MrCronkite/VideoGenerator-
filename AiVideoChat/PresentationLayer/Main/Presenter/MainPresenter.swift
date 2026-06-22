//
//  MainPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit

protocol MainPresenter: AnyObject {

    func showSettings()
    func openAIChat()
    func openTemplates()
}

final class MainPresenterImpl: MainPresenter {
    weak var view: MainViewProtocol?
    private let router: AppRouterProtocol

    init(view: MainViewProtocol? = nil, router: AppRouterProtocol) {
        self.view = view
        self.router = router
    }

    func openAIChat() {
        router.showChatAI()
    }

    func openTemplates() {
        router.showTemplates()
    }

    func showSettings() {
        router.showSettings()
    }
}
