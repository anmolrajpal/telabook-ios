//
//  CallsTabAgents+CoreData.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension CallsTabAgentsViewController {
    internal func configureFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Agent> = Agent.fetchRequest()
        if !currentSearchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Agent.personName)) CONTAINS[c] %@", currentSearchText)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.personName), ascending: true)]
        } else {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Agent.isDisabled)) = %d", showOnlyDisabledAccounts)
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
extension CallsTabAgentsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        updateUI(reloadingData: true)
    }
}
