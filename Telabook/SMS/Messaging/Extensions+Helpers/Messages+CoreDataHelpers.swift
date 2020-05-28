//
//  Messages+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
import os
extension MessagesController {
    internal func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        
        fetchRequest.predicate = conversationPredicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(UserMessage.date), ascending: false)
        ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            #if !RELEASE
            print("Error fetching results: \(error)")
            #endif
            os_log("Core Data Error: %@", log: .coredata, type: .error, error.localizedDescription)
        }
    }
}
extension MessagesController: NSFetchedResultsControllerDelegate {
    /*
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionViewOperations.removeAll(keepingCapacity: false)
    }
    /*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        print("did change with difference")
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
        /*
        messagesCollectionView.performBatchUpdates({
            for change in diff {
                switch change {
                    case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                        if let oldRow = assoc {
                            messagesCollectionView.moveItem(at: IndexPath(row: oldRow, section: 0), to: IndexPath(row: newRow, section: 0))
                        } else {
                            messagesCollectionView.insertItems(at: [IndexPath(row: newRow, section: 0)])
                    }
                    
                    case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                        if assoc == nil {
                            messagesCollectionView.deleteItems(at: [IndexPath(row: oldRow, section: 0)])
                    }
                }
            }
        }, completion: nil)
         */
    }
    */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("Section change")
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let operation: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.insertItems(at: [newIndexPath]) }
        case .delete:
            guard let indexPath = indexPath else { return }
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.deleteItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.moveItem(at: indexPath, to: newIndexPath) }
//        case .update:
//            guard let indexPath = indexPath else { return }
//            operation = BlockOperation { [weak self] in self?.messagesCollectionView.reloadItems(at: [indexPath]) }
            
//        @unknown default: fatalError("Unhandled Case")
            default: return
        }
        collectionViewOperations.append(operation)
    }
 */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        messagesCollectionView.reloadData()
        if self.isLastSectionVisible() == true {
            self.messagesCollectionView.scrollToBottom(animated: true)
        } else if let messageSentTime = self.fetchedResults?.first?.date,
            self.screenEntryTime > messageSentTime {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        if self.isFetchedResultsAvailable { self.stopSpinner() }
        /*
            messagesCollectionView.performBatchUpdates({
                self.collectionViewOperations.forEach { $0.start() }
            }, completion: { [weak self] finished in
                self?.collectionViewOperations.removeAll(keepingCapacity: false)
//                self.messagesCollectionView.scrollToBottom()
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            })
         */
        }
}
