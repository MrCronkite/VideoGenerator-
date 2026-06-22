//
//  ChatInputView.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit


final class ChatInputView: BaseView {

    var onSend: ((String) -> Void)?

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .white
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 4, bottom: 10, right: 4)
        tv.keyboardAppearance = .dark
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "How can I help you?"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .white.withAlphaComponent(0.5)
        return l
    }()

    private let sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(R.Images.iconSend, for: .normal)
        b.tintColor = .white
        return b
    }()

    private var textViewHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        textView.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }
}

extension ChatInputView {

    override func setupView() {
        super.setupView()

        addSubviews(containerView)
        containerView.addSubviews(
            textView,
            placeholderLabel,
            sendButton
        )
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 40)

        activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),

            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textViewHeightConstraint,

            placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = R.Colors.darkBrown

        sendButton.addTarget(
            self,
            action: #selector(sendTapped),
            for: .touchUpInside
        )

        layer.cornerRadius = 24
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
    }

    @objc
    private func sendTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onSend?(text)
        textView.text = ""
        placeholderLabel.isHidden = false
        updateHeight()
    }

    private func updateHeight() {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        let newHeight = min(max(size.height, 40), 120)
        textViewHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
    }

    func setSendEnabled(_ enabled: Bool) {
        sendButton.isEnabled = enabled
        sendButton.alpha = enabled ? 1.0 : 0.5
    }
}

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateHeight()
    }
}
