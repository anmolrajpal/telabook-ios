//
//  Customers+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MenuController


extension CustomersViewController {
    class CustomerDataSource: UITableViewDiffableDataSource<Section, Customer> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    }
    func setupTableView() {
        self.subview.tableView.delegate = self
        self.subview.tableView.register(CustomerCell.self, forCellReuseIdentifier: NSStringFromClass(CustomerCell.self))
    }
    func updateUI(animating:Bool = true) {
        guard let snapshot = currentSnapshot() else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            self.subview.tableView.reloadData()
            self.handleState()
        })
    }
    func configureDataSource() {
        self.dataSource = CustomerDataSource(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, customer) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CustomerCell.self), for: indexPath) as? CustomerCell else { fatalError("Could not create new cell") }
            cell.customerDetails = customer
            cell.backgroundColor = .telaGray1
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .disclosureIndicator
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
            cell.selectedBackgroundView  = backgroundView
            return cell
        })
        updateUI(animating: false)
    }
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, Customer>? {
        guard fetchedResultsController != nil else { return nil }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Customer>()
        snapshot.appendSections([.main])
        let objects = fetchedResultsController.fetchedObjects ?? []
        snapshot.appendItems(objects)
        return snapshot
    }
    
}

extension CustomersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomerCell.cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let customer = self.dataSource.itemIdentifier(for: indexPath) else { return }
        self.openChat(forSelectedCustomer: customer, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // 1
        let index = indexPath.row
        guard let customers = fetchedResultsController.fetchedObjects else { return nil }
        let customer = customers[index]
        guard let conversation = firebaseCustomers.first(where: { $0.conversationID == customer.externalConversationID }) else { return nil }
        
        // 2
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let yellowAction = UIAction(title: "Yellow", image: SFSymbol.circleSwitch.image.withTintColor(.telaYellow, renderingMode: .alwaysOriginal)) { _ in
                self.updateColorOnFirebase(forConversation: conversation, color: .Yellow)
            }
            let blueAction = UIAction(title: "Blue", image: SFSymbol.circleSwitch.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                self.updateColorOnFirebase(forConversation: conversation, color: .Blue)
            }
            let greenAction = UIAction(title: "Green", image: SFSymbol.circleSwitch.image.withTintColor(.telaGreen, renderingMode: .alwaysOriginal)) { _ in
                self.updateColorOnFirebase(forConversation: conversation, color: .Green)
            }
            let whiteAction = UIAction(title: "White", image: SFSymbol.circleSwitch.image.withTintColor(.telaWhite, renderingMode: .alwaysOriginal)) { _ in
                self.updateColorOnFirebase(forConversation: conversation, color: .White)
            }
            let setColorMenu = UIMenu(title: "Set Color", image: #imageLiteral(resourceName: "set_color").withInsets(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)), children: [
                yellowAction, blueAction, greenAction, whiteAction
            ])
            let sendMessageAction = UIAction(title: "Send Message", image: #imageLiteral(resourceName: "autoresponse_icon")) { _ in
                self.openChat(forSelectedCustomer: customer, at: indexPath)
            }
            let pinningAction = UIAction(title: customer.isPinned ? "Unpin" : "Pin", image: (customer.isPinned ? #imageLiteral(resourceName: "unpin") : #imageLiteral(resourceName: "pin")).withInsets(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))) { _ in
                self.updateConversationInStore(for: customer, pinning: !customer.isPinned, completion: {_ in})
            }
            let detailsAction = UIAction(title: "Details", image: SFSymbol.person.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                
            }
            let archiveAction = UIAction(title: "Archive", image: #imageLiteral(resourceName: "archive")) { _ in
                self.updateConversation(for: customer, archiving: true, completion: {_ in})
            }
            let unarchiveAction = UIAction(title: "Unarchive", image: #imageLiteral(resourceName: "archive")) { _ in
                self.updateConversation(for: customer, archiving: false, completion: {_ in})
            }
            let blockAction = UIAction(title: "Block", image: #imageLiteral(resourceName: "block_rounded"), attributes: .destructive) { _ in
                self.promptBlockingReasonAlert(for: customer)
            }
            
            let deleteAction = UIAction(title: "Confirm Delete", image: #imageLiteral(resourceName: "delete_icon"), attributes: .destructive) { _ in
                self.deleteConversation(for: customer, completion: {_ in})
            }
            let confirmDeleteMenu = UIMenu(title: "Delete", image: SFSymbol.arrowUpRightSquare.image, options: [.destructive], children: [deleteAction])
            return UIMenu(title: "", children: [
                sendMessageAction,
                pinningAction,
                setColorMenu,
                detailsAction,
                self.selectedSegment == .Inbox ? archiveAction : unarchiveAction,
                blockAction,
                confirmDeleteMenu
            ])
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        guard let customers = fetchedResultsController.fetchedObjects, !customers.isEmpty else { return nil }
        let customer = customers[index]
        
        
        let leadingAction:UIContextualAction
        if selectedSegment == .Inbox {
            let archiveAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Archive") { (action, view, completion) in
                self.updateConversation(for: customer, archiving: true, completion: completion)
            }
            archiveAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "archive"), text: "Archive").withRenderingMode(.alwaysTemplate)
            leadingAction = archiveAction
        } else {
            let unArchiveAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Unarchive") { (action, view, completion) in
                self.updateConversation(for: customer, archiving: false, completion: completion)
            }
            unArchiveAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "archive"), text: "Unarchive").withRenderingMode(.alwaysTemplate)
            leadingAction = unArchiveAction
        }
        leadingAction.backgroundColor = .telaBlue
        
        
        let pinningAction = UIContextualAction(style: UIContextualAction.Style.normal, title: customer.isPinned ? "Unpin" : "Pin") { (action, view, completion) in
            completion(true)
            self.updateConversationInStore(for: customer, pinning: !customer.isPinned, completion: completion)
        }
        pinningAction.image = UIImage.textImage(image: (customer.isPinned ? #imageLiteral(resourceName: "unpin") : #imageLiteral(resourceName: "pin")).image(scaledTo: CGSize(width: 22, height: 22))!.withInsets(UIEdgeInsets(top: 2, left: 0, bottom: 1, right: 0))!, text: customer.isPinned ? "Unpin" : "Pin").withRenderingMode(.alwaysOriginal)
        pinningAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [leadingAction, pinningAction])
        return configuration
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        guard let customers = fetchedResultsController.fetchedObjects else { return nil }
        let customer = customers[index]
//        guard let conversation = firebaseCustomers.first(where: { $0.conversationID == customer.externalConversationID }) else { return nil }
        
        
        
        let blockAction =  UIContextualAction(style: .destructive, title: "Block", handler: { (action,view,completion ) in
            completion(true)
//            self.initiateBlockNumberSequence(indexPath: indexPath, completion: completion)
        })
        blockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock"), text: "Block").withRenderingMode(.alwaysOriginal)
        blockAction.backgroundColor = .telaRed
        
        
        let moreAction = UIContextualAction(style: .normal, title: "More") { (action, view, completion) in
            let sendMessageAction = UIControlMenuAction(title: "Send Message", image: SFSymbol.sendMessage.image) { _ in
                self.openChat(forSelectedCustomer: customer, at: indexPath)
            }
            let setColorAction = UIControlMenuAction(title: "Set Color", image: #imageLiteral(resourceName: "set_color").image(scaledTo: CGSize(width: 26, height: 26))!, handler: { _ in
                self.promptChatColor(indexPath: indexPath)
            })
            let archiveAction = UIControlMenuAction(title: "Archive", image: #imageLiteral(resourceName: "archive"), handler: { _ in
                self.updateConversation(for: customer, archiving: true, completion: { _ in})
            })
            let unarchiveAction = UIControlMenuAction(title: "Unarchive", image: #imageLiteral(resourceName: "archive"), handler: { _ in
                self.updateConversation(for: customer, archiving: false, completion: { _ in})
            })
            let pinningAction = UIControlMenuAction(title: customer.isPinned ? "Unpin" : "Pin", image: (customer.isPinned ? #imageLiteral(resourceName: "unpin") : #imageLiteral(resourceName: "pin"))) { _ in
                self.updateConversationInStore(for: customer, pinning: !customer.isPinned, completion: completion)
            }
            let detailsAction = UIControlMenuAction(title: "Details", image: SFSymbol.person.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                
            }
            let blockAction = UIControlMenuAction(title: "Block", image: #imageLiteral(resourceName: "block_rounded")) { _ in
                self.promptBlockingReasonAlert(for: customer)
            }
            
            let deleteAction = UIControlMenuAction(title: "Delete", image: #imageLiteral(resourceName: "delete_icon")) { _ in
                self.deleteConversation(for: customer, completion: {_ in})
            }
            
            let actions:[UIControlMenuAction] = [
                sendMessageAction,
                pinningAction,
                setColorAction,
                detailsAction,
                self.selectedSegment == .Inbox ? archiveAction : unarchiveAction,
                blockAction,
                deleteAction
            ]

            let vc = MenuController(actions: actions)
            self.present(vc, animated: true, completion: nil)
            completion(true)
        }
        moreAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "tab_more_inactive").withTintColor(.white), text: "More").withRenderingMode(.alwaysOriginal)
        moreAction.backgroundColor = .telaIndigo
        
        let detailsAction =  UIContextualAction(style: .normal, title: "Details", handler: { (action,view,completionHandler ) in
            if let conversation = self.dataSource.itemIdentifier(for: indexPath) {
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
    
    internal func openChat(forSelectedCustomer customer:Customer, at indexPath:IndexPath) {
        let id = customer.customerID
        print(customer.node as Any)
        guard
            id != 0,
            customer.node != nil else { return }
        let vc = MessagesController(context: context, customer: customer, conversationReference: self.reference)
        navigationController?.pushViewController(vc, animated: true)
    }
}


