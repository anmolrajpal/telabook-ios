//
//  AutoResponseServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AutoResponseViewController {
    internal func fetchAutoResponse() {
        DispatchQueue.main.async {
            self.subview.spinner.startAnimating()
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = AutoResponseOperations.getOperationsToFetchAndSaveAutoResponse(using: context, userID: userID, forAgent: agentRefrenceObject)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    internal func updateAutoResponse(forID id:Int) {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = AutoResponseOperations.getOperationsToUpdateAutoResponseToServer(using: context, userID: userID, autoResponseID: id, forAgent: agentRefrenceObject, smsReplyToUpdate: subview.autoReplyTextView.text ?? "")
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                //MARK: Fetch & Sync Auto Response Operations
                case let operation as FetchSavedAgentAutoResponseEntry_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                
                            }
                        }
                }
                case let operation as DownloadAgentAutoResponseEntryFromServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
                case let operation as AddAgentAutoResponseEntryToCoreDataStore_Operation:
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
                
                
                
                //MARK: Update AutoResponse to Server and Sync to Core Data Operations
                case let operation as SaveUserUpdatedAutoResponseEntryToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            print("Response Saved in Core Data. Dismissing, leaving pending operations in Queue (updating on Server + sync to store)")
                            Thread.sleep(forTimeInterval: 0.4)
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                }
                case let operation as UpdateAgentAutoResponseEntryOnServer_Operation:
                operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
//                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
                case let operation as SyncUserUpdatedAutoResponseEntryFromServerToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
//                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            print("Updated AutoResponse synced to core data")
                        }
                }
                default: break
            }
            
            
            
            
            /*
            if let operation = operation as? FetchSavedAgentAutoResponseEntry_Operation {
                operation.completionBlock = {
                    if case let .failure(error) = operation.result {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    } else {
                        DispatchQueue.main.async {
//                            self.updateSnapshot()
                        }
                    }
                }
            } else if let operation = operation as? DownloadAgentAutoResponseEntryFromServer_Operation {
                operation.completionBlock = {
                    guard case let .failure(error) = operation.result else { return }
                    print(error.localizedDescription)
                    self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
            } else if let operation = operation as? AddAgentAutoResponseEntryToCoreDataStore_Operation {
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
            }
            */
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
