//
//  HistoryPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit


protocol HistoryChatPresenter: AnyObject {
    var chats: [ChatInfo] { get }

    func openChat(with id: String?)
    func loadHistory()
    func didTapBack()
}

final class HistoryChatPresenterImpl: HistoryChatPresenter {

    weak var view: HistoryChatProtocol?
    private let router: AppRouterProtocol
    private let networkService: NetworkServiceProtocol

    var chats: [ChatInfo] = []

    init(view: HistoryChatProtocol,
         router: AppRouterProtocol,
         networkService: NetworkServiceProtocol
    ) {
        self.view = view
        self.router = router
        self.networkService = networkService
    }

    func loadHistory() {
        Task { @MainActor in
            do {
                let chats = try await networkService.getChats()
                self.chats = chats
                view?.reloadAndShowHistory()
            } catch {
                view?.showError(error.localizedDescription)
            }
        }
    }

    func openChat(with id: String?) {
        router.pop()

        guard let id else { return}
        router.onChatSelected?(id)
    }

    func didTapBack() {
        router.pop()
    }
}
