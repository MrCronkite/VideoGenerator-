//
//  EditorViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit
import PhotosUI

protocol EditorViewProtocol: AnyObject {

}


final class EditorViewController: BaseController, EditorViewProtocol {

    var presenter: EditorPresenter!

    private var selectedTemplateIndex = 0

    private let formatOptions = ["16:9", "9:16", "1:1"]
    private let qualityOptions = ["540p", "720p", "1080p", "4K"]

    private var activeDropdown: DropdownMenuView?

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Images.arrowPop, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Editor"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 311, height: 311)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 12

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        return collection
    }()

    private let imageContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
       // view.clipsToBounds = true
        return view
    }()

    private let imageContainerGradientBorder: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            R.Colors.blueGradient.cgColor,
            R.Colors.pinkGradient.cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let imageContainerBorderMask: CAShapeLayer = {
        let mask = CAShapeLayer()
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = 1
        return mask
    }()

    private let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.layer.zPosition = 99
        return imageView
    }()

    private let plusImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "plus"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()

    private var removeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.Images.iconCross, for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.layer.zPosition = 100
        return button
    }()

    private let formatView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Colors.darkBrown
        view.layer.cornerRadius = 16
        return view
    }()

    private let qualityView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Colors.darkBrown
        view.layer.cornerRadius = 16
        return view
    }()

    private let formatLabel: UILabel = {
        let label = UILabel()
        label.text = "Format"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()

    private let qualityLabel: UILabel = {
        let label = UILabel()
        label.text = "Quality"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()

    private let formatValueLabel: UILabel = {
        let label = UILabel()
        label.text = "16:9"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()

    private let qualityValueLabel: UILabel = {
        let label = UILabel()
        label.text = "1080p"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()

    private var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let first = presenter.templates.first {
            titleLabel.text = first.name
        }

        updateCreateButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        createButton.applyHorizontalGradient(
            startColor: R.Colors.blueGradient,
            endColor: R.Colors.pinkGradient
        )

        imageContainerGradientBorder.frame = imageContainerView.bounds
        imageContainerBorderMask.frame = imageContainerView.bounds
        imageContainerBorderMask.path = UIBezierPath(
            roundedRect: imageContainerView.bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 16
        ).cgPath
    }
}

extension EditorViewController {

    override func setupView() {
        super.setupView()
        collectionView.register(
            PreviewCell.self,
            forCellWithReuseIdentifier: PreviewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubviews(
            backButton,
            titleLabel,
            collectionView,
            imageContainerView,
            formatView,
            qualityView,
            createButton
        )

        imageContainerView.addSubviews(
            selectedImageView,
            plusImageView,
            addPhotoButton,
            removeImageButton
        )

        formatView.addSubviews(formatLabel, formatValueLabel)
        qualityView.addSubviews(qualityLabel, qualityValueLabel)

        imageContainerView.layer.addSublayer(imageContainerGradientBorder)
        imageContainerGradientBorder.mask = imageContainerBorderMask
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        view.activate([

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 311),

            imageContainerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
            imageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageContainerView.widthAnchor.constraint(equalToConstant: 100),
            imageContainerView.heightAnchor.constraint(equalToConstant: 100),

            selectedImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            selectedImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            selectedImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            selectedImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),

            plusImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            plusImageView.widthAnchor.constraint(equalToConstant: 24),
            plusImageView.heightAnchor.constraint(equalToConstant: 24),

            addPhotoButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            addPhotoButton.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            addPhotoButton.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            addPhotoButton.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),

            removeImageButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: -4),
            removeImageButton.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 4),

            formatView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 24),
            formatView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            formatView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            formatView.heightAnchor.constraint(equalToConstant: 60),

            qualityView.topAnchor.constraint(equalTo: formatView.bottomAnchor, constant: 8),
            qualityView.leadingAnchor.constraint(equalTo: formatView.leadingAnchor),
            qualityView.trailingAnchor.constraint(equalTo: formatView.trailingAnchor),
            qualityView.heightAnchor.constraint(equalToConstant: 60),

            formatLabel.centerYAnchor.constraint(equalTo: formatView.centerYAnchor),
            formatLabel.leadingAnchor.constraint(equalTo: formatView.leadingAnchor, constant: 16),

            qualityLabel.centerYAnchor.constraint(equalTo: qualityView.centerYAnchor),
            qualityLabel.leadingAnchor.constraint(equalTo: qualityView.leadingAnchor, constant: 16),

            qualityValueLabel.centerYAnchor.constraint(equalTo: qualityView.centerYAnchor),
            qualityValueLabel.trailingAnchor.constraint(equalTo: qualityView.trailingAnchor, constant: -16),

            formatValueLabel.centerYAnchor.constraint(equalTo: formatView.centerYAnchor),
            formatValueLabel.trailingAnchor.constraint(equalTo: formatView.trailingAnchor, constant: -16),

            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56)
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
            action: #selector(backTapped),
            for: .touchUpInside
        )

        removeImageButton.addTarget(
            self,
            action: #selector(removeImageTapped),
            for: .touchUpInside
        )

        addPhotoButton.addTarget(
            self,
            action: #selector(addPhotoTapped),
            for: .touchUpInside
        )

        createButton.addTarget(
            self,
            action: #selector(createVideo),
            for: .touchUpInside
        )

        let formatTap = UITapGestureRecognizer(target: self, action: #selector(formatTapped))
        formatView.addGestureRecognizer(formatTap)
        formatView.isUserInteractionEnabled = true

        let qualityTap = UITapGestureRecognizer(target: self, action: #selector(qualityTapped))
        qualityView.addGestureRecognizer(qualityTap)
        qualityView.isUserInteractionEnabled = true
    }

    @objc
    private func createVideo() {
        guard let image = selectedImageView.image else { return }
        presenter.createVideo(
            index: selectedTemplateIndex,
            image: image
        )
    }

    @objc
    private func backTapped() {
        presenter.didTapBack()
    }

    @objc
    private func addPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        present(picker, animated: true)
    }

    @objc
    private func removeImageTapped() {
        selectedImageView.image = nil
        selectedImageView.isHidden = true
        removeImageButton.isHidden = true
        plusImageView.isHidden = false
        updateCreateButtonState()
    }

    // MARK: — Dropdowns

    @objc
    private func formatTapped() {
        toggleDropdown(
            anchor: formatView,
            options: formatOptions,
            selected: formatValueLabel.text
        ) { [weak self] selected in
            self?.formatValueLabel.text = selected
        }
    }

    @objc
    private func qualityTapped() {
        toggleDropdown(
            anchor: qualityView,
            options: qualityOptions,
            selected: qualityValueLabel.text
        ) { [weak self] selected in
            self?.qualityValueLabel.text = selected
        }
    }

    private func toggleDropdown(
        anchor: UIView,
        options: [String],
        selected: String?,
        onSelect: @escaping (String) -> Void
    ) {
        if let existing = activeDropdown {
            existing.dismiss()
            activeDropdown = nil
            return
        }

        let dropdown = DropdownMenuView()
        activeDropdown = dropdown

        dropdown.show(
            in: view,
            anchorView: anchor,
            options: options,
            selected: selected
        ) { [weak self] selectedOption in
            onSelect(selectedOption)
            self?.activeDropdown = nil
        }
    }

    private func updateTitleForVisibleCell() {

        let centerPoint = CGPoint(
            x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
            y: collectionView.bounds.height / 2
        )

        guard let indexPath = collectionView.indexPathForItem(at: centerPoint) else {
            return
        }

        selectedTemplateIndex = indexPath.item

        let template = presenter.templates[indexPath.item]

        titleLabel.text = template.name
    }

    private func updateCreateButtonState() {

        let hasImage = selectedImageView.image != nil

        createButton.isEnabled = hasImage
        createButton.alpha = hasImage ? 1.0 : 0.5
    }
}

extension EditorViewController: UICollectionViewDelegate { }

extension EditorViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitleForVisibleCell()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateTitleForVisibleCell()
        }
    }
}

extension EditorViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        presenter.templates.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PreviewCell.reuseIdentifier,
            for: indexPath
        ) as! PreviewCell

        cell.configure(with: presenter.templates[indexPath.item])

        return cell
    }
}

extension EditorViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in

            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async {

                self?.selectedImageView.image = image
                self?.selectedImageView.isHidden = false

                self?.plusImageView.isHidden = true
                self?.removeImageButton.isHidden = false
                self?.updateCreateButtonState()
            }
        }
    }
}
