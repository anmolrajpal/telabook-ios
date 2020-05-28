//
//  ManageAgentsHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension ManageAgentsViewController {
    
    internal func setupFetchedResultsController() {
        fetchRequest = Agent.fetchRequest()
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Agent.personName)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.personName), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: PersistentContainer.shared.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.date), ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: PersistentContainer.shared.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: String(describing: self))
        }
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            updateSnapshot()
        } catch {
            print("Error fetching results: \(error)")
        }
    }
    
    internal func setupTableView() {
        subview.tableView.refreshControl = subview.refreshControl
        subview.tableView.register(ManageAgentsCell.self, forCellReuseIdentifier: NSStringFromClass(ManageAgentsCell.self))
        subview.tableView.delegate = self
        
        self.diffableDataSource = UITableViewDiffableDataSource<Section, Agent>(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, agent) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ManageAgentsCell.self), for: indexPath) as! ManageAgentsCell
            cell.backgroundColor = .clear
            cell.agentDetails = agent
            return cell
        })
        updateSnapshot()
    }
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    internal func updateSnapshot(animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, Agent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: false, completion: {
            self.handleState()
        })
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
    
    
    
    /// Setup the `UISearchController` to let users search through the list of colors
    internal func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Agents"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        let attributes:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.telaRed,
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
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
