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
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.name)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Customer.name), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        } else {
            let aWeek = Date().subtract(days: 7)! as NSDate
            if selectedSegment == .Inbox {
                fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@ AND \(#keyPath(Customer.lastMessageDateTime)) >= %@ AND \(#keyPath(Customer.isArchived)) = %d AND \(#keyPath(Customer.isCustomerDeleted)) = %d", agent, aWeek, false, false)
            } else {
                fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@ AND \(#keyPath(Customer.lastMessageDateTime)) < %@ OR \(#keyPath(Customer.isArchived)) = %d AND \(#keyPath(Customer.isCustomerDeleted)) = %d", agent, aWeek, true, false)
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
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {   
        self.updateSnapshot(animated: true)
    }
}
