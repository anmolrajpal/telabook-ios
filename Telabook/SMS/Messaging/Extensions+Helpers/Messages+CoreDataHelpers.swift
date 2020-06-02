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
    /*
    internal func performInitialFetch() {
        do {
            NSFetchedResultsController<UserMessage>.deleteCache(withName: fetchedResultsController.cacheName)
            try fetchedResultsController.performFetch()
        } catch {
            #if !RELEASE
            print("Error fetching results: \(error)")
            #endif
            os_log("Core Data Error: %@", log: .coredata, type: .error, error.localizedDescription)
        }
    }
    */
    internal func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        
        fetchRequest.predicate = conversationPredicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(UserMessage.date), ascending: false)
        ]
//        fetchRequest.fetchBatchSize = 30
        fetchRequest.fetchLimit = self.limit
        
        fetchRequest.returnsObjectsAsFaults = true
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
//            self.messagesCollectionView.scrollToBottom(animated: false)
        } catch {
            #if !RELEASE
            print("Error fetching results: \(error)")
            #endif
            os_log("Core Data Error: %@", log: .coredata, type: .error, error.localizedDescription)
        }
    }
 
}
extension MessagesController: NSFetchedResultsControllerDelegate {
    

    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        
        
        DispatchQueue.main.async {
            if self.isFirstLayout {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: false)
            } else {
                self.reloadDataKeepingOffset()
            }
            self.isFirstLayout = false
            if self.isFetchedResultsAvailable == true { self.stopSpinner() }
            if self.isLastSectionVisible() == true {
                self.messagesCollectionView.scrollToBottom(animated: true)
            } else if let lastRefreshedTime = self.fetchedResults?.last?.lastRefreshedAt {
                if self.screenEntryTime > lastRefreshedTime {
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
        }
        
        
        
//        self.messagesCollectionView.reloadData()
//        self.messagesCollectionView.scrollToBottom()
        
        /*
        messagesCollectionView.performBatchUpdates({
            for change in diff {
//                print("did change with difference of type: \(change)")
                switch change {
                    case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                        if let oldRow = assoc {
                            messagesCollectionView.moveSection(oldRow, toSection: newRow)
//                            messagesCollectionView.moveItem(at: IndexPath(row: oldRow, section: 0), to: IndexPath(row: newRow, section: 0))
                        } else {
                            messagesCollectionView.insertSections([newRow])
//                            messagesCollectionView.insertItems(at: [IndexPath(row: newRow, section: 0)])
                    }
                    
                    case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                        if assoc == nil {
//                            messagesCollectionView.deleteItems(at: [IndexPath(row: oldRow, section: 0)])
                            messagesCollectionView.deleteSections([oldRow])
                    }
                }
            }
        }, completion: { [weak self] finished in
            
            
            
//            self?.collectionViewOperations.removeAll(keepingCapacity: false)
            //                self.messagesCollectionView.scrollToBottom()
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            } else if let lastRefreshedTime = self?.fetchedResults?.last?.lastRefreshedAt,
                let screenEntryTime = self?.screenEntryTime {
                if screenEntryTime > lastRefreshedTime {
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
            if self?.isFetchedResultsAvailable == true { self?.stopSpinner() }
        })
         */
    }
    
    
    
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       collectionViewOperations.removeAll(keepingCapacity: false)
   }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let operation: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            print(newIndexPath)
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.insertItems(at: [IndexPath(item: 0, section: newIndexPath.row)]) }
//            operation = BlockOperation { [weak self] in self?.messagesCollectionView.insertSections([newIndexPath.row]) }
        case .delete:
            guard let indexPath = indexPath else { return }
//            operation = BlockOperation { [weak self] in self?.messagesCollectionView.deleteItems(at: [indexPath]) }
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.deleteSections([indexPath.row]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.moveSection(indexPath.row, toSection: newIndexPath.row) }
        case .update:
            guard let indexPath = indexPath else { return }
//            operation = BlockOperation { [weak self] in self?.messagesCollectionView.reloadItems(at: [indexPath]) }
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.reloadSections([indexPath.row]) }
            
//        @unknown default: fatalError("Unhandled Case")
            default: return
        }
        collectionViewOperations.append(operation)
    }
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*
        messagesCollectionView.reloadData()
        if self.isLastSectionVisible() == true {
            self.messagesCollectionView.scrollToBottom(animated: true)
        } else if let messageSentTime = self.fetchedResults?.first?.date,
            self.screenEntryTime > messageSentTime {
            self.messagesCollectionView.scrollToBottom(animated: false)
        }
        if self.isFetchedResultsAvailable { self.stopSpinner() }
        */
        
        
        DispatchQueue.main.async {
            self.messagesCollectionView.performBatchUpdates({
                self.collectionViewOperations.forEach { $0.start() }
            }, completion: { [weak self] finished in
                self?.collectionViewOperations.removeAll(keepingCapacity: false)
                //                self.messagesCollectionView.scrollToBottom()
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                } else if let lastRefreshedTime = self?.fetchedResults?.last?.lastRefreshedAt,
                    let screenEntryTime = self?.screenEntryTime {
                    if screenEntryTime > lastRefreshedTime {
                        self?.messagesCollectionView.scrollToBottom(animated: false)
                    }
                }
                if self?.isFetchedResultsAvailable == true { self?.stopSpinner() }
            })
        }
        
        
    }
}
