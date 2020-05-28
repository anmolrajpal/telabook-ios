//
//  MoreServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//


import UIKit
import os

extension MoreViewController {
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func dumpCoreData() {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = DeleteAllEntities_Operation(context: PersistentContainer.shared.newBackgroundContext())
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Delete All Entities Operation completion
                case let operation as DeleteAllEntities_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                self.delegate?.presentLogin()
                            }
                        }
                }
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
            })
        }
    }
}
