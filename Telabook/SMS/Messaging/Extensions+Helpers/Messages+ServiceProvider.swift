//
//  Messages+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os



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
    internal func persistFirebaseMessagesInStore(entries:[FirebaseMessage]) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = customer.objectID
        let referenceContext = context.object(with: objectID) as! Customer
        let operations = MessageOperations.getOperationsToPersistMessagesInStore(using: context, forConversationWithCustomer: referenceContext, fromFirebaseEntries: entries)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func sendNewTextMessage(newMessage:NewMessage) {
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
        
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in})
        
        queue.addOperations(operations, waitUntilFinished: false)
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
                            DispatchQueue.main.async {
                                //                                    self.stopRefreshers()
                                //                                self.updateSnapshot(animated: true)
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
                case let operation as SendNewTextMessageOnServer_Operation:
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



public func printAndLog(message:String, log:OSLog, logType:OSLogType) {
    #if !RELEASE
    print(message)
    #endif
    os_log("%@", log: log, type: logType, message)
}
