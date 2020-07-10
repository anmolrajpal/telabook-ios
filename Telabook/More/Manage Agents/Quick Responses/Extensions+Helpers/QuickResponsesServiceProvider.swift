//
//  QuickResponsesServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os

extension QuickResponsesViewController {
    internal func fetchQuickResponses() {
        DispatchQueue.main.async {
            self.subview.placeholderLabel.text = "Loading..."
            self.startRefreshers()
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = QuickResponseOperations.getOperationsToFetchAndSaveQuickResponses(using: context, userID: userID, forAgent: agentRefrenceObject)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    internal func createQuickResponse(answer:String) {
        DispatchQueue.main.async {
            self.startRefreshers()
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = CreateNewQuickResponseEntryOnServer_Operation(userID: userID, answer: answer)
        operation.completionBlock = {
            guard case let .failure(error) = operation.result else {
                TapticEngine.generateFeedback(ofType: .Success)
                self.fetchQuickResponses()
                return
            }
            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
        }
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    
    internal func updateQuickResponse(forSelectedResponse response:QuickResponse, answer:String) {
        DispatchQueue.main.async {
            self.subview.placeholderLabel.text = "Updating..."
            self.startRefreshers()
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = QuickResponseOperations.getOperationsToSyncExistingQuickResponse(using: context, userID: userID, selectedResponse: response, quickResposneToUpdate: answer)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    
    internal func deleteQuickResponse(forSelectedResponse response:QuickResponse, agent:Agent, completion:@escaping (Bool) -> Void) {
        let context = PersistentContainer.shared.newBackgroundContext()
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = QuickResponseOperations.getOperationsToDeleteExistingQuickResponse(using: context, selectedResponse: response, forAgent: agentRefrenceObject)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue, completion: @escaping (Bool) -> Void) {
        operations.forEach { operation in
            switch operation {
                
                
                //MARK: Fetch & Sync Auto Response Operations
                case let operation as FetchSavedQuickResponsesEntries_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            
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
                                self.subview.responseTextView.text.removeAll()
                                self.subview.characterCountLabel.text = "Max Characters: 70"
                                self.subview.saveResponseButton.isEnabled = false
                                self.subview.saveResponseButton.backgroundColor = UIColor.telaGray6
                            }
                        }
                }
                
                
                
                //MARK: Update Existing Quick Response Operations
                case let operation as UpdateExistingQuickResponseEntryInStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            print("Response Saved in Core Data. Dismissing, leaving pending operations in Queue (updating on Server + sync to store)")
                            DispatchQueue.main.async {
                                self.stopRefreshers()
//                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                }
                
                case let operation as UpdateExistingQuickResponseEntryOnServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else {
                            self.fetchQuickResponses()
                            return
                        }
                        print(error.localizedDescription)
                        os_log("%@", log: .network, type: .error, error.localizedDescription)
                }
                
                
                //MARK: Delete Existing Quick Response Operations
                
                case let operation as MarkToDeleteExistingQuickResponseEntryInStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            print("Response Marked for Deletion in Core Data. leaving pending operations in Queue (deleting on Server + sync to store)")
                            self.markForDeletionWithSuccess(completion: completion)
                        }
                }
                case let operation as DeleteExistingQuickResponseEntryOnServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
                        os_log("%@", log: .network, type: .error, error.localizedDescription)
                }
                case let operation as DeleteExistingQuickResponseEntryFromStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            os_log("%@", log: .coredata, type: .error, error.localizedDescription)
                        } else {
                            print("Successfully Deleted Quick Response entry from Core Data")
                        }
                }
                default: break
            }
        }
    }
    private func markForDeletionWithSuccess(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
//                self.dismiss(animated: true, completion: nil)
            }), controller: self, completion: {
                queue.cancelAllOperations()
                self.stopRefreshers()
            })
        }
    }
}
