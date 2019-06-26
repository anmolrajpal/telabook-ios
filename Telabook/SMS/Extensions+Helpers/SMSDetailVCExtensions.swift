//
//  SMSDetailVCExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension SMSDetailViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SMSDetailCell.self), for: indexPath) as! SMSDetailCell
        cell.backgroundColor = .clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        cell.accessoryType = .disclosureIndicator
        if let conversation = fetchedResultsController.object(at: indexPath) as? ExternalConversation {
            cell.externalConversation = conversation
        }
        return cell
    }
}
extension SMSDetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let conversation = fetchedResultsController.object(at: indexPath) as? ExternalConversation {
            let id = conversation.externalConversationId
            if id != 0,
                let node = conversation.node {
                let chatVC = ChatViewController(conversationId: String(id), node: node, conversation: conversation)
                chatVC.title = conversation.internalAddressBookName?.isEmpty ?? true ? conversation.customerPhoneNumber : conversation.internalAddressBookName
                navigationController?.pushViewController(chatVC, animated: true)
            }
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SMSDetailCell.cellHeight
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let archiveAction:UIContextualAction
        if self.segmentedControl.selectedSegmentIndex == 0 {
            archiveAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Archive") { (action, view, completion) in
                DispatchQueue.main.async {
                    self.initiateChatArchivingSequence(markArchive: true, indexPath: indexPath, completion: completion)
                }
            }
            archiveAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "archive"), text: "Archive").withRenderingMode(.alwaysOriginal)
        } else {
            archiveAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Unarchive") { (action, view, completion) in
                DispatchQueue.main.async {
                    self.initiateChatArchivingSequence(markArchive: false, indexPath: indexPath, completion: completion)
                }
            }
            archiveAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "archive"), text: "Unarchive").withRenderingMode(.alwaysOriginal)
        }
        
        archiveAction.backgroundColor = .telaBlue
        let colorAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Chat Color") { (action, view, completion) in
            DispatchQueue.main.async {
                self.promptChatColor(indexPath: indexPath)
                completion(true)
            }
        }
        colorAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "smiley_icon"), text: "Chat Color").withRenderingMode(.alwaysOriginal)
        colorAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [archiveAction, colorAction])
        return configuration
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let blockAction =  UIContextualAction(style: .destructive, title: "Block", handler: { (action,view,completion ) in
            self.initiateBlockNumberSequence(indexPath: indexPath, completion: completion)
        })
        blockAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "unblock"), text: "Block").withRenderingMode(.alwaysOriginal)
        blockAction.backgroundColor = .red
        
        let detailsAction =  UIContextualAction(style: .normal, title: "Details", handler: { (action,view,completionHandler ) in
            if let conversation = self.fetchedResultsController.object(at: indexPath) as? ExternalConversation {
                let customerId = Int(conversation.customerId)
                let workerId = Int(self.workerId)
                guard customerId != 0, workerId != 0 else {
                    print("Customer ID & Worker ID => 0")
                    return
                }
                let customerDetailsVC = CustomerDetailsViewController()
                customerDetailsVC.delegate = self
                customerDetailsVC.customerId = customerId
                customerDetailsVC.workerId = workerId
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
        detailsAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit"), text: "Details").withRenderingMode(.alwaysOriginal)
        detailsAction.backgroundColor = .orange
        let configuration = UISwipeActionsConfiguration(actions: [blockAction, detailsAction])
        
        return configuration
    }
}

extension SMSDetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        self.tableView.reloadDataWithLayout()
        tableView.reloadData()
        /*
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        default: break
        }
        */
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
    }
}
