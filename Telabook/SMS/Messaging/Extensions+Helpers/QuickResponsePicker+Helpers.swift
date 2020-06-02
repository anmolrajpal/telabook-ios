//
//  QuickResponsePicker+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 31/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension QuickResponsePickerController {
    
    internal func setupTableView() {
        subview.tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        subview.tableView.delegate = self
        subview.tableView.dataSource = self
    }
}

extension QuickResponsePickerController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        quickResponses.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        let quickResponse = quickResponses[indexPath.section]
//        let parameters = UIControlMenuCell.Parameters(title: action.title, image: action.image)
//        cell.parameters = parameters
        cell.textLabel?.text = quickResponse.answer
        cell.backgroundColor = .clear
        
        cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemGray4
        cell.selectedBackgroundView  = selectedBackgroundView
        return cell
    }
}

extension QuickResponsePickerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quickResponse = quickResponses[indexPath.section]
        self.dismiss(animated: true) {
            self.delegate?.quickResponseDidPick(at: indexPath, response: quickResponse)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        8
    }
}
