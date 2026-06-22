//
//  OnboardingViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol OnboardingProtocol: AnyObject { }

final class OnboardingViewController: BaseController, OnboardingProtocol {

    var presenter: OnboardingPresenter!

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
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let tryItNowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Try it now", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 24
        b.alpha = 0
        return b
    }()

    private let splashView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .white.withAlphaComponent(0.2)
        iv.layer.cornerRadius = 40
        return iv
    }()

    private let chatVC = ChatViewController()

    private var index: Int = 0
    private var chatMessages: [ChatMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tryItNowButton.applyHorizontalGradient(
            startColor: R.Colors.blueGradient,
            endColor: R.Colors.pinkGradient
        )

        splashView.frame = view.bounds
    }
}

extension OnboardingViewController {

    override func setupView() {
        super.setupView()

        addChild(chatVC)

        view.addSubviews(
            splashView,
            headerView,
            tryItNowButton,
            chatVC.view
        )
        view.bringSubviewToFront(tryItNowButton)
        view.bringSubviewToFront(splashView)

        splashView.addSubviews(imageView)

        headerView.addSubviews(
            iconImageView,
            titleLabel
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

            iconImageView.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 16
            ),

            iconImageView.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -16
            ),

            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 12
            ),

            titleLabel.centerYAnchor.constraint(
                equalTo: iconImageView.centerYAnchor
            ),

            chatVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            chatVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tryItNowButton.heightAnchor.constraint(equalToConstant: 50),
            tryItNowButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            tryItNowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tryItNowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 160),
            imageView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()

        chatVC.chatInputView.isHidden = true
        hideHeaderGradient()
    }

    override func setupBehavior() {
        super.setupBehavior()

        tryItNowButton.addTarget(
            self,
            action: #selector(goToMain),
            for: .touchUpInside
        )
        tryItNowButton.isUserInteractionEnabled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3, animations: {
                    self.splashView.alpha = 0
                }, completion: { _ in
                    self.sendChatMessages()
                })
        }
    }

    @objc
    private func goToMain() {
        presenter.showPaywall()
    }

    private func sendChatMessages() {
        let messages: [ChatMessage] = [
            .init(
                text: "I can help you create almost anything in seconds",
                type: .incoming,
                isFirst: true
            ),
            .init(
                text: "Let's try something simple!",
                type: .incoming
            )
        ]

        let actions = [
            ActionItem(
                type: .talkAI,
                icon: R.Images.iconTalk,
                title: "Talk to AI",
                subtitle: "Ask anything. Get answers fast"
            ),
            ActionItem(
                type: .createVideo,
                icon: R.Images.iconVideo,
                title: "Create videos",
                subtitle: "Pick a template. Done in seconds"
            ),
            ActionItem(
                type: .write,
                icon: R.Images.iconWrite,
                title: "Write like a pro",
                subtitle: "Rewrite and improve your text"
            ),
            ActionItem(
                type: .understand,
                icon: R.Images.iconUnderstand,
                title: "Understand faster",
                subtitle: "Simplify complex info instantly"
            )
        ]

        let gridMessage = ChatMessage(
            text: "What do you want to create?",
            type: .actionGrid,
            actions: actions
        )

        chatMessages = messages + [gridMessage]
        showMessageSequence()
    }

    private func showMessageSequence() {
        guard index < chatMessages.count else { return }

        guard chatMessages[index].type != .outgoing else {
            chatVC.appendMessage(chatMessages[index])
            index += 1
            showMessageSequence()
            return
        }

        chatVC.showTyping()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }

            chatVC.hideTyping()
            chatVC.appendMessage(chatMessages[index])
            index += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.showMessageSequence()
            }
        }
    }

    private func showTalkAi() {
        let messages: [ChatMessage] = [
            .init(text: "Hi! I’d like to chat with AI and ask anything", type: .outgoing),
            .init(text: "Nice! Let me show you how it works", type: .incoming),
            .init(text: "Give me 5 ideas for a birthday surprise", type: .outgoing),

                .init(text: "Here are 5 fun birthday surprise ideas", type: .list, list: [
                    "Plan a surprise party with close friends",
                    "Organize a “memory lane” day with meaningful places",
                    "Create a personalized video from friends & family",
                    "Set up a surprise trip or weekend getaway",
                    "Prepare a themed dinner based on their favorite movie or cuisine"
                ]),

                .init(text: "See how easy that was? \nNow try it yourself", type: .incoming)
        ]

        chatMessages += messages

        showMessageSequence()
    }

    private func showCreateVideo() {
        let messages: [ChatMessage] = [
            .init(text: "Hi! I want to turn my ideas into videos", type: .outgoing),
            .init(text: "Nice! Let me show you how it works", type: .incoming),
            .init(text: "Man with a sports car, explosion behind, cinematic, slow motion, realistic, 4K", type: .outgoing),
            .init(text: "", type: .media, image: R.Images.iconMedia),
            .init(text: "See how easy that was? \nNow try it yourself", type: .incoming)
        ]

        chatMessages += messages

        showMessageSequence()
    }

    private func showWrite() {
        let messages: [ChatMessage] = [
            .init(text: "Hi! I want to fix and improve my text", type: .outgoing),
            .init(text: "Nice! Let me show you how it works", type: .incoming),
            .init(text: """
                  Rewrite this message to sound more professional
                  
                  Hey, can you send me the report asap? I kinda need it now because I have a meeting soon and don’t really have time to wait, so please send it as fast as you can
                  """, type: .outgoing),

                .init(text: """
                  Here’s your improved version
                  
                  Hi, could you please share the report at your earliest convenience?I have a meeting coming up and would really appreciate it.
                  """, type: .incoming),

                .init(text: "See how easy that was? \nNow try it yourself", type: .incoming)

        ]

        chatMessages += messages

        showMessageSequence()
    }

    private func showUnderstand() {
        let messages: [ChatMessage] = [
            .init(text: "Hi! I want to understand things faster", type: .outgoing),
            .init(text: "Nice! Let me show you how it works", type: .incoming),
            .init(text: """
                  Summarize this into key points
                 
                  In order to improve overall productivity and ensure successful project delivery, it is essential for all team members to prioritize their tasks effectively, maintain clear and consistent communication, and proactively address any возникающие issues. Failure to do so may result in delays, misalignment between teams, and reduced efficiency across the workflow.
                 """, type: .outgoing),

                .init(text: "Here are the key points ", type: .list, list: [
                    "Prioritize your tasks",
                    "Communicate clearly with the team",
                    "Solve issues early to avoid delays"
                ]),

                .init(text: "See how easy that was? \nNow try it yourself", type: .incoming)
        ]

        chatMessages += messages

        showMessageSequence()
    }
}

extension OnboardingViewController: ChatDelegate {
    func sendMessage(_ message: String) {}

    func showOnboarding(action: ActionType) {
        switch action {
        case .talkAI: showTalkAi()
        case .createVideo: showCreateVideo()
        case .write: showWrite()
        case .understand: showUnderstand()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(withDuration: 0.5) {
                self.tryItNowButton.alpha = 1
            }
        }
    }
}
