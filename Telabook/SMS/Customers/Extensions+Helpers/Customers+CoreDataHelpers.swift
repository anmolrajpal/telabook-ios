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
    internal func configureFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Customer> = Customer.fetchRequest()
        let objectID = agent.objectID
        let contextAgent = context.object(with: objectID) as! Agent
        
        // Predicates
        let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", contextAgent)
        let isDeletedPredicate = NSPredicate(format: "\(#keyPath(Customer.isCustomerDeleted)) = %d", false)
        let isBlacklistedPredicate = NSPredicate(format: "\(#keyPath(Customer.isBlacklisted)) = %d", false)
        
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.name)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Customer.name), ascending: true)]
            
        } else {
            let aWeek = Date().subtract(days: 7)! as NSDate
            
            let inboxDatePredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) >= %@", aWeek)
            let unarchivedPredicate = NSPredicate(format: "\(#keyPath(Customer.isArchived)) = %d", false)
            let archivedPredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) < %@ OR \(#keyPath(Customer.isArchived)) = %d", aWeek, true)
            
            
            let inboxCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, inboxDatePredicate,  unarchivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
            let archivedCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, archivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
            
            fetchRequest.predicate = selectedSegment == .Inbox ? inboxCompoundPredicate : archivedCompoundPredicate
 
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(Customer.isPinned), ascending: false),
                NSSortDescriptor(key: #keyPath(Customer.lastMessageDateTime), ascending: false)
            ]
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        performFetch()
    }
    internal func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
        }
    }
}
extension CustomersViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.updateUI()
    }
}
