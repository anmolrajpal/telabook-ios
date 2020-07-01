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

import MessageKit




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
        let datePredicate = NSPredicate(format: "\(#keyPath(UserMessage.updatedAt)) >= %@", screenEntryTime as NSDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conversationPredicate, datePredicate])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserMessage.date, ascending: true)]
//        fetchRequest.fetchLimit = self.limit
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        performFetch()
    }
 
}
extension MessagesController: NSFetchedResultsControllerDelegate {
    /*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        messagesCollectionView.performBatchUpdates({
            let count = controller.sections?.first?.numberOfObjects ?? 0
//            print(count)
            for change in diff {
                switch change {
                    case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                        let newSection = count - 1 - newRow
                        
                        if let oldRow = assoc {
                            let oldSection = count - 1 - oldRow
                            guard oldSection < count else { break }
                            print("Moving Old Section: \(oldSection) to New Section: \(newSection) where messages count = \(count) | where core data old indexPath row = \(oldRow) & New IndexPath row = \(newRow)")
                            messagesCollectionView.moveSection(oldSection, toSection: newSection)
                        } else {
                            print("Inserting Section: \(newSection) when messages count = \(count) | from core data indexPath row = \(newRow)")
                            messagesCollectionView.insertSections([newSection])
                    }
                    
                    case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                        let section = count - 1 - oldRow
                        if assoc == nil {
                            print("Deleting Section: \(section) when messages count = \(count) | where core data indexPath row = \(oldRow)")
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
    
   /*
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       collectionViewOperations.removeAll(keepingCapacity: false)
   }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let operation: BlockOperation
        let count = controller.fetchedObjects?.count ?? 0
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            let section = count - 1 - newIndexPath.row
            print("Inserting Section: \(section) when messages count = \(count) | from core data indexPath row = \(newIndexPath.row)")
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.insertSections([section]) }
        case .delete:
            guard let indexPath = indexPath else { return }
            let section = count - 1 - indexPath.row
            print("Deleting Section: \(section) when messages count = \(count) | from core data indexPath row = \(indexPath.row)")
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.deleteSections([section]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            let oldSection = count - 1 - indexPath.row
            let newSection = count - 1 - newIndexPath.row
            print("Moving Section: \(oldSection) when messages count = \(count) | from core data indexPath row = \(indexPath.row)\n To New Section: \(newSection) when messages count = \(count) | from core data indexPath row = \(newIndexPath.row)")
            operation = BlockOperation { [weak self] in self?.messagesCollectionView.moveSection(oldSection, toSection: newSection) }
        case .update:
            guard let indexPath = indexPath else { return }
            let section = count - 1 - indexPath.row
            print("Updating Section: \(section) when messages count = \(count) | from core data indexPath row = \(indexPath.row)")
            
            operation = BlockOperation { [weak self] in
                if let messagesCollectionView = self?.messagesCollectionView,
                    let cell = messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: section)) as? MessageContentCell,
                    let message = controller.object(at: indexPath) as? UserMessage {
                    cell.configure(with: message, at: IndexPath(item: 0, section: section), and: messagesCollectionView)
                }
//                self?.messagesCollectionView.reloadSections([section])
            }
            default: return
        }
        collectionViewOperations.append(operation)
    }
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.messagesCollectionView.performBatchUpdates({
            self.collectionViewOperations.forEach { $0.start() }
        }, completion: { [weak self] finished in
            self?.collectionViewOperations.removeAll(keepingCapacity: false)
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            } else if let lastRefreshedTime = self?.messages.last?.lastRefreshedAt,
                let screenEntryTime = self?.screenEntryTime {
                if screenEntryTime > lastRefreshedTime {
                    self?.messagesCollectionView.scrollToBottom(animated: false)
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
    }
    */
    
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           collectionViewOperations.removeAll(keepingCapacity: false)
       }
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            let operation: BlockOperation
//            let count = controller.fetchedObjects?.count ?? 0
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
//                print("Inserting Section: \(section) when messages count = \(count) | from core data indexPath row = \(newIndexPath.row)")
                let message = controller.object(at: newIndexPath) as! UserMessage
                
                
                operation = BlockOperation { [weak self] in
                    guard let self = self else { return }
                    if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
//                        print("Core Data<Insert Case>: Updating existing message at section : \(index) where message:\n\(message) when messages count = \(self.messages.count)")
                        self.messages[index] = message
                        let indexPath = IndexPath(item: 0, section: index)
                        let messagesCollectionView = self.messagesCollectionView
                        if case .photo = message.kind {
                            if let cell = messagesCollectionView.cellForItem(at: indexPath) as? MMSCell {
                                cell.configure(with: message, at: indexPath, and: messagesCollectionView, upload: self.uploadService.activeUploads[message.imageURL!], download: self.downloadService.activeDownloads[message.imageURL!], shouldAutoDownload: self.shouldAutoDownloadImageMessages)
                            }
                        } else {
                            if let cell = messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell {
                                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                            }
                        }
                    } else {
//                        print("Core Data<Insert Case>: Inserting new message at core data indexPath: \(newIndexPath) & message: \(message) when messages count = \(self.messages.count)")
                        self.messages.append(message)
                        self.messagesCollectionView.insertSections([self.messages.count - 1])
                        if self.messages.count >= 2 {
                            self.messagesCollectionView.reloadSections([self.messages.count - 2])
                        }
                    }
                }
            case .delete:
                guard let indexPath = indexPath else { return }
                print("Core Data: Delete case triggered at core data indexPath: \(indexPath) when messages count = \(self.messages.count)")
                return
//                let section = self.messages.count - 1 - indexPath.row
//                print("Deleting Section: \(section) where core data indexPath: \(indexPath) when messages count = \(self.messages.count)")
//                operation = BlockOperation { [weak self] in self?.messagesCollectionView.deleteSections([section]) }
            case .move:
                guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
                fatalError("Core Data Move case triggered from core data old indexPath: \(indexPath) to new indexPath: \(newIndexPath) when messages count = \(self.messages.count)")
//                let oldSection = count - 1 - indexPath.row
//                let newSection = count - 1 - newIndexPath.row
//                print("Moving Section: \(oldSection) when messages count = \(count) | from core data indexPath row = \(indexPath.row)\n To New Section: \(newSection) when messages count = \(count) | from core data indexPath row = \(newIndexPath.row)")
//                operation = BlockOperation { [weak self] in self?.messagesCollectionView.moveSection(oldSection, toSection: newSection) }
            case .update:
                guard let indexPath = indexPath else { return }
                let message = controller.object(at: indexPath) as! UserMessage
                
//                let section = count - 1 - indexPath.row
//                print("Updating Section: \(section) when messages count = \(count) | from core data indexPath row = \(indexPath.row)")
                
                operation = BlockOperation { [weak self] in
                    guard let self = self else { return }
                    if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
//                        print("Core Data<Update Case>: Updating message at section: \(index) | message:\n \(message) when messages count = \(self.messages.count)")
                        self.messages[index] = message
                        let indexPath = IndexPath(item: 0, section: index)
                        let messagesCollectionView = self.messagesCollectionView
                        if case .photo = message.kind {
                            if let cell = messagesCollectionView.cellForItem(at: indexPath) as? MMSCell {
                                cell.configure(with: message, at: indexPath, and: messagesCollectionView, upload: self.uploadService.activeUploads[message.imageURL!], download: self.downloadService.activeDownloads[message.imageURL!], shouldAutoDownload: self.shouldAutoDownloadImageMessages)
                            }
                        } else {
                            if let cell = messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell {
                                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                            }
                        }
                    }
    //                self?.messagesCollectionView.reloadSections([section])
                }
                default: fatalError()
            }
            collectionViewOperations.append(operation)
        }
     
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.messagesCollectionView.performBatchUpdates({
                self.collectionViewOperations.forEach { $0.start() }
            }, completion: { [weak self] finished in
                self?.collectionViewOperations.removeAll(keepingCapacity: false)
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                } else if let lastRefreshedTime = self?.messages.last?.lastRefreshedAt,
                    let screenEntryTime = self?.screenEntryTime {
                    if screenEntryTime > lastRefreshedTime {
                        self?.messagesCollectionView.scrollToBottom(animated: false)
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
        }
}








