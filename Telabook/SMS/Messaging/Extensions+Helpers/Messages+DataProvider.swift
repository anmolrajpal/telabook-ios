//
//  Messages+DataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase
import os
import CoreData

extension MessagesController {
    
    // MARK: - Firebase Methods
    
    
    
    func observeNewMessages() -> UInt {
//        print("Screen Entry Time: \(screenEntryTime.milliSecondsSince1970)")
        return reference.queryOrdered(byChild: "date").queryStarting(atValue: screenEntryTime.milliSecondsSince1970).observe(.childAdded, with: { [weak self] snapshot in
            guard let self = self else { return }
            if snapshot.exists() {
//                print("-------------------\n\nNew Message Child Added Snapshot:\n\n \(snapshot)\n\n-------------------\n\n")
                guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                    return
                }
//                print("----------------\n\n### \(#function) - Adding new Message: \n\n\(message)\n\n----------------\n\n")
                self.persistFirebaseMessageInStore(entry: message)
            }
        }) { error in
            printAndLog(message: "### \(#function) - Firebase Child Added Observer Event Error while observing new Messages: \(error)", log: .firebase, logType: .error)
        }
    }
    
    func observeExistingMessages() -> UInt {
        return reference.queryOrdered(byChild: "date").queryStarting(atValue: screenEntryTime.milliSecondsSince1970).observe(.childChanged, with: { [weak self] snapshot in
            guard let self = self else { return }
            if snapshot.exists() {
//                print("-------------\n\nExisting Message Child Updated Snapshot: \n\n\(snapshot)\n\n-------------------")
                guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                    return
                }
//                print("----------------\n\n### \(#function) - Message to update: \n\n\(message)\n\n----------------\n\n")
                self.persistFirebaseMessageInStore(entry: message)
            }
        }) { error in
            printAndLog(message: "### \(#function) - Firebase Child changed Observer Event Error while observing existing Messages: \(error)", log: .firebase, logType: .error)
        }
    }
    
    
    
    
    
    
    func loadInitialMessagesFromFirebase() {
        //        print("Loading Initial Messages from Firebase")
//        print("### \(#function) called")
        if messages.isEmpty { self.startSpinner() }
        let limit = self.limit
        reference.queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            guard snapshot.exists() else {
                self.messages = []
                self.shouldFetchMore = false
//                printAndLog(message: "### \(#function) Snapshot does not exists. Return()", log: .firebase, logType: .info)
                return
            }
//            print("----------------\n\n### \(#function) - Load initial messages snapshot: \n\n\(snapshot)\n\n----------------\n\n")
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) {
                        messages.append(message)
                    }
                }
            }
            if messages.count < limit {
                self.shouldFetchMore = false
            }
//            print("----------------\n\n### \(#function) - inserting initial messages: \n\n\(messages)\n\n----------------\n\n")
            self.persistInitialFirebaseMessagesInStore(entries: messages, fetchedEntries: nil)
        }) { error in
            let errorMessage = "Firebase Single Event Observer Error while observing Messages: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    
    
    
    
    func upsertExistingMessagesFromFirebase(fetchedMessages:[UserMessage]) {
//        print("### \(#function) called")
        let initialMessage = fetchedMessages.last!
        let initialMessageKey = initialMessage.messageId
        let limit = self.limit
//        print("### \(#function) Initial Message: \(initialMessage) where fetched Messages count = \(fetchedMessages.count)")
        reference.queryOrderedByKey().queryEnding(atValue: initialMessageKey).queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            guard snapshot.exists() else {
                
//                printAndLog(message: "### \(#function) Snapshot does not exists. Return()", log: .firebase, logType: .info)
                return
            }
//            print("----------------\n\n### \(#function) - Upserting existing messages snapshot: \n\n\(snapshot)\n\n----------------\n\n")
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) {
                        messages.append(message)
                    }
                }
            }
            if messages.count < limit {
                self.shouldFetchMore = false
            }
//            print("---------------------\n\n### \(#function) Upserting Firebase messages with count: \(messages.count) ; messages: \n\(messages)\n\n---------------------")
            self.persistInitialFirebaseMessagesInStore(entries: Array(messages), fetchedEntries: fetchedMessages)
        }) { error in
            let errorMessage = "Firebase Single Event Observer Error while observing Messages: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    
    
    
    
    func upsertUnseenMessagesFromFirebase(previousMessage:UserMessage, fetchedMessages:[UserMessage]) {
//        print("### \(#function) - Previous Message: \(previousMessage)")
        let previousMessageKey = previousMessage.messageId
        reference.queryOrderedByKey().queryStarting(atValue: previousMessageKey).queryLimited(toLast: UInt(unseenFetchLimit)).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            guard snapshot.exists() else {
//                printAndLog(message: "### \(#function) Snapshot does not exists. Return()", log: .firebase, logType: .info)
                return
            }
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) {
                        messages.append(message)
                    }
                }
            }
//            print("-------------------\n\n### \(#function) New Unseen Messages with count: \(messages.count) are: \n\(messages)\n\n----------------------")
            self.persistUnseenFirebaseMessagesInStore(entries: Array(messages.dropFirst()), fetchedEntries: fetchedMessages, offsetMessage: previousMessage)
        }) { error in
            let errorMessage = "Firebase Single Event Observer Error while observing Messages: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    
    
    
    
    
    
    
    func loadMoreMessagesFromFirebase(offsetMessage:UserMessage, updatingExistingMessages fetchedMessages:[UserMessage]) {
//        print("Loading More Messages from Firebase")
//        print("### \(#function) where offset message: \(offsetMessage) and fetched Messages to update: \(fetchedMessages)")
        let key = offsetMessage.firebaseKey!
//        print("### \(#function) Message Count : \(messages.count) | offset message text: \(offsetMessage.textMessage ?? "---") | Key: \(key)")
        
        reference.queryOrderedByKey().queryEnding(atValue: key).queryLimited(toLast: UInt(limit + 1)).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            guard snapshot.exists() else {
//               printAndLog(message: "### \(#function) Snapshot does not exists. Return()", log: .firebase, logType: .info)
                return
            }
            var messages:[FirebaseMessage] = []
            //            print("Snapshot Children Count: \(snapshot.children.allObjects.count)")
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
//                        printAndLog(message: "Invalid Data, Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, logType: .debug)
                        continue
                    }
                    //                    print(conversation)
                    messages.insert(message, at: 0)
                }
            }
            self.persistFirebaseMessagesInStore(entries: Array(messages.dropFirst()), fetchedEntries: fetchedMessages, offsetMessage: offsetMessage)
        }) { error in
            let errorMessage = "Firebase Single Event Observer Error while observing Messages: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    
    
    
    /*
     func loadMessages() {
     if messages.isEmpty { self.startSpinner() }
     
     handle = reference.queryLimited(toLast: UInt(limit)).observe(.value, with: { snapshot in
     guard snapshot.exists() else {
     #if !RELEASE
     print("Snapshot Does not exists: returning")
     #endif
     return
     }
     var messages:[FirebaseMessage] = []
     for child in snapshot.children {
     if let snapshot = child as? DataSnapshot {
     //                    print(snapshot)
     
     guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
     #if !RELEASE
     print("Invalid Data Error: Failed to create message from Firebase Message")
     #endif
     os_log("Invalid Data, Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, type: .debug)
     continue
     }
     //                    print(conversation)
     messages.append(message)
     }
     }
     //            self.firebaseCustomers = conversations
     self.persistFirebaseMessagesInStore(entries: messages)
     //            print(snapshot.value as Any)
     }) { error in
     #if !RELEASE
     print("Value Observer Event Error: \(error)")
     #endif
     os_log("Firebase Value Observer Event Error while observing Messages: %@", log: .firebase, type: .error, error.localizedDescription)
     }
     }
     */
    
    
    
    
    
    
    
    // MARK: - Core Data
    
    func fetchMoreMessages(offsetMessage:UserMessage) {
        if self.isLoading == false { self.isLoading = true }
        
        limit += 20
        let objectsBefore = messages
//        fetchedResultsController.fetchRequest.fetchLimit = limit
//        self.performFetch()
        let objectsAfter = messages
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //            self.reloadDataKeepingOffset()
        //            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
        //                self.loadMoreMessagesFromFirebase(offsetMessage: offsetMessage)
        //            }
        //            self.isLoading = false
        //        }
        
        
        DispatchQueue.main.async {
            let offset = self.messagesCollectionView.contentOffset.y + self.messagesCollectionView.adjustedContentInset.bottom + self.messagesCollectionView.verticalScrollIndicatorInsets.bottom
            let oldY = self.messagesCollectionView.contentSize.height - offset
            
            UIView.performWithoutAnimation {
                self.messagesCollectionView.performBatchUpdates({
                    if !objectsBefore.isEmpty {
                        objectsBefore.forEach({
                            if objectsAfter.firstIndex(of: $0) == nil {
                                print("### Deleting Section: \(objectsBefore.firstIndex(of: $0)!)")
                                self.messagesCollectionView.deleteSections([objectsBefore.firstIndex(of: $0)!])
                            }
                        })
                    }
                    if !objectsAfter.isEmpty {
                        objectsAfter.forEach({
                            if objectsBefore.firstIndex(of: $0) == nil {
                                print("### Inserting Section: \(objectsAfter.firstIndex(of: $0)!)")
                                self.messagesCollectionView.insertSections([objectsAfter.firstIndex(of: $0)!])
                            }
                        })
                    }
                }, completion: { [weak self] finished in
                    guard let self = self else { return }
                    self.messagesCollectionView.layoutIfNeeded()
                    let y = self.messagesCollectionView.contentSize.height - oldY
                    let newOffset = CGPoint(x: 0, y: y)
                    self.messagesCollectionView.contentOffset = newOffset
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
                        self.loadMoreMessagesFromFirebase(offsetMessage: offsetMessage, updatingExistingMessages: [])
                        self.isLoading = false
                    }
                })
            }
        }
    }
    
    
    
    
    
    /*
    func loadInitialMessages(animated:Bool = false) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchMessagesFromStore(count: self.limit) { messages in
                DispatchQueue.main.async {
                    self.messages = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: animated)
                }
            }
        }
    }
 */
//    func loadMoreMessages(offsetMessage:UserMessage) {
//        if self.isLoading == false { self.isLoading = true }
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()) {
//            self.fetchMessagesFromStore(count: self.limit) { messages in
//                DispatchQueue.main.async {
//                    self.messages.insert(contentsOf: messages, at: 0)
//                    self.reloadDataKeepingOffset()
//                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
//                        self.loadMoreMessagesFromFirebase(offsetMessage: offsetMessage)
//                        self.isLoading = false
//                    }
//                }
//            }
//        }
//    }
    
    func loadMoreMessages(offsetMessage:UserMessage, fetchFromFirebase:Bool) {
//        print("### \(#function) called; where should fetchFromFirebase = \(fetchFromFirebase) && where offset message = \(offsetMessage)")
        
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        fetchRequest.predicate = conversationPredicate
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \UserMessage.date, ascending: false) ]
        if fetchFromFirebase {
            offset = messages.count
            if self.isLoading == false { self.isLoading = true }
        }
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
            self.fetchMessagesFromStore(fetchRequest: fetchRequest) { [weak self] messages in
                guard let self = self else { return }
//                print("Fetched \(messages.count) messages which are: \(messages)")
                DispatchQueue.main.async {
//                    print("Original messages count = \(self.messages.count)")
//                    _ = messages.map { message in self.messages.removeAll(where: { $0.messageId == message.messageId }) }
                    messages.reversed().forEach { message in
                        if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
                            self.messages[index] = message
                        } else {
                            self.messages.insert(message, at: 0)
                        }
                    }
//                    print("After removing; original messages count = \(self.messages.count)")
//                    print("Inserting \(messages.count) messages in Original Messages")
//                    self.messages.insert(contentsOf: messages, at: 0)
//                    print("Orignal messages count after update: \(self.messages.count)")
//                    self.reloadDataKeepingOffset()
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.isLoading = false
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0) {
                        if fetchFromFirebase {
                            self.loadMoreMessagesFromFirebase(offsetMessage: offsetMessage, updatingExistingMessages: messages)
                        }
                        
                    }
                }
            }
        }
    }
    
    
    func fetchMessagesFromStore(count:Int, completion: @escaping (([UserMessage]) -> Void)) {
//        print("### \(#function) called")
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        
        fetchRequest.predicate = conversationPredicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserMessage.date, ascending: false)
        ]
        offset = messages.count
        fetchRequest.fetchLimit = count
        fetchRequest.fetchOffset = offset
        
        
        viewContext.perform {
            do {
                let result = try fetchRequest.execute()
//                print(result)
                completion(result.reversed())
            } catch let error {
                print(error)
            }
        }
    }
    
    
    
    func loadInitialMessages(animated:Bool = false, fetchFromFirebase:Bool, shouldLoadUnseenMessages:Bool) {
//        print("### \(#function) called")
        
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        let isSeenPredicate = NSPredicate(format: "\(#keyPath(UserMessage.isSeen)) = %d", true)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conversationPredicate, isSeenPredicate])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \UserMessage.date, ascending: false) ]
        
//        offset = messages.count
        fetchRequest.fetchLimit = limit
//        fetchRequest.fetchOffset = offset
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchMessagesFromStore(fetchRequest: fetchRequest) { [weak self] messages in
                guard let self = self else { return }
                if messages.isEmpty {
                    /**** There ain't any seen initial messages in store. Now fetching all messages from store.   **/
//                    print("### \(#function) Messages empty; now changing predicate to conversation only predicate")
                    fetchRequest.predicate = conversationPredicate
                    self.fetchMessagesFromStore(fetchRequest: fetchRequest) { messages in
//                        print("### \(#function) This must be the first time fetch")
                        DispatchQueue.main.async {
                            self.messages = messages
                            self.messagesCollectionView.reloadData()
                          self.messagesCollectionView.scrollToLastItem(animated: animated)
                            if fetchFromFirebase {
                                self.loadInitialMessagesFromFirebase()
                            }
                        }
                    }
                } else {
//                    print("### \(#function) Messages in store exists. Now Upserting!")
                    DispatchQueue.main.async {
                        messages.reversed().forEach { message in
                            if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
                                self.messages[index] = message
                            } else {
                                self.messages.insert(message, at: 0)
                            }
                        }
                        self.messagesCollectionView.reloadData()
                      self.messagesCollectionView.scrollToLastItem(animated: animated)
                        if fetchFromFirebase {
                            self.upsertExistingMessagesFromFirebase(fetchedMessages: messages)
                        }
                        if let lastSeenMessage = messages.last, shouldLoadUnseenMessages {
                            self.loadUnseenMessages(previousMessage: lastSeenMessage, animated: true, shouldFetchFromFirebase: true)
                        }
                    }
                }
            }
        }
    }
    /*
    func loadInitialUnseenMessages(animated:Bool, shouldFetchFromFirebase:Bool) {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        let isSeenPredicate = NSPredicate(format: "\(#keyPath(UserMessage.isSeen)) = %d", false)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conversationPredicate, isSeenPredicate])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \UserMessage.date, ascending: true) ]
        
        fetchRequest.fetchLimit = unseenFetchLimit
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchMessagesFromStore(fetchRequest: fetchRequest, shouldReverseResult: false) { messages in
                
            }
        }
    }
 */
    func loadUnseenMessages(previousMessage:UserMessage, animated:Bool, shouldFetchFromFirebase:Bool) {
        let previousMessageSentDate = previousMessage.sentDate as NSDate
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        let isSeenPredicate = NSPredicate(format: "\(#keyPath(UserMessage.isSeen)) = %d", false)
        let datePredicate = NSPredicate(format: "\(#keyPath(UserMessage.date)) > %@", previousMessageSentDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conversationPredicate, isSeenPredicate, datePredicate])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \UserMessage.date, ascending: true) ]
        
        fetchRequest.fetchLimit = unseenFetchLimit
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchMessagesFromStore(fetchRequest: fetchRequest, shouldReverseResult: false) { [weak self] messages in
                guard let self = self else { return }
//                print("--------------\n\n### \(#function) - Unseen Messages with count: \(messages.count) are: \n\n\(messages)\n\n-----------------")
                DispatchQueue.main.async {
                    messages.forEach { message in
                        if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
                            self.messages[index] = message
                        } else {
                            self.messages.append(message)
                        }
                    }
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    switch messages.count {
                        case 1, 2:
                            let indexPath = IndexPath(item: 0, section: self.messages.count - 1)
                            self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
                        case 3...:
                            let indexPath = IndexPath(item: 0, section: (self.messages.count - messages.count) + 1) // scrolls to second unseen message
                            self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
                        default: break
                    }
                    if shouldFetchFromFirebase {
                        self.upsertUnseenMessagesFromFirebase(previousMessage: previousMessage, fetchedMessages: messages)
                    }
                }
            }
        }
    }
    func fetchMessagesFromStore(fetchRequest:NSFetchRequest<UserMessage>, shouldReverseResult:Bool = true, completion: @escaping (([UserMessage]) -> Void)) {
        viewContext.perform {
            do {
                let result = try fetchRequest.execute()
                shouldReverseResult ?
                    completion(result.reversed()) :
                    completion(result)
            } catch let error {
                printAndLog(message: "Error fetching User Messages From Core Data store: \(error)", log: .coredata, logType: .error)
            }
        }
    }
}

