//
//  Blacklist+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension BlacklistViewController {
    
    internal func commonInit() {
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        setupFetchedResultsController()
        setupTableView()
        setupTargetActions()
        configureSearchController()
        synchronizeWithTimeLogic()
    }
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        if !isFetchedResultsAvailable {
            DispatchQueue.main.async {
                self.subview.placeholderLabel.text = "No Blocked User"
                self.subview.placeholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.subview.placeholderLabel.isHidden = true
            }
        }
    }
    internal func stopRefreshers() {
        DispatchQueue.main.async {
            self.subview.spinner.stopAnimating()
            self.subview.tableView.refreshControl?.endRefreshing()
        }
    }
    internal func setupTargetActions() {
        subview.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    @objc private func refreshData(_ sender: Any) {
        fetchBlacklist()
    }
    
    
    internal func synchronizeWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let firstObject = fetchedResultsController.sections?.first?.objects?.first as? BlockedUser,
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(120)
                let currentTime = Date()
                currentTime > thresholdRefreshTime ? initiateFetchBlacklistSequence(withRefreshMode: .refreshControl) : ()
                #if !RELEASE
                print("\n\n\tLast Refreshed At: \(Date.getStringFromDate(date: lastRefreshedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Threshold Refresh Time: \(Date.getStringFromDate(date: thresholdRefreshTime, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Current time: \(Date.getStringFromDate(date: currentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")))\n\n")
                #endif
            }
        } else {
            initiateFetchBlacklistSequence(withRefreshMode: .spinner)
        }
    }
    internal func initiateFetchBlacklistSequence(withRefreshMode refreshMode: RefreshMode) {
        isDownloading = true
        subview.placeholderLabel.text = "Loading..."
        if refreshMode == .spinner {
            DispatchQueue.main.async {
                self.subview.spinner.startAnimating()
                self.fetchBlacklist()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.subview.tableView.refreshControl?.beginExplicitRefreshing()
            }
        }
    }
}
