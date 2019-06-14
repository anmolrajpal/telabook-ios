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
            print("FRC Count => \(count)")
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
            print("Person Name at indexpath \(indexPath.row) => \(conversation.internalAddressBookName ?? "null")")
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
                let chatVC = ChatViewController(conversationId: String(id), node: node)
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
            archiveAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Archive") { (action, view, completion) in
                DispatchQueue.main.async {
                    self.initiateChatArchivingSequence(markArchive: true, indexPath: indexPath, completion: completion)
                }
            }
        } else {
            archiveAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Unarchive") { (action, view, completion) in
                DispatchQueue.main.async {
                    self.initiateChatArchivingSequence(markArchive: false, indexPath: indexPath, completion: completion)
                }
            }
        }
        archiveAction.image = #imageLiteral(resourceName: "archive")
        archiveAction.backgroundColor = .telaBlue
        let colorAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Chat Color") { (action, view, completion) in
            DispatchQueue.main.async {
                self.promptChatColor(indexPath: indexPath)
                completion(true)
            }
        }
        colorAction.image = #imageLiteral(resourceName: "edit")
        colorAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [archiveAction, colorAction])
        return configuration
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let blockAction =  UIContextualAction(style: .normal, title: "Block", handler: { (action,view,completionHandler ) in
            //do stuff
            completionHandler(true)
        })
        blockAction.image = #imageLiteral(resourceName: "unblock")
        blockAction.backgroundColor = .red
        
        let detailsAction =  UIContextualAction(style: .normal, title: "Details", handler: { (action,view,completionHandler ) in
            //do stuff
            completionHandler(true)
        })
        detailsAction.image = #imageLiteral(resourceName: "radio_active")
        detailsAction.backgroundColor = .orange
        
        let archiveAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Archive") { (action, view, completion) in
            completion(true)
        }
        archiveAction.image = #imageLiteral(resourceName: "archive")
        archiveAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [blockAction, detailsAction])
        
        return configuration
    }
}

extension SMSDetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("did change object check")
        self.tableView.reloadData()
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
