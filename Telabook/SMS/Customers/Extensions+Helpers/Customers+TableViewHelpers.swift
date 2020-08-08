//
//  Customers+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MenuController
import CoreData


extension CustomersViewController {
    enum Section { case main }
    
    
    class CustomerDataSource: UITableViewDiffableDataSource<Section, Customer> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    }
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.register(SubtitleTableViewCell.self)
        tableView.register(UITableViewCell.self)
        tableView.register(CustomerCell.self)
    }
    
    func configureDataSource() {
        dataSource = CustomerDataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, customer) -> UITableViewCell? in
            guard let self = self else { return nil }
            let reusableCell:UITableViewCell
            switch true {
                case self.pickerDelegate != nil:
                    let phoneNumber = customer.phoneNumber ?? ""
                    let number:String
                    if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
                        number = formattedPhoneNumber
                    } else {
                        number = phoneNumber
                    }
                    let name = customer.addressBookName
                    
                    let conversationColor = CustomerConversationColor.colorCase(from: Int(customer.colorCode)).color
                    
                    
                    let cell:UITableViewCell
                    if name == nil || name?.isBlank == true {
                        cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        cell.textLabel?.text = phoneNumber
                    } else {
                        cell = tableView.dequeueReusableCell(SubtitleTableViewCell.self, for: indexPath)
                        cell.textLabel?.text = name
                        cell.detailTextLabel?.text = number
                    }
                    
                    cell.tintColor = .telaBlue
                    cell.backgroundColor = .clear
                    cell.textLabel?.textColor = conversationColor
                    cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
                    cell.detailTextLabel?.textColor = UIColor.telaGray7
                    cell.detailTextLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
                    
                    if customer.customerID == self.selectedCustomer?.customerID,
                        self.selectedCustomer != nil {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                    reusableCell = cell
                
                case self.messageForwardingDelegate != nil:
                    let phoneNumber = customer.phoneNumber ?? ""
                    let number:String
                    if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
                        number = formattedPhoneNumber
                    } else {
                        number = phoneNumber
                    }
                    let name = customer.addressBookName
                    
                    let conversationColor = CustomerConversationColor.colorCase(from: Int(customer.colorCode)).color
                    
                    
                    let cell:UITableViewCell

                    if name == nil || name?.isBlank == true {
                        cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        cell.textLabel?.text = phoneNumber
                    } else {
                        cell = tableView.dequeueReusableCell(SubtitleTableViewCell.self, for: indexPath)
                        cell.textLabel?.text = name
                        cell.detailTextLabel?.text = number
                    }
                    
                    cell.tintColor = .telaBlue
                    cell.backgroundColor = .clear
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = conversationColor
                    cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
                    cell.detailTextLabel?.textColor = UIColor.telaGray7
                    cell.detailTextLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
                    
                    if self.selectedConversationsToForwardMessage.contains(where: { $0.customerID == customer.customerID }) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                    reusableCell = cell
                
                default:
                    let cell = tableView.dequeueReusableCell(CustomerCell.self, for: indexPath)
                    cell.configureCell(with: customer)
                    cell.backgroundColor = .clear
                    cell.accessoryType = .disclosureIndicator
                    reusableCell = cell
            }
            return reusableCell
        })
    }
    
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, Customer>? {
        guard fetchedResultsController != nil else { return nil }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Customer>()
        snapshot.appendSections([.main])
        snapshot.appendItems(customers)
        return snapshot
    }
    
    func updateUI(animating:Bool = true, reloadingData:Bool = true) {
        guard let snapshot = currentSnapshot(), dataSource != nil else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData && self.viewDidAppear { self.tableView.reloadData() }
            self.handleState()
        })
    }
    
}



// MARK: - UITableView Delegate

extension CustomersViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return segmentedControl
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomerCell.cellHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let customer = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch true {
            case pickerDelegate != nil:
                tableView.resetCheckmarks()
                cell.accessoryType = .checkmark
                pickerDelegate?.customersController(didPick: customer, at: indexPath, controller: self)
            case messageForwardingDelegate != nil:
                if let selectedIndex = selectedConversationsToForwardMessage.firstIndex(of: customer) {
                    selectedConversationsToForwardMessage.remove(at: selectedIndex)
                } else {
                    selectedConversationsToForwardMessage.append(customer)
                }
                updateNavigationBarItems()
                updateUI(animating: false, reloadingData: false)
            default:
                self.openChat(forSelectedCustomer: customer, at: indexPath)
        }
        /*
         if pickerDelegate == nil {
         self.openChat(forSelectedCustomer: customer, at: indexPath)
         } else {
         tableView.resetCheckmarks()
         cell.accessoryType = .checkmark
         pickerDelegate?.customersController(didPick: customer, at: indexPath, controller: self)
         }
         */
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard pickerDelegate == nil && messageForwardingDelegate == nil else { return nil }
        let index = indexPath.row
        let customer = customers[index]
        guard let conversation = firebaseCustomers.first(where: { $0.conversationID == customer.externalConversationID }) else { return nil }
        
        // 2
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            var menuItems = [UIMenuElement]()
            
            
            
            // MARK: - Send Message Action
            
            let sendMessageAction = UIAction(title: "Send Message", image: #imageLiteral(resourceName: "autoresponse_icon")) { _ in
                self.openChat(forSelectedCustomer: customer, at: indexPath)
            }
            menuItems.append(sendMessageAction)
            
            
            
            
            
            /*
             // MARK: - Pin/Unpin Action
             
             let pinningAction = UIAction(title: customer.isPinned ? "Unpin" : "Pin", image: (customer.isPinned ? #imageLiteral(resourceName: "unpin") : #imageLiteral(resourceName: "pin")).withInsets(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))) { _ in
             self.updateConversationInStore(for: customer, pinning: !customer.isPinned, completion: {_ in})
             }
             menuItems.append(pinningAction)
             */
            
            
            
            
            
            // MARK: - Send Color Action
            
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
            menuItems.append(setColorMenu)
            
            
            
            
            
            // MARK: - Details Action
            
            _ = UIAction(title: "Details", image: SFSymbol.person.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                let vc = CustomerDetailsController(conversation: customer)
                let navController = UINavigationController(rootViewController: vc)
                DispatchQueue.main.async {
                    self.present(navController, animated: true)
                }
            }
//            menuItems.append(detailsAction)
            
            
            
            // MARK: - Conversation Gallery Action
            
            let galleryAction = UIAction(title: "Gallery", image: #imageLiteral(resourceName: "camera_icon")) { _ in
                let vc = ConversationGalleryController(conversation: customer)
                let controller = UINavigationController(rootViewController: vc)
                self.present(controller, animated: true)
            }
            menuItems.append(galleryAction)
            
            
            
            // MARK: - Archive/Unarchive Actions
            
            let archiveAction = UIAction(title: "Archive", image: #imageLiteral(resourceName: "archive")) { _ in
                self.updateConversation(for: customer, archiving: true, completion: {_ in})
            }
            let unarchiveAction = UIAction(title: "Unarchive", image: #imageLiteral(resourceName: "archive")) { _ in
                self.updateConversation(for: customer, archiving: false, completion: {_ in})
            }
            switch self.selectedSegment {
                case .Inbox: menuItems.append(archiveAction)
                case .Archived: menuItems.append(unarchiveAction)
            }
            
            
            
            
            // MARK: - Copy Customer Phone Number Action
            
            if let text = customer.phoneNumber, !text.isBlank {
                let copyNumberAction = UIAction(title: "Copy Phone Number", image: SFSymbol.copy.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                    UIPasteboard.general.string = text
                }
                menuItems.append(copyNumberAction)
            }
            
            
            
            // MARK: - Block Action
            
            let blockAction = UIAction(title: "Block", image: #imageLiteral(resourceName: "block_rounded"), attributes: .destructive) { _ in
                self.promptBlockingReasonAlert(for: customer)
            }
            menuItems.append(blockAction)
            
            
            
            // MARK: - Delete Conversation Action
            
            let deleteAction = UIAction(title: "Confirm Delete", image: #imageLiteral(resourceName: "delete_icon"), attributes: .destructive) { _ in
                self.deleteConversation(for: customer, completion: {_ in})
            }
            let confirmDeleteMenu = UIMenu(title: "Delete", image: SFSymbol.arrowUpRightSquare.image, options: [.destructive], children: [deleteAction])
            menuItems.append(confirmDeleteMenu)
            
            
            return UIMenu(title: "", children: menuItems)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard pickerDelegate == nil && messageForwardingDelegate == nil else { return nil }
        let index = indexPath.row
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
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard pickerDelegate == nil && messageForwardingDelegate == nil else { return nil }
        let index = indexPath.row
        let customer = customers[index]
        //        guard let conversation = firebaseCustomers.first(where: { $0.conversationID == customer.externalConversationID }) else { return nil }
        
        
        
        let blockAction =  UIContextualAction(style: .destructive, title: "Block", handler: { (action,view,completion ) in
            completion(true)
            //            self.initiateBlockNumberSequence(indexPath: indexPath, completion: completion)
        })
        blockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock"), text: "Block").withRenderingMode(.alwaysOriginal)
        blockAction.backgroundColor = .telaRed
        
        
        let moreAction = UIContextualAction(style: .normal, title: "More") { (action, view, completion) in
            
            var menuItems = [UIControlMenuAction]()
            
            
            
            // MARK: - Send Message Action
            
            let sendMessageAction = UIControlMenuAction(title: "Send Message", image: SFSymbol.sendMessage.image) { _ in
                self.openChat(forSelectedCustomer: customer, at: indexPath)
            }
            menuItems.append(sendMessageAction)
            
            
            // MARK: - Pin/Unpin Action
            
            let pinningAction = UIControlMenuAction(title: customer.isPinned ? "Unpin" : "Pin", image: (customer.isPinned ? #imageLiteral(resourceName: "unpin") : #imageLiteral(resourceName: "pin"))) { _ in
                self.updateConversationInStore(for: customer, pinning: !customer.isPinned, completion: completion)
            }
            menuItems.append(pinningAction)
            
            
            
            
            // MARK: - Send Color Action
            
            let setColorAction = UIControlMenuAction(title: "Set Color", image: #imageLiteral(resourceName: "set_color").image(scaledTo: CGSize(width: 26, height: 26))!, handler: { _ in
                self.promptChatColor(indexPath: indexPath)
            })
            menuItems.append(setColorAction)
            
            
            
            // MARK: - Details Action
            
            _ = UIControlMenuAction(title: "Details", image: SFSymbol.person.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                let vc = CustomerDetailsController(conversation: customer)
                let navController = UINavigationController(rootViewController: vc)
                DispatchQueue.main.async {
                    self.present(navController, animated: true)
                }
            }
//            menuItems.append(detailsAction)
            
            
            
            
            // MARK: - Conversation Gallery Action
            
            let galleryAction = UIControlMenuAction(title: "Gallery", image: #imageLiteral(resourceName: "camera_icon")) { _ in
                let vc = ConversationGalleryController(conversation: customer)
                let controller = UINavigationController(rootViewController: vc)
                self.present(controller, animated: true)
            }
            menuItems.append(galleryAction)
            
            
            
            
            
            
            // MARK: - Archive/Unarchive Actions
            
            let archiveAction = UIControlMenuAction(title: "Archive", image: #imageLiteral(resourceName: "archive"), handler: { _ in
                self.updateConversation(for: customer, archiving: true, completion: { _ in})
            })
            let unarchiveAction = UIControlMenuAction(title: "Unarchive", image: #imageLiteral(resourceName: "archive"), handler: { _ in
                self.updateConversation(for: customer, archiving: false, completion: { _ in})
            })
            switch self.selectedSegment {
                case .Inbox: menuItems.append(archiveAction)
                case .Archived: menuItems.append(unarchiveAction)
            }
            
            
            
            
            // MARK: - Copy Customer Phone Number Action
            
            if let text = customer.phoneNumber, !text.isBlank {
                let copyNumberAction = UIControlMenuAction(title: "Copy Phone Number", image: SFSymbol.copy.image) { _ in
                    UIPasteboard.general.string = text
                }
                menuItems.append(copyNumberAction)
            }
            
            
            
            
            
            
            // MARK: - Block Action
            
            let blockAction = UIControlMenuAction(title: "Block", image: #imageLiteral(resourceName: "block_rounded")) { _ in
                self.promptBlockingReasonAlert(for: customer)
            }
            menuItems.append(blockAction)
            
            
            
            
            
            
            // MARK: - Delete Conversation Action
            
            let deleteAction = UIControlMenuAction(title: "Delete", image: #imageLiteral(resourceName: "delete_icon")) { _ in
                self.deleteConversation(for: customer, completion: {_ in})
            }
            menuItems.append(deleteAction)
            
            
            
            let vc = MenuController(actions: menuItems)
            self.present(vc, animated: true, completion: nil)
            completion(true)
        }
        moreAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "tab_more_inactive").withTintColor(.white), text: "More").withRenderingMode(.alwaysOriginal)
        moreAction.backgroundColor = .telaIndigo
        
        let detailsAction =  UIContextualAction(style: .normal, title: "Details", handler: { (action,view,completionHandler ) in
//            let vc = CustomerDetailsController(conversation: customer)
//            let navController = UINavigationController(rootViewController: vc)
//            DispatchQueue.main.async {
//                self.present(navController, animated: true)
//            }
            completionHandler(true)
        })
        detailsAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit").withTintColor(.white), text: "Details").withRenderingMode(.alwaysOriginal)
        detailsAction.backgroundColor = .systemPink
        let configuration = UISwipeActionsConfiguration(actions: [detailsAction, moreAction])
        
        return configuration
    }
    
    internal func openChat(forSelectedCustomer customer:Customer, at indexPath:IndexPath) {
        let id = customer.customerID
        guard
            id != 0,
            customer.node != nil else { return }
        printAndLog(message: "Conversation ID: \(customer.externalConversationID)\nNode: \(customer.node ?? "--")", log: .ui, logType: .info)
        let vc = MessagesController(customer: customer)
        navigationController?.pushViewController(vc, animated: true)
        viewDidAppear = false
    }
}


