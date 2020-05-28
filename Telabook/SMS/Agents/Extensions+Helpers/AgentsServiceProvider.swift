//
//  AgentsServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os

extension AgentsViewController {
    internal func fetchAgents() {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = AgentOperations.getOperationsToFetchLatestEntries(using: context)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            if let operation = operation as? FetchMostRecentAgentsEntryOperation {
                operation.completionBlock = {
                    if case let .failure(error) = operation.result {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    } else {
                        DispatchQueue.main.async {
                            self.updateSnapshot()
                        }
                    }
                }
            } else if let operation = operation as? DownloadAgentsEntriesFromServerOperation {
                operation.completionBlock = {
                    guard case let .failure(error) = operation.result else { return }
                    print(error.localizedDescription)
                    self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
            } else if let operation = operation as? DeleteRedundantAgentEntriesOperation {
                operation.completionBlock = {
                    if let error = operation.error {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    }
                }
            } else if let operation = operation as? UpdateAgentEntriesOperation {
                operation.completionBlock = {
                    if let error = operation.error {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    }
                }
            } else if let operation = operation as? AddAgentEntriesToStoreOperation {
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
        }
    }
    
    
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .destructive, handler: { action in
                
            }), controller: self, completion: {
                queue.cancelAllOperations()
                self.stopRefreshers()
            })
        }
    }
}
