//
//  SMSVCExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension SMSViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SMSCell.self), for: indexPath) as! SMSCell
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        if let conversation = fetchedhResultController.object(at: indexPath) as? InternalConversation {
            cell.internalConversation = conversation
        }
        return cell
    }
}
extension SMSViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let conversation = fetchedhResultController.object(at: indexPath) as? InternalConversation {
            let workerId = Int(conversation.workerId)
            let smsDetailVC = SMSDetailViewController()
            smsDetailVC.workerId = workerId
            
            print(self.externalConversations?.count ?? -1)
            print(self.externalConversations as Any)
            if self.externalConversations?.count ?? 0 > 0 {
                smsDetailVC.internalConversation = self.externalConversations?[indexPath.row].internal
            } else {
                smsDetailVC.internalConversation = conversation
            }
            //            smsDetailVC.navigationItem.title = "\(conversation.personName?.capitalized ?? "")"
            self.show(smsDetailVC, sender: self)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SMSCell.cellHeight
    }
    
}
extension SMSViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
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
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
