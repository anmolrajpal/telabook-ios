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
        guard let context = agent.managedObjectContext else {
            fatalError("### \(#function) : Unable to retrieve managed object context from agent object:\n\(agent)")
        }
        let fetchRequest:NSFetchRequest<Customer> = Customer.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.propertiesToFetch = ["\(#keyPath(Customer.customerID))", "\(#keyPath(Customer.phoneNumber))", "\(#keyPath(Customer.addressBookName))", "\(#keyPath(Customer.colorCode))", "\(#keyPath(Customer.isPinned))", "\(#keyPath(Customer.lastMessageDateTime))"]
        
        let objectID = agent.objectID
        let contextAgent = context.object(with: objectID) as! Agent
        
        // Predicates
        let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", contextAgent)
        let isDeletedPredicate = NSPredicate(format: "\(#keyPath(Customer.isCustomerDeleted)) = %d", false)
        let isBlacklistedPredicate = NSPredicate(format: "\(#keyPath(Customer.isBlacklisted)) = %d", false)
        
        let aWeek = Date().subtract(days: 7)! as NSDate
        
        let inboxDatePredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) >= %@", aWeek)
        let unarchivedPredicate = NSPredicate(format: "\(#keyPath(Customer.isArchived)) = %d", false)
        let archivedPredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) < %@ OR \(#keyPath(Customer.isArchived)) = %d", aWeek, true)
        
        
        let inboxCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, inboxDatePredicate,  unarchivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
        let archivedCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, archivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
        
        

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Customer.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(Customer.lastMessageDateTime), ascending: false)
        ]
        
        if fetchedResultsController == nil {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        fetchedResultsController.fetchRequest.predicate = selectedSegment == .Inbox ? inboxCompoundPredicate : archivedCompoundPredicate
        performFetch()
    }
    internal func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
            fatalError("\(error.localizedDescription)")
        }
    }
}
extension CustomersViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        DispatchQueue.main.async {
            self.updateUI(animating: false, reloadingData: false)
        }
    }
}
