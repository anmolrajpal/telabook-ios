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
    
    func inboxPredicate() -> NSPredicate  {
        // Predicates
        let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
        let isDeletedPredicate = NSPredicate(format: "\(#keyPath(Customer.isCustomerDeleted)) = %d", false)
        let isBlacklistedPredicate = NSPredicate(format: "\(#keyPath(Customer.isBlacklisted)) = %d", false)
        
        let aWeek = Date().subtract(days: 7)! as NSDate
        
        let inboxDatePredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) >= %@", aWeek)
        let unarchivedPredicate = NSPredicate(format: "\(#keyPath(Customer.isArchived)) = %d", false)
        
        
        let inboxCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, inboxDatePredicate,  unarchivedPredicate, isBlacklistedPredicate, isDeletedPredicate])

        
        return inboxCompoundPredicate
    }
    func archivedPredicate() -> NSPredicate  {

        // Predicates
        let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
        let isDeletedPredicate = NSPredicate(format: "\(#keyPath(Customer.isCustomerDeleted)) = %d", false)
        let isBlacklistedPredicate = NSPredicate(format: "\(#keyPath(Customer.isBlacklisted)) = %d", false)
        
        let aWeek = Date().subtract(days: 7)! as NSDate
        
        let archivedPredicate = NSPredicate(format: "\(#keyPath(Customer.lastMessageDateTime)) < %@ OR \(#keyPath(Customer.isArchived)) = %d", aWeek, true)
        let archivedCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [agentPredicate, archivedPredicate, isBlacklistedPredicate, isDeletedPredicate])
        
        
        return archivedCompoundPredicate
    }
    internal func configureFetchedResultsController() {
        guard let context = agent.managedObjectContext else {
            fatalError("### \(#function) : Unable to retrieve managed object context from agent object:\n\(agent)")
        }
        /*
        guard let context = agent.managedObjectContext else {
            fatalError("### \(#function) : Unable to retrieve managed object context from agent object:\n\(agent)")
        }
        let fetchRequest:NSFetchRequest<Customer> = Customer.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.propertiesToFetch = ["\(#keyPath(Customer.customerID))", "\(#keyPath(Customer.phoneNumber))", "\(#keyPath(Customer.addressBookName))", "\(#keyPath(Customer.colorCode))", "\(#keyPath(Customer.isPinned))", "\(#keyPath(Customer.lastMessageDateTime))", "\(#keyPath(Customer.messageType))"]
        
//        let objectID = agent.objectID
//        let contextAgent = context.object(with: objectID) as! Agent
        
        // Predicates
        let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
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
        */
        
        if fetchedResultsController == nil {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        fetchedResultsController.fetchRequest.predicate = selectedSegment == .Inbox ? inboxPredicate() : archivedPredicate()
        
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
        /*
        // Cast the snapshot reference to a snapshot
            let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

            // Create a new snapshot with the value object as item identifier
            var mySnapshot = NSDiffableDataSourceSnapshot<String, Customer>()

            // Copy the sections from the fetched results controller's snapshot
            mySnapshot.appendSections(snapshot.sectionIdentifiers)

            // For each section, map the item identifiers (NSManagedObjectID) from the
            // fetched result controller's snapshot to managed objects (Task) and
            // then to value objects (TaskItem), before adding to the new snapshot
            mySnapshot.sectionIdentifiers.forEach { section in
                let itemIdentifiers = snapshot.itemIdentifiers(inSection: section)
                    .map { context.object(with: $0) as! Customer }
//                    .map { Customer(context: context, conversationToUpdate: $0) }

                mySnapshot.appendItems(itemIdentifiers, toSection: section)
            }

            // Apply the snapshot, animating differences unless not in a window
        DispatchQueue.main.async {
            self.dataSource.apply(mySnapshot, animatingDifferences: self.view.window != nil)
        }
            */
        
        /*
        guard let dataSource = tableView.dataSource as? CustomerDataSource else {
                fatalError("The data source has not implemented snapshot support while it should")
            }
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, animatingDifferences: tableView.numberOfSections != 0)
        dataSource.applySnapshot(snapshot, animatingDifferences: true)
        */
        /*
        guard let dataSource = tableView.dataSource as? UITableViewDiffableDataSource<Int, NSManagedObjectID> else {
                assertionFailure("The data source has not implemented snapshot support while it should")
                return
            }
            var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
            let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

            let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
                guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier),
                      let index = snapshot.indexOfItem(itemIdentifier),
                      index == currentIndex else {
                    return nil
                }
                guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
                return itemIdentifier
            }
            snapshot.reloadItems(reloadIdentifiers)

            let shouldAnimate = tableView.numberOfSections != 0
            dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: shouldAnimate)
        */
        DispatchQueue.main.async {
            self.updateUI(animating: true, reloadingData: true)
        }
//        DispatchQueue.main.async {
//        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>, animatingDifferences: true) {
//            self.dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>, animatingDifferences: false)
//        }
//        }
        
        
//        guard let snapshot = currentSnapshot(), dataSource != nil else { return }
//        dataSource.apply(snapshot, animatingDifferences: true, completion: { [weak self] in
//            guard let self = self else { return }
//            self.dataSource.apply(snapshot, animatingDifferences: false)
//            self.handleState()
//        })
        
        
    }
}
