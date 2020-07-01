//
//  ScheduleMessageDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
extension ScheduleMessageViewController {
    internal func fetchScheduledMessages() {
        if scheduledMessages.isEmpty {
            self.startSpinner()
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = ScheduledMessagesOperations.getOperationsToFetchScheduledMessages(using: context)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue, completion: @escaping (Bool) -> Void) {
        operations.forEach { operation in
            switch operation {
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Sync Scheduled Messages Operations completions
                case let operation as FetchScheduledMessagesFromServer_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                
                case let operation as MergeScheduledMessagesFromServerToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                default: break
            }
        }
    }
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController.telaAlertController(title: "Error", message: message)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
            action.setTitleColor(color: .telaBlue)
            alert.addAction(action)
            self.present(alert, animated: true) {
                queue.cancelAllOperations()
            }
        }
    }
}
