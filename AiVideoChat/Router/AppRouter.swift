//
//  AppRouter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol RouterProtocol: AnyObject {
    var navigationController: UINavigationController? { get set }
    
    func initialViewController()
}

protocol AppRouterProtocol: RouterProtocol {
    var hasSeenOnboarding: Bool { get set }
    var onChatSelected: ((String) -> Void)? { get set }

    func showPaywall()
    func showOnboarding()
    func showMain()
    func showSettings()
    func showChatAI()
    func showHistoryChats()
    func showTemplates()
    func showEditor(_ templates: [Template])
    func showVideoResult(_ params: VideoParams)

    func dismiss()
    func pop()
}


final class AppRouter: AppRouterProtocol {

    weak var navigationController: UINavigationController?
    private let builder: BuilderProtocol

    @UserDefault(
        key: AppStorageKeys.hasSeenOnboarding,
        defaultValue: false
    )
    var hasSeenOnboarding: Bool

    var onChatSelected: ((String) -> Void)?

    init(builder: BuilderProtocol = ModuleBuilder()) {
        self.builder = builder
    }

    func initialViewController() {
        if !hasSeenOnboarding {
            showOnboarding()
        } else {
            showMain()
        }
    }

    func showOnboarding() {
        let onboardingVC = builder.buildOnboardingModule(router: self)
        onboardingVC.modalPresentationStyle = .fullScreen
        navigationController?.viewControllers = [onboardingVC]
    }

    func showPaywall() {
        let paywallVC = builder.buildPaywallModule(router: self)
        paywallVC.modalPresentationStyle = .fullScreen
        navigationController?.viewControllers = [paywallVC]
    }

    func showMain() {
        let mainVC = builder.buildMainModule(router: self)
        mainVC.modalPresentationStyle = .fullScreen
        navigationController?.viewControllers = [mainVC]
    }

    func showSettings() {
        let settingsVC = builder.buildSettingsModule(router: self)
        settingsVC.modalPresentationStyle = .fullScreen
        navigationController?.present(settingsVC, animated: true)
    }

    func showChatAI() {
        let chatVC = builder.buildChatModule(router: self)
        chatVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(chatVC, animated: true)
    }

    func showHistoryChats() {
        let historyVC = builder.buildChatAiHistory(router: self)
        historyVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(historyVC, animated: true)
    }

    func showTemplates() {
        let templatesVC = builder.buildTemplatesModule(router: self)
        templatesVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(templatesVC, animated: true)
    }

    func showEditor(_ templates: [Template]) {
        let editorVC = builder.buildEditorModule(router: self, templates: templates)
        editorVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(editorVC, animated: true)
    }

    func showVideoResult(_ params: VideoParams) {
        let videoVC = builder.buildVideoResultModule(router: self, params: params)
        videoVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(videoVC, animated: true)
    }

    func dismiss() {
        navigationController?.dismiss(animated: true)
    }

    func pop() {
        navigationController?.popViewController(animated: true)
    }
}
