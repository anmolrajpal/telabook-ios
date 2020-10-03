//
//  Messages+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os
import MessageKit
import CoreData
import Firebase


extension MessagesController {
    internal func reloadQuickResponses() {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        
        guard let worker = customer.agent else { return }
        let objectID = worker.objectID
        let referenceAgent = context.object(with: objectID) as! Agent
        let userID = Int(worker.userID)
        
        let operations = QuickResponseOperations.getOperationsToFetchAndSaveQuickResponses(using: context, userID: userID, forAgent: referenceAgent)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    
    internal func persistFirebaseMessageInStore(entry:FirebaseMessage) {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(UserMessage.firebaseKey)) == %@ AND \(#keyPath(UserMessage.conversation)) == %@", entry.firebaseKey, customer)
        fetchRequest.predicate = predicate
        let fetchedEntry = self.messages.first(where: { $0.firebaseKey == entry.firebaseKey })
        let isSeen = fetchedEntry?.isSeen ?? false
        let cachedImageUUID = fetchedEntry?.imageUUID
        let downloadState = fetchedEntry?.downloadState ?? .new
        let uploadState = fetchedEntry?.uploadState ?? .none
        var message:UserMessage?
        viewContext.performAndWait {
            _ = UserMessage(context: viewContext, messageEntryFromFirebase: entry, forConversationWithCustomer: customer, imageUUID: cachedImageUUID, isSeen: isSeen, downloadState: downloadState, uploadState: uploadState)
            do {
                if viewContext.hasChanges { try viewContext.save() }
            } catch let error {
                printAndLog(message: "Error persisting observed message: \(error)", log: .coredata, logType: .error)
            }
            if let object = try? fetchRequest.execute().first {
                message = object
            }
        }
        if let message = message {
            DispatchQueue.main.async {
                if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
                    self.messages[index] = message
                    self.updateCell(with: message)
                } else if message.sentDate >= self.screenEntryTime {
                    self.messages.append(message)
                    self.messagesCollectionView.performBatchUpdates({
                        self.messagesCollectionView.insertSections([self.messages.count - 1])
                        if self.messages.count >= 2 {
                            self.messagesCollectionView.reloadSections([self.messages.count - 2])
                        }
                    }) { _ in }
                }
            }
        }
    }
    
    
    /*
     internal func persistFirebaseMessageInStore(entry:FirebaseMessage) {
     let fetchedEntry = self.messages.first(where: { $0.firebaseKey == entry.firebaseKey })
     let isSeen = fetchedEntry?.isSeen ?? false
     let cachedImageUUID = fetchedEntry?.imageUUID
     let downloadState = fetchedEntry?.downloadState ?? .new
     let uploadState = fetchedEntry?.uploadState ?? .none
     let context = PersistentContainer.shared.newBackgroundContext()
     let objectID = customer.objectID
     let referenceContext = context.object(with: objectID) as! Customer
     //        let context = viewContext
     context.performAndWait {
     do {
     _ = UserMessage(context: context, messageEntryFromFirebase: entry, forConversationWithCustomer: referenceContext, imageUUID: cachedImageUUID, isSeen: isSeen, downloadState: downloadState, uploadState: uploadState)
     try context.save()
     } catch let error {
     printAndLog(message: "Error persisting observed message: \(error)", log: .coredata, logType: .error)
     }
     }
     }
     */
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func persistInitialFirebaseMessagesInStore(entries:[FirebaseMessage], fetchedEntries:[UserMessage]?) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceContext = context.object(with: objectID) as! Customer
        let operation = MergeMessageEntriesFromFirebaseToStore_Operation(context: context, conversation: referenceContext, serverEntries: entries, fetchedEntries: fetchedEntries)
        operation.completionBlock = {
            if let error = operation.error {
                printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
            } else {
                if operation.serverEntries?.isEmpty == true { self.shouldFetchMore = false }
                self.messages.isEmpty ?
                    self.loadInitialMessages(animated: true, fetchFromFirebase: false, shouldLoadUnseenMessages: false) :
                    self.loadInitialMessages(animated: false, fetchFromFirebase: false, shouldLoadUnseenMessages: false)
                
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func persistFirebaseMessagesInStore(entries:[FirebaseMessage], fetchedEntries:[UserMessage]?, offsetMessage:UserMessage) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceContext = context.object(with: objectID) as! Customer
        let operation = MergeMessageEntriesFromFirebaseToStore_Operation(context: context, conversation: referenceContext, serverEntries: entries, fetchedEntries: fetchedEntries)
        operation.completionBlock = {
            if let error = operation.error {
                print(error.localizedDescription)
                self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
            } else {
                if operation.serverEntries?.isEmpty == true { self.shouldFetchMore = false }
                self.loadMoreMessages(offsetMessage: offsetMessage, fetchFromFirebase: false)
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func persistUnseenFirebaseMessagesInStore(entries:[FirebaseMessage], fetchedEntries:[UserMessage]?, offsetMessage:UserMessage) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceContext = context.object(with: objectID) as! Customer
        let operation = MergeMessageEntriesFromFirebaseToStore_Operation(context: context, conversation: referenceContext, serverEntries: entries, fetchedEntries: fetchedEntries)
        operation.completionBlock = {
            if let error = operation.error {
                print(error.localizedDescription)
                self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
            } else {
                self.loadUnseenMessages(previousMessage: offsetMessage, animated: true, shouldFetchFromFirebase: false)
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func sendNewTextMessage(newMessage: NewMessage) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceCustomer = context.object(with: objectID) as! Customer
        let operations = MessageOperations.getOperationsToSend(newTextMessage: newMessage, using: context, forConversationWithCustomer: referenceCustomer, messageReference: self.reference, conversationReference: self.conversationReference)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func forwardTextMessage(message: UserMessage, to customer: Customer, forwardedFromNode: String) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let conversationsNode: Config.FirebaseConfig.Node = .conversations(companyID: AppData.companyId, workerID: Int(customer.agent!.workerID))
        let messagesNode: Config.FirebaseConfig.Node = .messages(companyID: AppData.companyId, node: customer.node!)
        let conversationsDatabaseReference = conversationsNode.reference
        let messagesDatabaseReference = messagesNode.reference
        
        guard let key = messagesDatabaseReference.childByAutoId().key else { return }
        let newMessage = NewMessage(kind: message.kind, messageId: key, sender: thisSender, sentDate: Date(), forwardedFromNode: forwardedFromNode)
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let customerObject = context.object(with: objectID) as! Customer
        let operations = MessageOperations.getOperationsToSend(newTextMessage: newMessage, using: context, forConversationWithCustomer: customerObject, messageReference: messagesDatabaseReference, conversationReference: conversationsDatabaseReference)
        //        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    func forwardMultimediaMessage(message: UserMessage, to customer: Customer, forwardedFromNode: String) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        guard let originalMediaItemLocalURL = message.imageLocalURL() else { return }
        
        //        let conversationsNode: Config.FirebaseConfig.Node = .conversations(companyID: AppData.companyId, workerID: Int(customer.agent!.workerID))
        let messagesNode: Config.FirebaseConfig.Node = .messages(companyID: AppData.companyId, node: customer.node!)
        //        let conversationsDatabaseReference = conversationsNode.reference
        let messagesDatabaseReference = messagesNode.reference
        let imageUUID = UUID()
        
        let imageFileName = imageUUID.uuidString + ".jpeg"
        
        let localImageURL = customer.mediaFolder().appendingPathComponent(imageFileName)
        
        guard let key = messagesDatabaseReference.childByAutoId().key else { return }
        guard case .photo(let originalMediaItem as ImageItem) = message.kind else { return }
        var newMediaItem = originalMediaItem
        newMediaItem.imageUUID = imageUUID
        
        DispatchQueue.global().async {
            let fileManager = FileManager.default
            do {
                try fileManager.copyItem(at: originalMediaItemLocalURL, to: localImageURL)
            } catch {
                let errorMessage = "### \(#function): Failed to copy image file from original url: \(originalMediaItemLocalURL) to new image local url: \(localImageURL); \nError Description: \(error)"
                printAndLog(message: errorMessage, log: .ui, logType: .error)
                fatalError(errorMessage)
            }
        }
        
        let newMessage = NewMessage(kind: .photo(newMediaItem), messageId: key, sender: thisSender, sentDate: Date(), forwardedFromNode: forwardedFromNode)
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let customerObject = context.object(with: objectID) as! Customer
        
        var forwardedMessage: UserMessage?
        context.performAndWait {
            forwardedMessage = UserMessage(context: context, newMessageEntryFromCurrentUser: newMessage, forConversationWithCustomer: customerObject)
            forwardedMessage?.uploadState = .uploaded
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "### \(#function) - Core Data Error saving new media message entry in store: \(message) | Error: \(error)", log: .coredata, logType: .error)
                return
            }
        }
        let operations = MessageOperations.getOperationsToSend(newMultimediaMessage: forwardedMessage!, using: context, forConversationWithCustomer: customerObject)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func sendNewMultimediaMessage(newMessage:UserMessage) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceCustomer = context.object(with: objectID) as! Customer
        let referenceMessage = context.object(with: newMessage.objectID) as! UserMessage
        let operations = MessageOperations.getOperationsToSend(newMultimediaMessage: referenceMessage, using: context, forConversationWithCustomer: referenceCustomer)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func clearUnreadMessagesCount() {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceCustomer = context.object(with: objectID) as! Customer
        
        let wasNotSeenNodeReference = Config.FirebaseConfig.Node.unreadMessages(conversationID: Int(referenceCustomer.externalConversationID)).reference
        
        let operations = MessageOperations.getOperationsToClearUnreadMessagesCount(using: context, forConversationWithCustomer: referenceCustomer, unreadMessagesCountNodeReference: wasNotSeenNodeReference, conversationReference: self.conversationReference, updatedAt: self.screenEntryTime)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func deleteUserMessage(message:UserMessage) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let messageReference = reference.child(message.messageId)
        let context = self.viewContext
        let operations = MessageOperations.getOperationsToDeleteUserMessage(using: context, message: message, messageReference: messageReference, updatedAt: Date())
        
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in
            self.updateCell(with: message)
        })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func markAllMessagesAsSeen() {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceCustomer = context.object(with: objectID) as! Customer
        
        let operation = MarkAllMessagesAsSeenInStore_Operation(context: context, conversation: referenceCustomer)
        operation.completionBlock = {
            if let error = operation.error {
                printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func initiateClick2CallOperation(for conversationID: Int, fromPhoneNumber: String, toPhoneNumber: String, isAgent: Int) {
        click2CallManager.addOperation(for: conversationID) {
            self.updateNavigationBarItems()
        }
        let workerID = customer.agent?.workerID ?? 0
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = Click2Call_Operation(fromPhoneNumber: fromPhoneNumber, toPhoneNumber: toPhoneNumber, conversationID: String(conversationID), isAgent: String(isAgent))
        
        operation.completionBlock = { [weak self] in
            switch operation.result {
                case .failure(let error):
                    printAndLog(message: "### initiateClick2CallOperation - Error: \(error.localizedDescription)", log: .network, logType: .error)
                    Click2CallManager.shared.removeOperation(for: conversationID) {
                        self?.updateNavigationBarItems()
                    }
                    DispatchQueue.main.async {
                        if UIApplication.shared.applicationState == .active {
                            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                                return
                            }
                            if let tabBarController = rootViewController as? TabBarController {
                                if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                                    if let lastViewController = selectedNavigationController.viewControllers.last {
                                        if let presentedViewController = lastViewController.presentedViewController {
                                            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                                self?.updateNavigationBarItems()
                                            }), controller: presentedViewController)
                                        } else {
                                            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                                self?.updateNavigationBarItems()
                                            }), controller: lastViewController)
                                        }
                                    }
                                }
                            } else {
                                fatalError("Root View Controller must be Tab Bar Controller: \(TabBarController.self)")
                            }
                        } else {
                            let notificationItem = LocalNotificationItem(key: .click2CallError, title: "Failed to schedule call", body: "There was an error scheduling your call to \(toPhoneNumber). Please try again.", sound: .default, badgeCount: 1, delay: 0, userInfo: ["workerID": workerID, "conversationID": conversationID], tapHandler: nil)
                            LocalNotificationService.shared.postNotification(for: notificationItem)
                        }
                    }
                case .success:
                    printAndLog(message: "Successfully scheduled a call from \(fromPhoneNumber) to \(toPhoneNumber) where conversationID: \(conversationID)", log: .network, logType: .info, isPrivate: true)
                    Click2CallManager.shared.removeOperation(for: conversationID) {
                        self?.updateNavigationBarItems()
                    }
                    DispatchQueue.main.async {
                        if UIApplication.shared.applicationState == .active {
                            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                                return
                            }
                            if let tabBarController = rootViewController as? TabBarController {
                                if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                                    if let lastViewController = selectedNavigationController.viewControllers.last {
                                        if let presentedViewController = lastViewController.presentedViewController {
                                            UIAlertController.showTelaAlert(title: "Call Scheduled", message: "Please wait for the call on your phone.", action: UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                                self?.updateNavigationBarItems()
                                            }), controller: presentedViewController)
                                        } else {
                                            UIAlertController.showTelaAlert(title: "Call Scheduled", message: "Please wait for the call on your phone.", action: UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                                self?.updateNavigationBarItems()
                                            }), controller: lastViewController)
                                        }
                                    }
                                }
                            } else {
                                fatalError("Root View Controller must be Tab Bar Controller: \(TabBarController.self)")
                            }
                        } else {
                            let notificationItem = LocalNotificationItem(key: .click2CallSuccess, title: "Call Scheduled", body: "Please wait for the call on your phone.", sound: .default, badgeCount: 1, delay: 0, userInfo: ["workerID": workerID, "conversationID": conversationID], tapHandler: nil)
                            LocalNotificationService.shared.postNotification(for: notificationItem)
                        }
                    }
                case .none: fatalError("Click2Call Operation Result Invalid case. This needs to be handled.")
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    internal func updateNewMessageToFirebase(message:UserMessage) {
        self.reference.child(message.messageId).setValue(message.toFirebaseObject()) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.conversationReference.updateChildValues(FirebaseCustomer.getUpdatedConversationObject(fromLastMessage: message)) { (error, _) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Safe to update on server")
                    }
                }
            }
        }
    }
    
    
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue, completion: @escaping (Bool) -> Void) {
        operations.forEach { operation in
            switch operation {
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Sync Messages Operations completions
                case let operation as MergeMessageEntriesFromFirebaseToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            self.loadInitialMessages(animated: true, fetchFromFirebase: false, shouldLoadUnseenMessages: false)
                            if operation.serverEntries?.isEmpty == true {
                                self.shouldFetchMore = false
                            }
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Send New Message Operations completion
                case let operation as AddNewMessageEntryToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if !RELEASE
                            print("Error inserting new message operation in Store: \(error)")
                            #endif
                            os_log("Error inserting new message operation in Store: %@", log: .coredata, type: .error, error.localizedDescription)
                            
                        } else {
                            DispatchQueue.main.async {
                                self.messagesCollectionView.scrollToBottom(animated: true)
                            }
                        }
                }
                case let operation as UpdateNewMessageEntryToFirebase_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else {
                            return
                        }
                        if let insertedMessage = operation.newMessageFromStore {
                            insertedMessage.isSending = false
                            insertedMessage.errorSending = true
                        }
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        #if !RELEASE
                        print("Error updating newly created message from store to Firebase: \(error)")
                        #endif
                        os_log("Error updating newly created message from store to Firebase: %@", log: .network, type: .error, error.localizedDescription)
                }
                case let operation as SendNewMessageOnServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else {
                            operation.newlyCreatedMessage?.isSending = false
                            return
                        }
                        if let insertedMessage = operation.newlyCreatedMessage {
                            insertedMessage.isSending = false
                            insertedMessage.errorSending = true
                        }
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        #if !RELEASE
                        print("Error sending new text message operation on server: \(error)")
                        #endif
                        os_log("Error sending new text message operation on server: %@", log: .network, type: .error, error.localizedDescription)
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Delete User Message Operations completion
                case let operation as MarkMessageDeletedInStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if !RELEASE
                            print("Error marking message as deleted in Store: \(error)")
                            #endif
                            os_log("Error marking message as deleted in Store: %@", log: .coredata, type: .error, error.localizedDescription)
                            
                        } else {
                            DispatchQueue.main.async {
                                completion(true)
                            }
                            let message = "Successfully, marked message as deleted in Core Data Store. Now Updating message on Firebase."
                            printAndLog(message: message, log: .coredata, logType: .info)
                        }
                }
                case let operation as MarkMessageDeletedOnFirebase_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else {
                            print("Successfully deleted message")
                            return
                        }
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        operation.message.isMessageDeleted = false
                        let message = "Error deleting message on Firebase: \(error.localizedDescription)"
                        printAndLog(message: message, log: .firebase, logType: .error)
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                default: break
            }
        }
    }
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                if let completionHandler = completion { completionHandler() }
            }), controller: self, completion: {
                queue.cancelAllOperations()
                //                self.stopRefreshers()
            })
        }
    }
}
