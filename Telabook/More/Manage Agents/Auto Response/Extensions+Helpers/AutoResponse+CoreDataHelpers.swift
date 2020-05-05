//
//  AutoResponse+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension AutoResponseViewController {
    internal func setupFetchedResultsController() {
        let context = PersistentContainer.shared.viewContext
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        fetchRequest = AutoResponse.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(AutoResponse.autoResponseSender)) == %@", agentRefrenceObject)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(AutoResponse.lastRefreshedAt), ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: String(describing: self))
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            updateSnapshot()
        } catch {
            print("Error fetching results: \(error)")
        }
    }
}
extension AutoResponseViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSnapshot()
    }
}
