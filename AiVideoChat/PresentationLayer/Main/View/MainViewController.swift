//
//  MainViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit
import Lottie

protocol MainViewProtocol: AnyObject {

}


final class MainViewController: BaseController, MainViewProtocol {

    var presenter: MainPresenter!

    private let buttonSettings: UIButton = {
        let b = UIButton()
        b.setImage(R.Images.mainSettings, for: .normal)
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your AI tools, \nready to go"
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = R.Images.mainIcon
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let askedView: UIView = {
        let v = UIView()
        v.backgroundColor = R.Colors.darkBrown
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1.5
        return v
    }()

    private let askedImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = R.Images.mainAsk
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let askedLabel: UILabel = {
        let l = UILabel()
        l.text = " Ask anything"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white.withAlphaComponent(0.5)
        return l
    }()

    private let gradientBorderLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [R.Colors.blueGradient.cgColor, R.Colors.pinkGradient.cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 24
        return g
    }()

    private let gradientBorderMask: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.5
        return layer
    }()

    private let intoVideoView = UIView()

    private let intoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = R.Images.mainBg
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let iconVideo: UIImageView = {
        let iv = UIImageView()
        iv.image = R.Images.mainVideo
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let videoTitle: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.numberOfLines = 0
        l.text = "Turn Photo \ninto Video"
        return l
    }()

    private let videoSubtitle: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.numberOfLines = 0
        l.text = "Animate * Templates"
        return l
    }()

    private let readyView: UIView = {
        let v = UIView()
        v.backgroundColor = .white.withAlphaComponent(0.5)
        v.layer.cornerRadius = 16
        return v
    }()

    private let readyTitle: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.numberOfLines = 0
        l.text = "Ready in seconds"
        return l
    }()

    private let iconReady: UIImageView = {
        let iv = UIImageView()
        iv.image = R.Images.mainPlay
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let imageGeneratorView = FeatureCardView(
        icon: R.Images.mainSiri,
        title: "Fix & Improve \nWriting",
        subtitle: "Rewrite * Fix grammar"
    )

    private let storyView = FeatureCardView(
        icon: R.Images.mainText,
        title: "Understand \nFaster",
        subtitle: "Summarize * Key points"
    )

    private let rightColumnStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let cardsRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientBorderLayer.frame = askedView.bounds
        gradientBorderMask.frame = askedView.bounds

        gradientBorderMask.path = UIBezierPath(
            roundedRect: askedView.bounds.insetBy(dx: 1.75, dy: 1.75),
            cornerRadius: 24
        ).cgPath

        gradientBorderLayer.mask = gradientBorderMask

        if gradientBorderLayer.superlayer == nil {
            askedView.layer.addSublayer(gradientBorderLayer)
        }
    }
}

extension MainViewController {

    override func setupView() {
        super.setupView()

        askedView.addSubviews(
            askedImageView,
            askedLabel
        )

        intoVideoView.addSubviews(
            intoImageView
        )

        intoVideoView.addSubviews(
            iconVideo,
            videoTitle,
            videoSubtitle,
            readyView
        )

        readyView.addSubviews(
            readyTitle,
            iconReady
        )

        rightColumnStack.addArrangedSubview(imageGeneratorView)
        rightColumnStack.addArrangedSubview(storyView)

        cardsRowStack.addArrangedSubview(intoVideoView)
        cardsRowStack.addArrangedSubview(rightColumnStack)

        view.addSubviews(
            buttonSettings,
            titleLabel,
            imageView,
            askedView,
            cardsRowStack
        )
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        view.activate([
            buttonSettings.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonSettings.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            buttonSettings.widthAnchor.constraint(equalToConstant: 40),
            buttonSettings.heightAnchor.constraint(equalToConstant: 40),

            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 46),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            askedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            askedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            askedView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            askedView.heightAnchor.constraint(equalToConstant: 56),

            askedImageView.widthAnchor.constraint(equalToConstant: 24),
            askedImageView.leadingAnchor.constraint(equalTo: askedView.leadingAnchor, constant: 16),
            askedImageView.centerYAnchor.constraint(equalTo: askedView.centerYAnchor),

            askedLabel.leadingAnchor.constraint(equalTo: askedImageView.trailingAnchor, constant: 12),
            askedLabel.centerYAnchor.constraint(equalTo: askedView.centerYAnchor),

            cardsRowStack.topAnchor.constraint(equalTo: askedView.bottomAnchor, constant: 40),
            cardsRowStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardsRowStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            intoImageView.leadingAnchor.constraint(equalTo: intoVideoView.leadingAnchor),
            intoImageView.topAnchor.constraint(equalTo: intoVideoView.topAnchor),
            intoImageView.trailingAnchor.constraint(equalTo: intoVideoView.trailingAnchor),
            intoImageView.bottomAnchor.constraint(equalTo: intoVideoView.bottomAnchor),

            iconVideo.leadingAnchor.constraint(equalTo: intoVideoView.leadingAnchor, constant: 16),
            iconVideo.topAnchor.constraint(equalTo: intoVideoView.topAnchor, constant: 24),
            iconVideo.heightAnchor.constraint(equalToConstant: 36),

            videoTitle.leadingAnchor.constraint(equalTo: intoVideoView.leadingAnchor, constant: 16),
            videoTitle.trailingAnchor.constraint(equalTo: intoVideoView.trailingAnchor, constant: -16),
            videoTitle.topAnchor.constraint(equalTo: intoVideoView.topAnchor, constant: 72),

            videoSubtitle.leadingAnchor.constraint(equalTo: intoVideoView.leadingAnchor, constant: 16),
            videoSubtitle.trailingAnchor.constraint(equalTo: intoVideoView.trailingAnchor, constant: -16),
            videoSubtitle.topAnchor.constraint(equalTo: intoVideoView.topAnchor, constant: 132),

            readyView.widthAnchor.constraint(equalToConstant: 149),
            readyView.heightAnchor.constraint(equalToConstant: 32),
            readyView.centerXAnchor.constraint(equalTo: intoVideoView.centerXAnchor),
            readyView.bottomAnchor.constraint(equalTo: intoVideoView.bottomAnchor, constant: -16),

            readyTitle.centerYAnchor.constraint(equalTo: readyView.centerYAnchor),
            readyTitle.leadingAnchor.constraint(equalTo: readyView.leadingAnchor, constant: 12),

            iconReady.centerYAnchor.constraint(equalTo: readyView.centerYAnchor),
            iconReady.trailingAnchor.constraint(equalTo: readyView.trailingAnchor, constant: -12),
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()
    }

    override func setupBehavior() {
        super.setupBehavior()

        buttonSettings.addTarget(
            self,
            action: #selector(openSettings),
            for: .touchUpInside
        )

        let tapChat = UITapGestureRecognizer(
            target: self,
            action: #selector(openAIChat)
        )
        askedView.addGestureRecognizer(tapChat)

        let tapVideo = UITapGestureRecognizer(
            target: self,
            action: #selector(openVideoGen)
        )
        intoVideoView.addGestureRecognizer(tapVideo)

        let tapImageGen = UITapGestureRecognizer(
            target: self,
            action: #selector(openAIChat)
        )
        let tapStory = UITapGestureRecognizer(
            target: self,
            action: #selector(openAIChat)
        )
        imageGeneratorView.addGestureRecognizer(tapImageGen)
        storyView.addGestureRecognizer(tapStory)
    }

    @objc
    private func openSettings() {
      //  presenter.showSettings()
    }

    @objc
    private func openVideoGen() {
        presenter.openTemplates()
    }

    @objc
    private func openAIChat() {
        presenter.openAIChat()
    }
}
