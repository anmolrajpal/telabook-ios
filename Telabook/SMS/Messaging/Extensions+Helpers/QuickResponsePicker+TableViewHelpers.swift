//
//  QuickResponsePicker+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 31/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension QuickResponsePickerController {
    internal func commonInit() {
        setupTableView()
        setUpNavBar()
        setupNavBarItems()
    }
    private func setupNavBarItems() {
        let addButton = UIBarButtonItem(title: "Manage", style: UIBarButtonItem.Style.done, target: self, action: #selector(manageButtonDidTap))
        navigationItem.rightBarButtonItems = [addButton]
    }
    @objc
    private func manageButtonDidTap() {
        let vc = QuickResponsesViewController(userID: Int(agent.userID), agent: agent)
        navigationController?.pushViewController(vc, animated: true)
    }
}
