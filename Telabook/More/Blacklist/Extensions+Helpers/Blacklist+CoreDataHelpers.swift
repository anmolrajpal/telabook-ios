//
//  Blacklist+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension BlacklistViewController {
    internal func setupFetchedResultsController() {
        if viewContext == nil {
            viewContext = PersistentContainer.shared.viewContext
        }
        let fetchRequest:NSFetchRequest<BlockedUser> = BlockedUser.fetchRequest()
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(BlockedUser.phoneNumber)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BlockedUser.phoneNumber), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        } else {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(BlockedUser.isUnblocking)) = %d", false)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(BlockedUser.updatedAt), ascending: false)
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        }
        fetchedResultsController.delegate = self
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
extension BlacklistViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        DispatchQueue.main.async {
            self.updateUI(animating: true, reloadingData: true)
        }
    }
}

