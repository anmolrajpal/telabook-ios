//
//  AddressBook+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AddressBookViewController {
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func fetchContacts() {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        guard let agentRefrenceObject = context.object(with: agent.objectID) as? Agent, agentRefrenceObject.workerID != 0 else {
            dismiss(animated: true) {
                showAlert(withErrorMessage: "Unable to find Line.")
            }
            return
        }
        let operations = AddressBookOperations.getOperationsToFetchContacts(using: context, agent: agentRefrenceObject)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
            case let operation as FetchSavedContactEntries_Operation:
                operation.completionBlock = { [weak self] in
                    if case let .failure(error) = operation.result {
                        printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        guard let self = self else { return }
                        self.handleOperationCompletionState()
                    } else {
                        
                    }
                }
            case let operation as FetchContactEntriesFromServer_Operation:
                operation.completionBlock = { [weak self] in
                    guard case let .failure(error) = operation.result else { return }
                    printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                    guard let self = self else { return }
                    self.handleOperationCompletionState()
                    showAlert(withErrorMessage: error.publicDescription)
                }
            case let operation as DeleteRedundantContactEntries_Operation:
                operation.completionBlock = { [weak self] in
                    if let error = operation.error {
                        printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        guard let self = self else { return }
                        self.handleOperationCompletionState()
                    }
                }
            case let operation as UpsertContactEntriesInStore_Operation:
                operation.completionBlock = { [weak self] in
                    if let error = operation.error {
                        printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                    }
                    guard let self = self else { return }
                    self.handleOperationCompletionState()
                }
            default: break
            }
        }
    }
    func handleOperationCompletionState() {
        isDownloading = false
        stopRefreshers()
        handleState()
    }
}
