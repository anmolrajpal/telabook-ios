//
//  Customers+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension CustomersViewController {
    internal func setupFetchedResultsController() {
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.name)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Customer.name), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        } else {
            if selectedSegment == .Inbox {
                fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.isArchived)) = %d AND \(#keyPath(Customer.isCustomerDeleted)) = %d AND \(#keyPath(Customer.agent)) == %@", false, false, agent)
            } else {
                fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.isArchived)) = %d AND \(#keyPath(Customer.isCustomerDeleted)) = %d AND \(#keyPath(Customer.agent)) == %@", true, false, agent)
            }
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Customer.lastMessageDateTime), ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        }
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            self.updateSnapshot(animated: true)
        } catch {
            print("Error fetching results: \(error)")
        }
    }
}
extension CustomersViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSnapshot()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.updateSnapshot(animated: true)
    }
}
