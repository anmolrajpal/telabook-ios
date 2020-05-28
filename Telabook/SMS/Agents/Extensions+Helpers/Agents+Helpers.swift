//
//  Agents+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AgentsViewController {
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
    
    
    internal func synchronizeWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let firstObject = fetchedResultsController.sections?.first?.objects?.first as? Agent,
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(120)
                let currentTime = Date()
                currentTime > thresholdRefreshTime ? initiateFetchAgentsSequence(withRefreshMode: .refreshControl) : ()
                #if DEBUG
                print("\n\n\tLast Refreshed At: \(Date.getStringFromDate(date: lastRefreshedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Threshold Refresh Time: \(Date.getStringFromDate(date: thresholdRefreshTime, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Current time: \(Date.getStringFromDate(date: currentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")))\n\n")
                #endif
            }
        } else {
            initiateFetchAgentsSequence(withRefreshMode: .spinner)
        }
    }
    internal func initiateFetchAgentsSequence(withRefreshMode refreshMode: RefreshMode) {
        if refreshMode == .spinner {
            DispatchQueue.main.async {
                self.subview.spinner.startAnimating()
                self.fetchAgents()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.subview.tableView.refreshControl?.beginExplicitRefreshing()
            }
        }
    }
}
