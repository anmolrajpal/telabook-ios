//
//  CustomersServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import os
extension CustomersViewController {
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func persistFirebaseEntriesToCoreDataStore(entries:[FirebaseCustomer]) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = CustomerOperations.getOperationsToPersistData(using: context, forAgent: agentRefrenceObject, fromFirebaseEntries:entries)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func updateConversation(for customer:Customer, archiving:Bool, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
//        context.parent = context
        let operations = CustomerOperations.getArchivingOperations(using: context, for: customer, shouldArchive: archiving)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func updateConversationInStore(for customer:Customer, archiving:Bool, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        //        context.parent = context
        let operation = UpdateConversationInStore_ArchivingOperation(context: context, selectedCustomer: customer, shouldArchive: archiving)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: completion)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func updateConversationInStore(for customer:Customer, pinning:Bool, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
//        let context = PersistentContainer.shared.newBackgroundContext()
//        let objectID = agent.objectID
//        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operation = UpdateConversationInStore_PinningOperation(context: context, selectedCustomer: customer, shouldPin: pinning)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: completion)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func blockConversation(for customer:Customer, blockingReason:String, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = BlacklistOperations.getOperationsToBlockConversation(using: context, for: customer, withReasonToBlock: blockingReason)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    internal func markConversationInStore(isBlocking:Bool, for customer:Customer) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        let context = PersistentContainer.shared.newBackgroundContext()
        let operation = MarkBlockCustomerInStore_Operation(context: context, customer: customer, markBlock: isBlocking)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: {_ in})
        queue.addOperations([operation], waitUntilFinished: false)
    }
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue, completion: @escaping (Bool) -> Void) {
        operations.forEach { operation in
            switch operation {
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Sync Customer Conversations Operations completions
                case let operation as FetchSavedCustomersEntries_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            
                        }
                }
                case let operation as DeleteRedundantCustomerEntries_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                case let operation as AddCustomerEntriesFromServerToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                self.stopRefreshers()
//                                self.updateSnapshot(animated: true)
                            }
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Archive/Unarchive Customer Conversation Operations completions
                case let operation as UpdateConversationInStore_ArchivingOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if DEBUG
                            print("Error updating Archiving operation in Store: \(error)")
                            #endif
                            os_log("Error updating Archiving operation in Store: %@", log: .coredata, type: .error, error.localizedDescription)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                }
                case let operation as UpdateConversationOnServer_ArchivingOperation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        self.updateConversationInStore(for: operation.customer, archiving: !operation.shouldArchive, completion: {_ in})
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        #if DEBUG
                        print("Error updating Archiving operation on server: \(error)")
                        #endif
                        os_log("Error updating Archiving operation on server: %@", log: .network, type: .error, error.localizedDescription)
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Pin/Unpin Customer Conversation Operation completion
                case let operation as UpdateConversationInStore_PinningOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if DEBUG
                            print("Error updating Pinning operation in Store: \(error)")
                            #endif
                            os_log("Error updating Pinning operation in Store: %@", log: .coredata, type: .error, error.localizedDescription)
                            completion(false)
                        } else {
                            completion(true)
                            DispatchQueue.main.async {
                                self.subview.tableView.scrollToTopRow()
                            }
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Block conversation Operations completions
                case let operation as MarkBlockCustomerInStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if DEBUG
                            print("Error updating Blacklist operation in Store: \(error)")
                            #endif
                            os_log("Error updating Blacklist operation in Store: %@", log: .coredata, type: .error, error.localizedDescription)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                }
                case let operation as BlockCustomerOnServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        let customer = operation.customer
                        self.markConversationInStore(isBlocking: false, for: customer)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        #if DEBUG
                        print("Error updating Archiving operation on server: \(error)")
                        #endif
                        os_log("Error updating Archiving operation on server: %@", log: .network, type: .error, error.localizedDescription)
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
                self.stopRefreshers()
            })
        }
    }
}
