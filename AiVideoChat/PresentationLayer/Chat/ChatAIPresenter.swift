//
//  ChatAIPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import Foundation

protocol ChatAIPresenter: AnyObject {
    func goToBack()

    func loadingChat()
    func sendMessage(_ message: String)
    func showHistory()
}

final class ChatAIPresenterImpl: ChatAIPresenter {
    weak var view: ChatAIViewController?
    private var router: AppRouterProtocol
    private var networkService: NetworkServiceProtocol
    private var chatID: String

    init(
        view: ChatAIViewController,
        router: AppRouterProtocol,
        networkService: NetworkServiceProtocol,
        chatID: String = UUID().uuidString
    ) {
        self.view = view
        self.router = router
        self.networkService = networkService
        self.chatID = chatID

        loadingChat()
    }

    func sendMessage(_ message: String) {
        Task { @MainActor in
            do {
                let response = try await networkService.sendMessage(
                    text: message,
                    chatId: chatID
                )
                view?.showAnswer(text: response.assistantMessage)
            } catch {

            }
        }
    }

    func goToBack() {
        router.pop()
    }

    func showHistory() {
        router.onChatSelected = { [weak self] id in
            guard let self else { return }
            view?.showLoadingIndicator()
            chatID = id
            self.loadingChat()
        }

        router.showHistoryChats()
    }

    func loadingChat() {
        Task { @MainActor in
            do {
                let response = try await networkService.getMessages(chatID: chatID)
                view?.reloadView(messages: response)
            } catch {
                view?.showError(error.localizedDescription)
            }
        }
    }
}
