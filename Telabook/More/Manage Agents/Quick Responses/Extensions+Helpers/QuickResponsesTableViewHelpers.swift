//
//  QuickResponsesTableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit


extension QuickResponsesViewController {
    internal func setupTableView() {
        subview.tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        subview.tableView.delegate = self
        self.diffableDataSource = UITableViewDiffableDataSource<Section, Agent>(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, agent) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ManageAgentsCell.self), for: indexPath) as! ManageAgentsCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = UIColor.telaGray7
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
            return cell
        })
        updateSnapshot()
    }
    
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    internal func updateSnapshot(animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, QuickResponse>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: false, completion: {
            self.handleState()
        })
    }
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        if self.isFetchedResultsAvailable {
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
}

extension QuickResponsesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction =  UIContextualAction(style: .normal, title: "Edit", handler: { (action,view,completion ) in
            if let quickResponse = self.quickResponses?[indexPath.row],
                let responseId = quickResponse.id,
                let response = quickResponse.answer,
                responseId != 0,
                !response.isEmpty {
                self.showEditResponseDialogBox(responseId: String(responseId), response: response)
                completion(true)
            } else {
                fatalError("Error unwrapping quick response values")
            }
        })
        editAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit"), text: "Edit").withRenderingMode(.alwaysOriginal)
        editAction.backgroundColor = UIColor.telaIndigo
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "Delete", handler: { (action,view,completion ) in
            self.initiateDeleteQuickResponseSequence(at: indexPath, completion: completion)
            
        })
        deleteAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "delete_icon"), text: "Delete").withRenderingMode(.alwaysOriginal)
        deleteAction.backgroundColor = UIColor.telaRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}
