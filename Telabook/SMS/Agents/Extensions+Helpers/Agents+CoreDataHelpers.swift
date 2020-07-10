//
//  Agents+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension AgentsViewController {
    internal func configureFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Agent> = Agent.fetchRequest()
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Agent.personName)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.personName), ascending: true)]
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.date), ascending: false)]
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
extension AgentsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        updateUI(reloadingData: true)
    }
}
