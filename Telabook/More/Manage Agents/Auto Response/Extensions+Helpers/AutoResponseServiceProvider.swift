//
//  AutoResponseServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension AutoResponseViewController {
    internal func fetchAutoResponse() {
        
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
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
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
//                            self.stopRefreshers()
                            self.updateSnapshot()
                        }
                    }
                }
            }
        }
    }
    
    
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, controller: self, completion: {
                queue.cancelAllOperations()
//                self.stopRefreshers()
            })
        }
    }
}
