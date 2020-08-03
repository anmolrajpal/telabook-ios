//
//  DisabledAccounts+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension DisabledAccountsController {
    // MARK: Common setup
    internal func commonInit() {
        title = "DISABLED ACCOUNTS"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
//        configureHierarchy()
        configureTableView()
        configureDataSource()
//        configureFetchedResultsController()
        configureTargetActions()
//        configureSearchController()
    }
    
    
    
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        if disabledAccounts.isEmpty {
            DispatchQueue.main.async {
//                self.placeholderLabel.text = self.isFiltering ? "No Results" : "Loading..."
                self.placeholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.placeholderLabel.isHidden = true
            }
        }
    }
    internal func stopRefreshers() {
        spinner.stopAnimating()
        tableView.refreshControl?.endRefreshing()
    }
    private func configureTargetActions() {
        tableViewRefreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    @objc private func refreshData(_ sender: Any) {
//        fetchAgents()
    }
}
