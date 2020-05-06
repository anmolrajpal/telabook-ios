//
//  QuickResponses+FetchedResultsHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import CoreData

extension QuickResponsesViewController {
    internal func setupFetchedResultsController() {
        let context = PersistentContainer.shared.viewContext
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        fetchRequest = QuickResponse.fetchRequest()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let agentPredicate = NSPredicate(format: "\(#keyPath(QuickResponse.sender)) == %@", agentRefrenceObject)
        let deletionCheckPredicate = NSPredicate(format: "\(#keyPath(QuickResponse.markForDeletion)) = %d", false)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [agentPredicate, deletionCheckPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(QuickResponse.updatedAt), ascending: false)]
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
extension QuickResponsesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSnapshot()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.updateSnapshot(animated: true)
    }
}
