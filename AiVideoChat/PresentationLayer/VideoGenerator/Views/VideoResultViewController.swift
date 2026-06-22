//
//  VideoResultViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit
import Lottie
import AVFoundation
import Photos

protocol VideoResultViewProtocol: AnyObject {
    func loadVideo(url: URL)
    func showError(_ text: String)
    func setDownloadButtonLoading(_ isLoading: Bool)
    func showSavedConfirmation()
}

final class VideoResultViewController: BaseController, VideoResultViewProtocol {

    var presenter: VideoResultPresenter!

    private let playerLayer = AVPlayerLayer()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Images.arrowPop, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Result"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.zPosition = -1
        return label
    }()

    private let videoView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = R.Colors.darkBrown
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 24
        return button
    }()

    private let downloadButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Download"
        config.imagePadding = 8
        config.baseBackgroundColor = .clear
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 16, weight: .semibold)
            return attrs
        }
        button.configuration = config
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    private let reloadButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Replace"
        config.image = R.Images.iconReplace
        config.imagePadding = 8
        config.baseBackgroundColor = .gray.withAlphaComponent(0.3)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 14, weight: .regular)
            return attrs
        }
        button.configuration = config
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        showGenerating()
        presenter.generateVideo()

        hideHeaderGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer.frame = videoView.bounds
        downloadButton.applyHorizontalGradient(
            startColor: R.Colors.blueGradient,
            endColor: R.Colors.pinkGradient
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            VideoPlayerPool.shared.clearAll()
        }
    }

    func loadVideo(url: URL) {
        hideGenerating()
        let player = VideoPlayerPool.shared.player(for: url)
        playerLayer.player = player
        player.play()
    }

    func showError(_ text: String) {
        hideGenerating()
        showAlert(message: text)
        errorLabel.text = text
    }
}

extension VideoResultViewController {
    override func setupView() {

        buttonsStack.addArrangedSubview(shareButton)
        buttonsStack.addArrangedSubview(downloadButton)

        view.addSubviews(
            backButton,
            titleLabel,
            videoView,
            buttonsStack
        )

        videoView.layer.addSublayer(playerLayer)
        videoView.addSubviews(
            errorLabel,
            reloadButton
        )
        playerLayer.videoGravity = .resizeAspectFill
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        view.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            videoView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -20),

            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 52),

            errorLabel.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: videoView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: -16),

            reloadButton.topAnchor.constraint(equalTo: videoView.topAnchor, constant: 16),
            reloadButton.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: -16)
        ])
    }

    override func setupBehavior() {
        super.setupBehavior()

        shareButton.addTarget(
            self,
            action: #selector(shareTapped),
            for: .touchUpInside
        )

        downloadButton.addTarget(
            self,
            action: #selector(downloadTapped),
            for: .touchUpInside
        )

        backButton.addTarget(
            self,
            action: #selector(goToBack),
            for: .touchUpInside
        )

        reloadButton.addTarget(
            self,
            action: #selector(reloadGeneratingVideo),
            for: .touchUpInside
        )
    }

    @objc
    private func reloadGeneratingVideo() {
        showGenerating()
        presenter.generateVideo()
    }

    @objc
    private func goToBack() {
        presenter.goToBack()
    }


    @objc
    private func shareTapped() {
        guard let url = presenter.currentVideoURL else { return }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }

        present(activityVC, animated: true)
    }

    @objc
    private func downloadTapped() {
        presenter.downloadVideo()
    }

    func setDownloadButtonLoading(_ isLoading: Bool) {
        downloadButton.isEnabled = !isLoading

        guard var config = downloadButton.configuration else { return }

        if isLoading {
            config.showsActivityIndicator = true
            config.title = "Downloading..."
        } else {
            config.showsActivityIndicator = false
            config.title = "Download"
        }

        downloadButton.configuration = config
    }

    func showSavedConfirmation() {
        showInfo(
            message: "Video has been saved to your gallery"
        )
    }
}
