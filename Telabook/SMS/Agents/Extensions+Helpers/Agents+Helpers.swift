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
        view.backgroundColor = .telaGray1
        setUpNavBar()
        configureHierarchy()
        configureTableView()
        configureDataSource()
        configureFetchedResultsController()
        configureTargetActions()
        configureSearchController()
    }
    
    
    
    
    
    // MARK: - Setup Views
    private func configureHierarchy() {
        view.addSubview(spinner)
        view.addSubview(placeholderLabel)
        layoutConstraints()
    }
    
    
    // MARK: - Layout Methods for views
    private func layoutConstraints() {
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).activate()
        
        placeholderLabel.widthAnchor.constraint(equalToConstant: view.frame.size.width - 40).activate()
        placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).activate()
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
        if agents.isEmpty {
            DispatchQueue.main.async {
                self.placeholderLabel.text = self.isFiltering ? "No Results" : "Loading..."
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
        fetchAgents()
    }
    
    
    internal func synchronizeAgents() {
        if !agents.isEmpty {
            if let firstObject = agents.randomElement(),
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(180)
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
                        self.spinner.startAnimating()
                        self.fetchAgents()
                    }
            case .refreshControl:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.tableView.refreshControl?.beginExplicitRefreshing()
                    }
            case .none:
                self.fetchAgents()
        }
    }
}
