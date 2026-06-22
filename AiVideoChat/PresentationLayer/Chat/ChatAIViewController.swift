//
//  ChatAIViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit

protocol ChatProtocol: AnyObject {
   func showAnswer(text: String)
   func reloadView(messages: [Messages])
   func showError(_ text: String)
}

final class ChatAIViewController: BaseController, ChatProtocol {

    var presenter: ChatAIPresenter!

    private let chatVC = ChatViewController()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Colors.darkBrown
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Images.iconChat
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Chat"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let label = UILabel()
        label.text = formatter.string(from: Date())
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.5)
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Images.arrowPop, for: .normal)
        return button
    }()

    private let historyButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Images.iconHistory, for: .normal)
        return button
    }()

    private let previewView = UIView()

    private let previewLabel: UILabel = {
        let label = UILabel()
        label.text = "Your AI assistant for anything"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let previewSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask questions, get answers, and explore ideas in seconds"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.5)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
    }
}

extension ChatAIViewController {

    override func setupView() {
        super.setupView()

        addChild(chatVC)

        previewView.addSubviews(
            previewLabel,
            previewSubLabel
        )

        headerView.addSubviews(
            iconImageView,
            titleLabel,
            subtitleLabel,
            backButton,
            historyButton
        )

        view.addSubviews(
            headerView,
            previewView,
            chatVC.view
        )

        chatVC.didMove(toParent: self)
        chatVC.delegate = self
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        view.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 118),

            chatVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            chatVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -22),

            iconImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 32),
            iconImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -28),

            subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),

            historyButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            historyButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            previewView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 135),

            previewLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
            previewLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
            previewLabel.topAnchor.constraint(equalTo: previewView.topAnchor),

            previewSubLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
            previewSubLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
            previewSubLabel.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 10),
            previewSubLabel.bottomAnchor.constraint(equalTo: previewView.bottomAnchor)
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()

        hideHeaderGradient()
    }

    override func setupBehavior() {
        super.setupBehavior()

        backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        historyButton.addTarget(
            self,
            action: #selector(showHistory),
            for: .touchUpInside
        )
    }

    @objc
    private func backButtonTapped() {
        presenter.goToBack()
    }

    @objc
    private func showHistory() {
        presenter.showHistory()
    }

    func showAnswer(text: String) {
        chatVC.showReply(for: text)
    }

    func reloadView(messages: [Messages]) {
        hideLoadingIndicator()
        guard !messages.isEmpty else { return }
        previewView.isHidden = true
        chatVC.showHistory(messagesResponse: messages)
    }

    func showError(_ text: String) {
        hideLoadingIndicator()
        showAlert(message: text)
    }
}

extension ChatAIViewController: ChatDelegate {
    func sendMessage(_ message: String) {
        previewView.isHidden = true
        presenter.sendMessage(message)
    }

    func showOnboarding(action: ActionType) { }
}
