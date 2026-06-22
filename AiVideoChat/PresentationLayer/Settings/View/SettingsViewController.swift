//
//  SettingsViewController.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 17.06.2026.
//

import UIKit

protocol SettingsViewProtocol: AnyObject { }

final class SettingsViewController: BaseController, SettingsViewProtocol {


    var presenter: SettingsPresenter!


    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
