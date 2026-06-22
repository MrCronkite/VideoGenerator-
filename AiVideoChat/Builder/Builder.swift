//
//  Builder.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol BuilderProtocol {
    func buildPaywallModule(router: AppRouterProtocol) -> UIViewController
    func buildOnboardingModule(router: AppRouterProtocol) -> UIViewController

    func buildMainModule(router: AppRouterProtocol) -> UIViewController
    func buildSettingsModule(router: AppRouterProtocol) -> UIViewController
    func buildChatModule(router: AppRouterProtocol) -> UIViewController
    func buildChatAiHistory(router: AppRouterProtocol) -> UIViewController

    func buildTemplatesModule(router: AppRouterProtocol) -> UIViewController
    func buildEditorModule(router: AppRouterProtocol, templates: [Template]) -> UIViewController
    func buildVideoResultModule(router: AppRouterProtocol, params: VideoParams) -> UIViewController
}


final class ModuleBuilder: BuilderProtocol {

    @MainActor
    func buildPaywallModule(router: AppRouterProtocol) -> UIViewController {
        let view = PaywallViewController()
        let pm = PurchaseManager()
        let presenter = PaywallPresenterImpl(
            view: view,
            router: router,
            purchaseManager: pm
        )
        view.presenter = presenter
        return view
    }

    func buildOnboardingModule(router: AppRouterProtocol) -> UIViewController {
        let view = OnboardingViewController()
        let presenter = OnboardingPresenterImpl(
            view: view,
            router: router
        )
        view.presenter = presenter
        return view
    }

    func buildMainModule(router: AppRouterProtocol) -> UIViewController {
        let view = MainViewController()
        let presenter = MainPresenterImpl(
            view: view,
            router: router
        )
        view.presenter = presenter
        return view
    }

    func buildSettingsModule(router: AppRouterProtocol) -> UIViewController {
        let view = SettingsViewController()
        let presenter = SettingsPresenterImpl(
            view: view,
            router: router
        )
        view.presenter = presenter
        return view
    }

    func buildChatModule(router: AppRouterProtocol) -> UIViewController {
        let view = ChatAIViewController()
        let networkService = NetworkService()
        let presenter = ChatAIPresenterImpl(
            view: view,
            router: router,
            networkService: networkService
        )
        view.presenter = presenter
        return view
    }

    @MainActor
    func buildChatAiHistory(router: AppRouterProtocol) -> UIViewController {
        let view = HistoryChatViewController()
        let networkService = NetworkService()
        let presenter = HistoryChatPresenterImpl(
            view: view,
            router: router,
            networkService: networkService
        )
        view.presenter = presenter
        return view
    }

    @MainActor
    func buildTemplatesModule(router: AppRouterProtocol) -> UIViewController {
        let view = TemplatesViewController()
        let networkService = NetworkService()
        let presenter = TemplatesPresenterImpl(
            view: view,
            router: router,
            networkService: networkService
        )
        view.presenter = presenter
        return view
    }

    @MainActor
    func buildEditorModule(
        router: AppRouterProtocol,
        templates: [Template]
    ) -> UIViewController {
        let view = EditorViewController()
        let presenter = EditorPresenterImpl(
            view: view,
            router: router,
            templates: templates
        )
        view.presenter = presenter
        return view
    }

    @MainActor
    func buildVideoResultModule(
        router: AppRouterProtocol,
        params: VideoParams
    ) -> UIViewController {
        let view = VideoResultViewController()
        let networkService = NetworkService()
        let presenter = VideoResultPresenterImpl(
            view: view,
            router: router,
            params: params,
            networkService: networkService
        )
        view.presenter = presenter
        return view
    }
}
