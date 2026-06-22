//
//  HistoryChatViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit

enum ChatSection: Hashable {
    case today
    case yesterday
    case month(String)
}


protocol HistoryChatProtocol: AnyObject {
    func reloadAndShowHistory()
    func showError(_ text: String)
}


final class HistoryChatViewController: BaseController, HistoryChatProtocol {

    var presenter: HistoryChatPresenter!

    private var tableView = UITableView()

    private var chats: [ChatInfo] = []

    private var groupedChats: [ChatSection: [ChatInfo]] = [:]
    private var sections: [ChatSection] = []

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Images.arrowPop, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Chat History"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        presenter.loadHistory()

        setupUI()
        setupBehavior()
    }

    private func setupUI() {
        hideHeaderGradient()
        tableView.register(
            HistoryChatCell.self,
            forCellReuseIdentifier: HistoryChatCell.id
        )
        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = 84
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        view.addSubviews(tableView, backButton, titleLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -24),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }


    override func setupBehavior() {
        super.setupBehavior()
        backButton.addTarget(
            self,
            action: #selector(backTapped),
            for: .touchUpInside
        )
    }

    @objc
    private func backTapped() {
        presenter.didTapBack()
    }

    func reloadAndShowHistory() {
        hideLoadingIndicator()
        chats = presenter.chats

        groupedChats.removeAll()
        sections.removeAll()

        for chat in chats {
            guard let date = chat.updatedAt.toDolaDate() else {
                continue
            }

            let section: ChatSection

            if date.isToday {
                section = .today

            } else if date.isYesterday {
                section = .yesterday

            } else {
                section = .month(date.monthYearString())
            }

            groupedChats[section, default: []].append(chat)
        }

        for key in groupedChats.keys {
            groupedChats[key]?.sort { first, second in
                guard
                    let d1 = first.updatedAt.toDolaDate(),
                    let d2 = second.updatedAt.toDolaDate()
                else {
                    return false
                }
                return d1 > d2
            }
        }

        sections = groupedChats.keys.sorted { lhs, rhs in
            sortSections(lhs, rhs)
        }

        tableView.reloadData()
    }

    private func sortSections(_ lhs: ChatSection, _ rhs: ChatSection) -> Bool {

        func rank(_ s: ChatSection) -> Int {
            switch s {
            case .today: return 0
            case .yesterday: return 1
            case .month: return 2
            }
        }

        return rank(lhs) < rank(rhs)
    }

    func showError(_ text: String) {
        hideLoadingIndicator()
        showAlert(message: text)
    }
}

extension HistoryChatViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sections[section]
        return groupedChats[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HistoryChatCell.id,
            for: indexPath
        ) as? HistoryChatCell else {
            return UITableViewCell()
        }

        let section = sections[indexPath.section]
        let chat = groupedChats[section]![indexPath.row]

        cell.configure(with: chat)

        return cell
    }
}

extension HistoryChatViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let title: String
        switch sections[section] {
        case .today:
            title = "Today"
        case .yesterday:
            title = "Yesterday"
        case .month(let monthTitle):
            title = monthTitle
        }

        let headerView = UIView()

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = sections[indexPath.section]
        let chat = groupedChats[section]?[indexPath.row]

        presenter.openChat(with: chat?.chatId)
    }
}
