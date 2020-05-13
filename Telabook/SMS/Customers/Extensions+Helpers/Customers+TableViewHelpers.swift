//
//  Customers+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension CustomersViewController {
    internal class CustomerDataSource: UITableViewDiffableDataSource<Section, Customer> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    }
    internal func setupTableView() {
//        subview.tableView.refreshControl = subview.refreshControl
        subview.tableView.register(CustomerCell.self, forCellReuseIdentifier: NSStringFromClass(CustomerCell.self))
        subview.tableView.delegate = self
        
        self.diffableDataSource = CustomerDataSource(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, customer) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CustomerCell.self), for: indexPath) as! CustomerCell
            cell.customerDetails = customer
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
        snapshot = NSDiffableDataSourceSnapshot<Section, Customer>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: animated, completion: {
            self.handleState()
        })
    }
}

extension CustomersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomerCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leadingAction:UIContextualAction
        
        if selectedSegment == .Inbox {
            let archiveAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Archive") { (action, view, completion) in
                DispatchQueue.main.async {
//                    self.initiateChatArchivingSequence(markArchive: true, indexPath: indexPath, completion: completion)
                }
            }
            archiveAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "archive"), text: "Archive").withRenderingMode(.alwaysTemplate)
            leadingAction = archiveAction
        } else {
            let unArchiveAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Unarchive") { (action, view, completion) in
                DispatchQueue.main.async {
//                    self.initiateChatArchivingSequence(markArchive: false, indexPath: indexPath, completion: completion)
                }
            }
            unArchiveAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "archive"), text: "Unarchive").withRenderingMode(.alwaysTemplate)
            leadingAction = unArchiveAction
        }
        leadingAction.backgroundColor = .telaBlue
        
        
        let colorAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Chat Color") { (action, view, completion) in
            DispatchQueue.main.async {
                self.promptChatColor(indexPath: indexPath)
                completion(true)
            }
        }
        colorAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "set_color").image(scaledTo: CGSize(width: 24, height: 24))!.withInsets(UIEdgeInsets(top: 2, left: 0, bottom: 1, right: 0))!, text: "Chat Color").withRenderingMode(.alwaysOriginal)
        colorAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [leadingAction, colorAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let blockAction =  UIContextualAction(style: .destructive, title: "Block", handler: { (action,view,completion ) in
//            self.initiateBlockNumberSequence(indexPath: indexPath, completion: completion)
        })
        blockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock"), text: "Block").withRenderingMode(.alwaysOriginal)
        blockAction.backgroundColor = .telaRed
        
        
        let moreAction = UIContextualAction(style: .normal, title: "More") { (action, view, completion) in
            
        }
        moreAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "tab_more_inactive").withTintColor(.white), text: "More").withRenderingMode(.alwaysOriginal)
        moreAction.backgroundColor = .telaIndigo
        
        let detailsAction =  UIContextualAction(style: .normal, title: "Details", handler: { (action,view,completionHandler ) in
            if let conversation = self.diffableDataSource?.itemIdentifier(for: indexPath) {
                let customerId = Int(conversation.externalConversationID)
//                let workerId = Int(self.workerI)
//                guard customerId != 0, workerId != 0 else {
//                    print("Customer ID & Worker ID => 0")
//                    return
//                }
                let customerDetailsVC = CustomerDetailsViewController()
//                customerDetailsVC.delegate = self
                customerDetailsVC.customerId = customerId
//                customerDetailsVC.workerId = workerId
                customerDetailsVC.view.backgroundColor = UIColor.telaGray1
                customerDetailsVC.modalPresentationStyle = .overFullScreen
                DispatchQueue.main.async {
                    self.present(customerDetailsVC, animated: true, completion: nil)
                }
                completionHandler(true)
            } else {
                DispatchQueue.main.async {
                    UIAlertController.showTelaAlert(title: "Error", message: "Invalid Conversation of Conversation not Found", controller: self)
                }
            }
        })
        detailsAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit").withTintColor(.white), text: "Details").withRenderingMode(.alwaysOriginal)
        detailsAction.backgroundColor = .systemPink
        let configuration = UISwipeActionsConfiguration(actions: [detailsAction, moreAction])
        
        return configuration
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCustomer = self.diffableDataSource?.itemIdentifier(for: indexPath) {
            let id = selectedCustomer.customerID
            guard id != 0,
                let node = selectedCustomer.node else { return }
            print("Conversation Node: \(node)")
//                let vc = ChatViewController(conversationId: String(id), node: node, conversation: selectedCustomer)
//                vc.workerId = self.workerId
//                vc.title = conversation.internalAddressBookName?.isEmpty ?? true ? conversation.customerPhoneNumber : conversation.internalAddressBookName
//            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
