//
//  Customers+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension CustomersViewController {
    internal func setupFetchedResultsController() {
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.name)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Customer.name), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        } else {
            let aWeek = Date().subtract(days: 7)! as NSDate
            let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
            let inboxDatePredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) >= %@", aWeek)
            let unarchivedPredicate = NSPredicate(format: "\(#keyPath(Customer.isArchived)) = %d", false)
            let archivedPredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) < %@ OR \(#keyPath(Customer.isArchived)) = %d", aWeek, true)
            let isDeletedPredicate = NSPredicate(format: "\(#keyPath(Customer.isCustomerDeleted)) = %d", false)
            let isBlacklistedPredicate = NSPredicate(format: "\(#keyPath(Customer.isBlacklisted)) = %d", false)
            
            let inboxCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, inboxDatePredicate,  unarchivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
            let archivedCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, archivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
            
            fetchRequest.predicate = selectedSegment == .Inbox ? inboxCompoundPredicate : archivedCompoundPredicate
 
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(Customer.isPinned), ascending: false),
                NSSortDescriptor(key: #keyPath(Customer.lastMessageDateTime), ascending: false)
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        }
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
//            self.updateSnapshot(animated: true)
//            updateUI()
        } catch {
            print("Error fetching results: \(error)")
        }
    }
}
extension CustomersViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {   
//        self.updateSnapshot(animated: true)
        self.updateUI()
    }
}
