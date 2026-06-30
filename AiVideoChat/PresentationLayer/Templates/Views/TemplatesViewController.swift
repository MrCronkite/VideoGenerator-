//
//  TemplatesViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit

protocol TemplatesViewProtocol: AnyObject {
    func showTemplates(_ templates: [Template])
    func showError(_ text: String)
}

@MainActor
final class TemplatesViewController: BaseController, TemplatesViewProtocol {

    var presenter: TemplatesPresenter!

    private var templates: [Template] = []

    private var categories: [String] = []

    private var selectedCategory: String?

    private var filteredTemplates: [Template] {
        guard let selectedCategory else {
            return templates
        }

        return templates.filter {
            $0.category == selectedCategory
        }
    }

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Colors.darkBrown
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Images.iconTemplates
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Video"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
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

    private lazy var categoriesCollectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset.left = 16
        layout.sectionInset.right = 16

        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear

        collection.delegate = self
        collection.dataSource = self

        collection.register(
            CategoryTemplatesCell.self,
            forCellWithReuseIdentifier: CategoryTemplatesCell.reuseIdentifier
        )

        return collection
    }()

    private lazy var templatesCollectionView: UICollectionView = {

        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in

            let item = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .absolute(220)
                )
            )

            item.contentInsets = .init(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(220)
                ),
                subitems: [item, item]
            )

            return NSCollectionLayoutSection(group: group)
        }

        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collection.backgroundColor = .clear

        collection.delegate = self
        collection.dataSource = self

        collection.register(
            TemplateCell.self,
            forCellWithReuseIdentifier: TemplateCell.reuseIdentifier
        )

        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadTemplates()
        showLoadingIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        for cell in templatesCollectionView
            .visibleCells
            .compactMap({ $0 as? TemplateCell })
        {
            cell.resumePlaybackIfNeeded()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        for cell in templatesCollectionView
            .visibleCells
            .compactMap({ $0 as? TemplateCell })
        {
            cell.pausePlayback()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            for cell in templatesCollectionView
                .visibleCells
                .compactMap({ $0 as? TemplateCell })
            {
                cell.cancelPlayback()
            }
        }
    }

    func showTemplates(_ templates: [Template]) {
        hideLoadingIndicator()

        self.templates = templates

        categories = Array(
            Set(templates.map(\.category))
        ).sorted()

        selectedCategory = categories.first

        categoriesCollectionView.reloadData()
        templatesCollectionView.reloadData()
    }
}

extension TemplatesViewController {

    override func setupView() {
        super.setupView()

        headerView.addSubviews(
            iconImageView,
            titleLabel,
            backButton,
            historyButton
        )

        view.addSubviews(
            headerView,
            categoriesCollectionView,
            templatesCollectionView
        )
    }

    override func addConstraintViews() {
        super.addConstraintViews()

        view.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 118),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -22),

            iconImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 32),
            iconImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            historyButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            historyButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            categoriesCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 36),

            templatesCollectionView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 16),
            templatesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            templatesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            templatesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

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
            action: #selector(goToBack),
            for: .touchUpInside
        )
    }

    @objc
    private func goToBack() {
        presenter.goToBack()
    }

    func showError(_ text: String) {
        showAlert(message: text)
    }
}

extension TemplatesViewController: UICollectionViewDataSource {

    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        collectionView == categoriesCollectionView
        ? categories.count
        : filteredTemplates.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if collectionView == categoriesCollectionView {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryTemplatesCell.reuseIdentifier,
                for: indexPath
            ) as! CategoryTemplatesCell

            let category = categories[indexPath.item]

            cell.configure(
                title: category,
                selected: category == selectedCategory
            )

            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TemplateCell.reuseIdentifier,
            for: indexPath
        ) as! TemplateCell

        let template = filteredTemplates[indexPath.item]

        cell.configure(with: template)

        return cell
    }
}

extension TemplatesViewController: UICollectionViewDelegate {

    func collectionView(
            _ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath
        ) {

            if collectionView == categoriesCollectionView {
                selectedCategory = categories[indexPath.item]

                categoriesCollectionView.reloadData()
                templatesCollectionView.reloadData()
            } else {
                let template = filteredTemplates[indexPath.item]
                presenter.openEditor(
                    with: filteredTemplates,
                    selected: template
                )
            }
        }
}

extension TemplatesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        guard collectionView == categoriesCollectionView else {
            return .zero
        }

        let title = categories[indexPath.item]

        let width =
        title.size(
            withAttributes: [
                .font: UIFont.systemFont(
                    ofSize: 15,
                    weight: .medium
                )
            ]
        ).width + 32

        return CGSize(
            width: width,
            height: 36
        )
    }
}
