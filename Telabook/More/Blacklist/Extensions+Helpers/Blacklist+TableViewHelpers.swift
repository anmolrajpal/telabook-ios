//
//  Blacklist+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import InteractiveModal

extension BlacklistViewController {
    internal class BlacklistDataSource: UITableViewDiffableDataSource<Section, BlockedUser> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    }
    internal func setupTableView() {
        subview.tableView.register(BlacklistCell.self, forCellReuseIdentifier: NSStringFromClass(BlacklistCell.self))
        subview.tableView.delegate = self
        
        self.diffableDataSource = BlacklistDataSource(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, blockedUser) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(BlacklistCell.self), for: indexPath) as! BlacklistCell
            cell.blockedUser = blockedUser
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
            cell.selectedBackgroundView  = backgroundView
            return cell
        })
        updateSnapshot()
    }
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    internal func updateSnapshot(animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, BlockedUser>()
        snapshot.appendSections([.main])
        let objects = fetchedResultsController.fetchedObjects ?? []
        snapshot.appendItems(objects)
        self.diffableDataSource?.apply(self.snapshot, animatingDifferences: animated, completion: {
            self.handleState()
        })
    }
}



extension BlacklistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BlacklistCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        guard let blacklist = fetchedResultsController.fetchedObjects else { return nil }
        let blockedUser = blacklist[index]
        
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            
            let detailsAction = UIAction(title: "Details", image: #imageLiteral(resourceName: "tab_more_active").withTintColor(.white)) { _ in
                self.showDetails(at: indexPath)
            }
            
            let unblockAction = UIAction(title: "Unblock", image: #imageLiteral(resourceName: "unblock").withTintColor(.white).image(scaledTo: .init(width: 30, height: 30))!, attributes: .destructive) { _ in
                self.unblockConversation(for: blockedUser, completion: {_ in})
            }
           
            return UIMenu(title: "", children: [
                detailsAction,
                unblockAction
            ])
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        guard let blacklist = fetchedResultsController.fetchedObjects else { return nil }
        let blockedUser = blacklist[index]
        
        let unblockAction =  UIContextualAction(style: .destructive, title: "Unblock", handler: { (action,view,completion ) in
            self.unblockConversation(for: blockedUser, completion: completion)
        })
        unblockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock").withTintColor(.white).image(scaledTo: .init(width: 25, height: 25))!, text: "Unblock").withRenderingMode(.alwaysOriginal)
        unblockAction.backgroundColor = .systemPink
        
        
        let detailsAction =  UIContextualAction(style: .destructive, title: "Details", handler: { (action,view,completion ) in
            completion(true)
            self.showDetails(at: indexPath)
        })
        detailsAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "tab_more_active").withTintColor(.white), text: "Details").withRenderingMode(.alwaysOriginal)
        detailsAction.backgroundColor = .telaGray7
        
       
        let configuration = UISwipeActionsConfiguration(actions: [unblockAction, detailsAction])
        return configuration
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showDetails(at: indexPath)
    }
    internal func showDetails(at indexPath:IndexPath) {
        if let selectedBlockedUser = self.diffableDataSource?.itemIdentifier(for: indexPath) {
            let vc = BlacklistedDetailsViewController(selectedBlockedUser: selectedBlockedUser)
            vc.delegate = self
            let presenter = InteractiveModalViewController(controller: vc)
            self.present(presenter, animated: true, completion: nil)
        }
    }
}

extension BlacklistViewController: BlacklistedDetailsDelegate {
    func unblockButton(didTapFor blockedUser: BlockedUser) {
        self.unblockConversation(for: blockedUser, completion: {_ in})
    }
}
