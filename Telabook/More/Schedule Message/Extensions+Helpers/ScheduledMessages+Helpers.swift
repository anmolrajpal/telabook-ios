//
//  ScheduledMessages+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ScheduleMessageViewController {
    internal func commonInit() {
        title = "SCHEDULED MESSAGES"
        setUpNavBar()
        setupNavBarItems()
//        configureFetchedResultsController()
        configureHierarchy()
        configureTableView()
        configureFetchedResultsController()
        performFetch()
    }
    private func setupNavBarItems() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonDidTapped))
        navigationItem.rightBarButtonItems = [addButton]
    }
    @objc
    private func addButtonDidTapped() {
        let vc = ScheduleNewMessageViewController()
        vc.delegate = self
        let controller = UINavigationController(rootViewController: vc)
        present(controller, animated: true)
    }
    private func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(placeholderLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
        tableView.fillSuperview()
        spinner.centerInSuperview()
        placeholderLabel.anchor(top: spinner.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
    }
    func startSpinner() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    func stopSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
}

extension ScheduleMessageViewController: ScheduleNewMessageDelegate {
    func controllerDidScheduleNewMessage(controller: UIViewController) {
        controller.dismiss(animated: true) {
            self.fetchScheduledMessages()
        }
    }
}
