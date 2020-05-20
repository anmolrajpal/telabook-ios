//
//  NewConversation+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import os

extension NewConversationController {
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func startNewConversation(with phoneNumber:String) {
        self.startRefreshers()
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = StartNewConversation_Operation(agentSenderID: String(senderID), phoneNumber: phoneNumber)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Start New Conversation Operation completion
                case let operation as StartNewConversation_Operation:
                    operation.completionBlock = {
                        guard case let .success(conversation) = operation.result else {
                            if case let .failure(error) = operation.result {
                                print(error.localizedDescription)
                                self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                            }
                            return
                        }
                        guard let conversationID = conversation.externalConversationId, let node = conversation.node else {
                            self.showAlert(withErrorMessage: "Unable to get required data from server", cancellingOperationQueue: queue)
                            return
                        }
                        self.conversationDidStart(withID: conversationID, node: node)
                        
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
                self.stopRefreshers()
            })
        }
    }
}
