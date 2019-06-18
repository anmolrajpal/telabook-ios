//
//  SMSVCExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension SMSViewController : UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredSearch.count
        } else {
            if let count = fetchedhResultController.sections?.first?.numberOfObjects {
                return count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SMSCell.self), for: indexPath) as! SMSCell
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        let conversation:InternalConversation
        if isSearching {
            conversation = self.filteredSearch[indexPath.row]
        } else {
            conversation = fetchedhResultController.object(at: indexPath) as! InternalConversation
        }
        cell.internalConversation = conversation
//        if let conversation = fetchedhResultController.object(at: indexPath) as? InternalConversation {
//            cell.internalConversation = conversation
//        }
        return cell
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchController.view.backgroundColor = UIColor.telaBlack.withAlphaComponent(0.6)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count == 0 {
            searchController.view.backgroundColor = UIColor.telaBlack.withAlphaComponent(0.6)
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            searchController.view.backgroundColor = .clear
            isSearching = true
            let convos = self.fetchedhResultController.fetchedObjects as! [InternalConversation]
            filteredSearch = convos.filter({$0.personName?.range(of: searchBar.text!, options: String.CompareOptions.caseInsensitive) != nil})
            tableView.reloadData()
        }
    }
}
extension SMSViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let conversation = fetchedhResultController.object(at: indexPath) as? InternalConversation {
        
            let smsDetailVC = SMSDetailViewController(conversation: conversation)
            navigationController?.pushViewController(smsDetailVC, animated: true)
            /*
            if !(self.externalConversations?.isEmpty ?? true) {
                let smsDetailVC = SMSDetailViewController(conversation: (self.externalConversations?[indexPath.row].internal)!)
                navigationController?.pushViewController(smsDetailVC, animated: true)
            } else {
                let smsDetailVC = SMSDetailViewController(conversation: conversation)
                navigationController?.pushViewController(smsDetailVC, animated: true)
            }
             */
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
