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
    
    internal func performFetch() {
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
    
    internal func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        
        fetchRequest.predicate = conversationPredicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserMessage.date, ascending: false)
        ]
//        fetchRequest.fetchBatchSize = self.limit * 2
        fetchRequest.fetchLimit = self.limit
//        fetchRequest.propertiesToFetch = [
//            "firebaseKey",
//            "textMessage",
//            "date"
//        ]
//        fetchRequest.returnsObjectsAsFaults = true
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        /*
        do {
            try fetchedResultsController.performFetch()
//            self.messagesCollectionView.scrollToBottom(animated: false)
        } catch {
            #if !RELEASE
            print("Error fetching results: \(error)")
            #endif
            os_log("Core Data Error: %@", log: .coredata, type: .error, error.localizedDescription)
        }
         */
    }
 
}
extension MessagesController: NSFetchedResultsControllerDelegate {
    /*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        messagesCollectionView.performBatchUpdates({
            let count = messages.count
//            print(count)
            for change in diff {
                switch change {
                    case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                        let newSection = count - 1 - newRow
                        if let oldRow = assoc {
                            let oldSection = count - 1 - oldRow
                            messagesCollectionView.moveSection(oldSection, toSection: newSection)
                        } else {
                            messagesCollectionView.insertSections([newSection])
                    }
                    
                    case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                        let section = count - 1 - oldRow
                        if assoc == nil {
                            messagesCollectionView.deleteSections([section])
                    }
                }
            }
        }, completion: { [weak self] finished in
            if self?.messages.isEmpty == true { self?.stopSpinner() }
            self?.messagesCollectionView.layoutIfNeeded()
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            } else if let lastRefreshedTime = self?.messages.last?.lastRefreshedAt,
                let screenEntryTime = self?.screenEntryTime {
                if screenEntryTime > lastRefreshedTime {
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
            if self?.didSentNewMessage == true, let sections = self?.messagesCollectionView.indexPathsForVisibleItems.compactMap({ $0.section }),
                let secondLastSection = sections.secondLargest() {
                self?.didSentNewMessage = false
                self?.messagesCollectionView.reloadSections([secondLastSection])
                self?.messagesCollectionView.layoutIfNeeded()
            //  sections.forEach({ self?.messagesCollectionView.reloadSections([$0]) })
            }
        })
    }
 */
    /*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        
        /*
        DispatchQueue.main.async {
            if self.isFirstLayout {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.layoutIfNeeded()
                self.messagesCollectionView.scrollToBottom(animated: false)
            } else {
                self.reloadDataKeepingOffset()
            }
            self.isFirstLayout = false
            if !self.messages.isEmpty == true { self.stopSpinner() }
            if self.isLastSectionVisible() == true {
                self.messagesCollectionView.scrollToBottom(animated: true)
            } else if let lastRefreshedTime = self.messages.last?.lastRefreshedAt {
                if self.screenEntryTime > lastRefreshedTime {
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
        }
        */
        
        
//        self.messagesCollectionView.reloadData()
//        self.messagesCollectionView.scrollToBottom()
        
        
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
            self?.messagesCollectionView.layoutIfNeeded()
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            } else if let lastRefreshedTime = self?.messages.last?.lastRefreshedAt,
                let screenEntryTime = self?.screenEntryTime {
                if screenEntryTime > lastRefreshedTime {
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
            if (self?.messages.isEmpty ?? true) { self?.stopSpinner() }
        })
         
    }
    */
    
    
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       collectionViewOperations.removeAll(keepingCapacity: false)
   }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let operation: BlockOperation
        let count = messages.count
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            let section = count - 1 - newIndexPath.row
            print(section)
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.insertSections([section]) }
        case .delete:
            guard let indexPath = indexPath else { return }
            let section = messages.count - 1 - indexPath.row
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.deleteSections([section]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            let oldSection = messages.count - 1 - indexPath.row
            let newSection = messages.count - 1 - newIndexPath.row
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.moveSection(oldSection, toSection: newSection) }
        case .update:
            guard let indexPath = indexPath else { return }
            let section = count - 1 - indexPath.row
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.reloadSections([section]) }
            default: return
        }
        collectionViewOperations.append(operation)
    }
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        DispatchQueue.main.async {
            self.messagesCollectionView.performBatchUpdates({
                self.collectionViewOperations.forEach { $0.start() }
            }, completion: { [weak self] finished in
                self?.collectionViewOperations.removeAll(keepingCapacity: false)
                
                self?.messagesCollectionView.layoutIfNeeded()
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                } else if let lastRefreshedTime = self?.messages.last?.lastRefreshedAt,
                    let screenEntryTime = self?.screenEntryTime {
                    if screenEntryTime > lastRefreshedTime {
                        print("Should scroll to bottom")
//                        DispatchQueue.main.async {
                            self?.messagesCollectionView.scrollToBottom(animated: false)
//                        }
                    }
                }
                if self?.messages.isEmpty == true { self?.stopSpinner() }
                if self?.didSentNewMessage == true, let sections = self?.messagesCollectionView.indexPathsForVisibleItems.compactMap({ $0.section }),
                    let secondLastSection = sections.secondLargest() {
                    self?.didSentNewMessage = false
                    self?.messagesCollectionView.reloadSections([secondLastSection])
                    self?.messagesCollectionView.layoutIfNeeded()
                }
            })
//        }
    }
}








