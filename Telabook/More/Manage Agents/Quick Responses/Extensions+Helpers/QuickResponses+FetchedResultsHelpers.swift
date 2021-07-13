//
//  QuickResponses+FetchedResultsHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension QuickResponsesViewController {
    internal func configureFetchedResultsController() {
        let context = PersistentContainer.shared.viewContext
        let fetchRequest:NSFetchRequest<QuickResponse> = QuickResponse.fetchRequest()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        
        let agentPredicate = NSPredicate(format: "\(#keyPath(QuickResponse.sender)) == %@", agentRefrenceObject)
        let deletionCheckPredicate = NSPredicate(format: "\(#keyPath(QuickResponse.markForDeletion)) = %d", false)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [agentPredicate, deletionCheckPredicate])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(QuickResponse.createdAt), ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        performFetch()
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to perform fetch on Quick Responses NSFetchedResultsController")
        }
    }
    
}
extension QuickResponsesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        updateUI(reloadingData: true)
    }
}
