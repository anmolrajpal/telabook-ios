//
//  QuickResponsesServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import os

extension QuickResponsesViewController {
    internal func fetchQuickResponses() {
        DispatchQueue.main.async {
            self.startRefreshers()
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = QuickResponseOperations.getOperationsToFetchAndSaveQuickResponses(using: context, userID: userID, forAgent: agentRefrenceObject)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                //MARK: Fetch & Sync Auto Response Operations
                case let operation as FetchSavedQuickResponsesEntries_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                
                            }
                        }
                }
                case let operation as DownloadQuickResponsesEntriesFromServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
                case let operation as DeleteRedundantQuickResponsesEntries_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                case let operation as AddQuickResponseEntryFromServerToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                                self.updateSnapshot()
                            }
                        }
                }
                
                
//                //MARK: Update AutoResponse to Server and Sync to Core Data Operations
//                case let operation as SaveUserUpdatedAutoResponseEntryToStore_Operation:
//                    operation.completionBlock = {
//                        if let error = operation.error {
//                            print(error.localizedDescription)
//                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
//                        } else {
//                            print("Response Saved in Core Data. Dismissing, leaving pending operations in Queue (updating on Server + sync to store)")
//                            Thread.sleep(forTimeInterval: 0.4)
//                            DispatchQueue.main.async {
//                                self.stopRefreshers()
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                        }
//                }
//                case let operation as UpdateAgentAutoResponseEntryOnServer_Operation:
//                    operation.completionBlock = {
//                        guard case let .failure(error) = operation.result else { return }
//                        print(error.localizedDescription)
//                        //                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
//                }
//                case let operation as AddQuickResponseEntryFromServerToStore_Operation:
//                    operation.completionBlock = {
//                        if let error = operation.error {
//                            print(error.localizedDescription)
//                            //                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
//                        } else {
//                            print("Updated AutoResponse synced to core data")
//                        }
//                }
                default: break
            }
        }
    }
    
    
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }), controller: self, completion: {
                queue.cancelAllOperations()
                self.stopRefreshers()
            })
        }
    }
}
