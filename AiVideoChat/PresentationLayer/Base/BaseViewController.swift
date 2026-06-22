//
//  BaseViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

class BaseController: UIViewController {

   private let loadingView = LoadingView()
   private let imageView = UIImageView(image: R.Images.elipse)
   private let alertView = CustomAlertView()
   private let infoView = InfoOverlayView()
   private let generatingView = GeneratingView()


    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingView()

        setupView()
        addConstraintViews()
        configureAppearance()
        setupBehavior()
        createAlertView()
        createGeneratingView()
        createInfoView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = .init(x: 0, y: 0, width: view.bounds.width, height: 250)
        imageView.contentMode = .scaleToFill
        imageView.layer.zPosition = -1
        view.addSubviews(imageView)
    }
}

@objc extension BaseController {
    private func createLoadingView() {
        loadingView.frame = view.bounds
        loadingView.layer.zPosition = 100
        view.addSubview(loadingView)
    }

    private func createAlertView() {
        alertView.frame = view.bounds
        alertView.layer.zPosition = 100
        view.addSubview(alertView)
    }

    private func createGeneratingView() {
        generatingView.frame = view.bounds
        generatingView.layer.zPosition = 100
        generatingView.backgroundColor = R.Colors.bgColor
        generatingView.alpha = 0
        view.addSubview(generatingView)
    }

    private func createInfoView() {
        infoView.frame = view.bounds
        infoView.layer.zPosition = 100
        infoView.backgroundColor = R.Colors.bgColor.withAlphaComponent(0.3)
        infoView.alpha = 0
        view.addSubview(infoView)
    }

    func showGenerating() {
        generatingView.alpha = 1
    }

    func hideGenerating() {
        generatingView.alpha = 0
    }

    func showLoadingIndicator() {
        loadingView.start()
    }

    func hideLoadingIndicator() {
        loadingView.finish()
    }

    func hideHeaderGradient() {
        imageView.isHidden = true
    }

    func showAlert(message: String) {
        alertView.show(
            in: view,
            message: message,
            onConfirm: { }
        )
    }

    func showInfo(message: String) {
        infoView.show(
            in: view,
            icon: R.Images.iconCheck,
            text: message
        )

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3,
            execute: {
                self.infoView.hide()
            }
        )
    }

    func setupView() {}

    func addConstraintViews() {}

    func configureAppearance() {
        view.backgroundColor = R.Colors.bgColor

        navigationController?.navigationBar.barStyle = .black
    }

    func setupBehavior() {}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

