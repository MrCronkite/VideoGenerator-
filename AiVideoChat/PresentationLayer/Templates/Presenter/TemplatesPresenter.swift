//
//  TemplatesPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit

protocol TemplatesPresenter: AnyObject {
    func loadTemplates()
    func openEditor(with template: [Template], selected: Template)
    func goToBack()
}


final class TemplatesPresenterImpl: TemplatesPresenter {

    weak var view: TemplatesViewProtocol?
    private var router: AppRouterProtocol
    private var networkService: NetworkServiceProtocol

    init(
        view: TemplatesViewProtocol,
        router: AppRouterProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.view = view
        self.router = router
        self.networkService = networkService
    }

    func loadTemplates() {
        Task { @MainActor in
            do {
                let response = try await networkService.getTemplates()
                view?.showTemplates(response.templates)
            } catch {
                view?.showError(error.localizedDescription)
            }
        }
    }

    func goToBack() {
        router.pop()
    }

    func openEditor(with templates: [Template], selected: Template) {
        router.showEditor(templates)
    }
}
