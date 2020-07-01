//
//  Agents+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AgentsViewController {
    
    // MARK: Common setup
    internal func commonInit() {
        title = "SMS"
        setUpNavBar()
        configureTableView()
        configureDataSource()
        configureFetchedResultsController()
        setupTargetActions()
        setupSearchController()
    }
    
    
    internal func addFirebaseObservers() {
        handle = observePendingMessagesCount()
    }
    internal func removeFirebaseObservers() {
        if handle != nil {
            reference.removeObserver(withHandle: handle)
        }
    }
    
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        if self.fetchedResultsController.sections?.first?.numberOfObjects == 0 {
            DispatchQueue.main.async {
                self.subview.placeholderLabel.text = self.isFiltering ? "No Agent Found" : "Loading"
                self.subview.placeholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.subview.placeholderLabel.isHidden = true
            }
        }
    }
    internal func stopRefreshers() {
        self.subview.spinner.stopAnimating()
        self.subview.tableView.refreshControl?.endRefreshing()
    }
    internal func setupTargetActions() {
        subview.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    @objc private func refreshData(_ sender: Any) {
        fetchAgents()
    }
    
    
    internal func synchronizeAgents() {
        if !agents.isEmpty {
            if let firstObject = agents.randomElement(),
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(60)
                Date() > thresholdRefreshTime ?
                    initiateFetchAgentsSequence(withRefreshMode: .refreshControl) :
                    initiateFetchAgentsSequence(withRefreshMode: .none)
            }
        } else {
            initiateFetchAgentsSequence(withRefreshMode: .spinner)
        }
    }
    
    internal func initiateFetchAgentsSequence(withRefreshMode refreshMode: RefreshMode) {
        switch refreshMode {
            case .spinner:
                    DispatchQueue.main.async {
                        self.subview.spinner.startAnimating()
                        self.fetchAgents()
                    }
            case .refreshControl:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.subview.tableView.refreshControl?.beginExplicitRefreshing()
                    }
            case .none:
                self.fetchAgents()
        }
    }
}
