//
//  Blacklist+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os

extension BlacklistViewController {
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func fetchBlacklist(page:Int = 1) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = BlacklistOperations.getOperationsToFetchBlacklist(using: context, page: page)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func unblockConversation(for blockedUser:BlockedUser, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = BlacklistOperations.getOperationsToUnblockCustomer(using: context, blockedUser: blockedUser)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    internal func markConversation(isUnblocking:Bool, for blockedUser:BlockedUser) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        let context = PersistentContainer.shared.newBackgroundContext()
        let operation = MarkUnblockCustomerInStore_Operation(context: context, blockedUser: blockedUser, markUnblock: isUnblocking)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: {_ in})
        queue.addOperations([operation], waitUntilFinished: false)
    }
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue, completion: @escaping (Bool) -> Void) {
        operations.forEach { operation in
            switch operation {
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Sync Blacklist Operations completions
                case let operation as FetchSavedBlacklistEntries_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.isDownloading = false
                            self.stopRefreshers()
                            self.handleState()
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                case let operation as FetchBlacklistFromServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
                        self.isDownloading = false
                        self.stopRefreshers()
                        self.handleState()
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
                case let operation as DeleteRedundantBlacklistEntries_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.isDownloading = false
                            self.stopRefreshers()
                            self.handleState()
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                case let operation as AddBlacklistEntriesFromServerToStore_Operation:
                    operation.completionBlock = {
                        self.isDownloading = false
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.stopRefreshers()
                            self.handleState()
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                                self.handleState()
                            }
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Unblock Blocked user Operations completions
                case let operation as MarkUnblockCustomerInStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if !RELEASE
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
                case let operation as UnblockCustomerOnServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        let blockedConversation = operation.blockedUser
                        self.markConversation(isUnblocking: false, for: blockedConversation)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        #if !RELEASE
                        print("Error updating Archiving operation on server: \(error)")
                        #endif
                        os_log("Error updating Archiving operation on server: %@", log: .network, type: .error, error.localizedDescription)
                }
                case let operation as DeleteBlockedUserEntryFromStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            #if !RELEASE
                            print(error.localizedDescription)
                            #endif
                            os_log("%@", log: .coredata, type: .error, error.localizedDescription)
                        } else {
                            print("Successfully Deleted Blocked User entry from Core Data")
                        }
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
