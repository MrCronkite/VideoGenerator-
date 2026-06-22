//
//  ChatViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol ChatDelegate: AnyObject {

    func showOnboarding(action: ActionType)
    func sendMessage(_ message: String)
}


final class ChatViewController: UIViewController {

    private var messages: [ChatMessage] = []
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChatMessage>!
    private var isTyping = false
    private var isSending = false

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeLayout()
        )

        cv.backgroundColor = .clear
        cv.keyboardDismissMode = .interactive
        cv.alwaysBounceVertical = true
        cv.delegate = self
        return cv
    }()

    let chatInputView = ChatInputView()

    private var inputViewBottom: NSLayoutConstraint!

    weak var delegate: ChatDelegate?

    var isEmptyChat: Bool {
        messages.isEmpty
    }

    // MARK: — Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        setupKeyboard()
        setupDismissKeyboardGesture()

        chatInputView.onSend = { [weak self] text in
            self?.handleSend(text)
        }
    }

    // MARK: — Layout

    private func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(120)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 2
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 16, leading: 0, bottom: 16, trailing: 0
                )
                return section
            },
            configuration: config
        )
    }

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubviews(
            collectionView,
            chatInputView
        )

        inputViewBottom = chatInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        view.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: chatInputView.topAnchor),

            chatInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            inputViewBottom,
        ])
    }

    // MARK: — Dismiss keyboard on tap outside

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // не блокирует тапы по ячейкам/кнопкам под жестом
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: — DataSource

    private func setupDataSource() {
        collectionView.register(
            IncomingMessageCell.self,
            forCellWithReuseIdentifier: IncomingMessageCell.reuseId
        )
        collectionView.register(
            OutgoingMessageCell.self,
            forCellWithReuseIdentifier: OutgoingMessageCell.reuseId
        )
        collectionView.register(
            TypingIndicatorCell.self,
            forCellWithReuseIdentifier: TypingIndicatorCell.reuseId
        )
        collectionView.register(
            ActionGridCell.self,
            forCellWithReuseIdentifier: ActionGridCell.reuseId
        )
        collectionView.register(
            NumberedListCell.self,
            forCellWithReuseIdentifier: NumberedListCell.reuseId
        )
        collectionView.register(
            MediaImageCell.self,
            forCellWithReuseIdentifier: MediaImageCell.reuseId
        )

        dataSource = UICollectionViewDiffableDataSource<Int, ChatMessage>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, message: ChatMessage) -> UICollectionViewCell? in

            let type = self.cellType(for: message)

            let cell = collectionView.dequeue(type, for: indexPath)

            if let configurable = cell as? any ConfigurableCell {
                configurable.configure(with: message)
            }

            if let greedCell = cell as? ActionGridCell {
                greedCell.delegate = self
            }

            return cell
        }
    }

    private func cellType(for message: ChatMessage) -> UICollectionViewCell.Type {
        switch message.type {
        case .incoming:
            return IncomingMessageCell.self
        case .outgoing:
            return OutgoingMessageCell.self
        case .typing:
            return TypingIndicatorCell.self
        case .actionGrid:
            return ActionGridCell.self
        case .list:
            return NumberedListCell.self
        case .media:
            return MediaImageCell.self
        }
    }

    private func handleSend(_ text: String) {
        guard !isSending else { return }
        isSending = true
        chatInputView.setSendEnabled(false)

        let outgoing = ChatMessage(text: text, type: .outgoing)
        appendMessage(outgoing)
        delegate?.sendMessage(text)
        showTyping()
    }

    func showReply(for message: String) {
        hideTyping()
        unlockSending()

        appendMessage(ChatMessage(
            text: message,
            type: .incoming
        ))
    }

    func unlockSending() {
        isSending = false
        chatInputView.setSendEnabled(true)
    }

    func appendMessage(_ message: ChatMessage) {
        messages.append(message)
        applySnapshot()
        scrollToBottom()
    }

    func showTyping() {
        guard !isTyping else { return }
        isTyping = true
        let typing = ChatMessage(text: "", type: .typing)
        messages.append(typing)
        applySnapshot()
        scrollToBottom()
    }

    func hideTyping() {
        isTyping = false
        messages.removeAll { $0.type == .typing }
        applySnapshot()
    }

    func showHistory(messagesResponse: [Messages]) {
        messages.removeAll()
        messagesResponse.forEach {
            if $0.role == "user" {
                messages.append(.init(text: $0.content, type: .outgoing))
            } else {
                messages.append(.init(text: $0.content, type: .incoming))
            }
        }

        applySnapshot()
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChatMessage>()
        snapshot.appendSections([0])
        snapshot.appendItems(messages)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let lastIndex = IndexPath(item: messages.count - 1, section: 0)

        DispatchQueue.main.async {
            self.collectionView.scrollToItem(
                at: lastIndex,
                at: .bottom,
                animated: true
            )
        }
    }

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        inputViewBottom.constant = -keyboardFrame.height
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        scrollToBottom()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        inputViewBottom.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let typingCell = cell as? TypingIndicatorCell {
            typingCell.startAnimating()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let typingCell = cell as? TypingIndicatorCell {
            typingCell.stopAnimating()
        }
    }
}

extension ChatViewController: ActionGridDelegate {
    func didSelect(action: ActionType) {
        delegate?.showOnboarding(action: action)
    }
}
