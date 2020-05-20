//
//  Blacklist+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension BlacklistViewController {
    internal func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<BlockedUser> = BlockedUser.fetchRequest()
        let context = PersistentContainer.shared.viewContext
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(BlockedUser.phoneNumber)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BlockedUser.phoneNumber), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        } else {
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(BlockedUser.updatedAt), ascending: false)
            ]
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
extension BlacklistViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.updateSnapshot(animated: true)
    }
}

