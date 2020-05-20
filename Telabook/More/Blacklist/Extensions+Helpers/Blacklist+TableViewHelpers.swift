//
//  Blacklist+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

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
        // 1
        let index = indexPath.row
        guard let blacklist = fetchedResultsController.fetchedObjects else { return nil }
        let blockedUser = blacklist[index]
        print(blockedUser)
        
        // 2
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            
            let detailsAction = UIAction(title: "Details", image: SFSymbol.person.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                
            }
            
            let unblockAction = UIAction(title: "Unblock", image: #imageLiteral(resourceName: "block_rounded"), attributes: .destructive) { _ in
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
        print(blockedUser)
        
        
        
        let unblockAction =  UIContextualAction(style: .destructive, title: "Unblock", handler: { (action,view,completion ) in
            self.unblockConversation(for: blockedUser, completion: {_ in})
        })
        unblockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock"), text: "Unblock").withRenderingMode(.alwaysOriginal)
        unblockAction.backgroundColor = .systemPink
        
        
        
        let detailsAction =  UIContextualAction(style: .destructive, title: "Details", handler: { (action,view,completion ) in
            //            self.initiateBlockNumberSequence(indexPath: indexPath, completion: completion)
        })
        detailsAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "more_img"), text: "Details").withRenderingMode(.alwaysOriginal)
        detailsAction.backgroundColor = .telaGray7
        
       
        let configuration = UISwipeActionsConfiguration(actions: [unblockAction, detailsAction])
        return configuration
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedBlockedUser = self.diffableDataSource?.itemIdentifier(for: indexPath) {
            let id = selectedBlockedUser.id
            print(id)
//            guard id != 0,
//                let node = selectedCustomer.node else { return }
//            print("Conversation Node: \(node)")
//                let vc = ChatViewController(conversationId: String(id), node: node, conversation: selectedCustomer)
//                vc.workerId = self.workerId
//                vc.title = conversation.internalAddressBookName?.isEmpty ?? true ? conversation.customerPhoneNumber : conversation.internalAddressBookName
//            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
