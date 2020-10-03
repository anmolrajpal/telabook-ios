//
//  CallsTabAgents+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension CallsTabAgentsViewController {
    /*
    func observePendingMessagesCount() -> UInt {
        func mapToInt(value:AnyObject?) -> Int {
            switch value {
                case let value as Int: return value
                case let value as NSNumber: return value.intValue
                case let value as String: return Int(value) ?? 0
                default: return 0
            }
        }
        func mapToDate(value:AnyObject?) -> Date? {
            switch value {
                case let value as Int: return .getDate(fromSecondsOrMilliseconds: value)
                case let value as NSNumber: return .getDate(fromSecondsOrMilliseconds: value.intValue)
                case let value as String: return value.dateFromFormattedString
                default: return nil
            }
        }
        return reference.observe(.value, with: { snapshot in
            guard !self.agents.isEmpty else { return }
            //                print("Wasnotseen snapshot: \(snapshot)")
            let context = PersistentContainer.shared.newBackgroundContext()
            let agents = self.agents.compactMap { context.object(with: $0.objectID) as? Agent }
            var pendingMessages:[PendingMessage] = []
            for agent in agents {
                var count = 0
                var lastMessageDate:Date?
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let value = snapshot.value as? [String: AnyObject] {
                        let workerID = mapToInt(value: value["worker_id"])
                        if workerID == agent.workerID {
                            count += 1
                            lastMessageDate = mapToDate(value: value["date"])
                        }
                    }
                }
                pendingMessages.append(.init(agent: agent, count: count, lastMessageDate: lastMessageDate))
            }
            self.updateAgents(with: pendingMessages, context: context)
        }) { error in
            let message = "### \(#function) - Error observing wasnotseen reference node: \(error.localizedDescription)"
            printAndLog(message: message, log: .firebase, logType: .error)
        }
    }
    */
    
    
    private func updateAgents(with pendingMessages: [PendingMessage], context: NSManagedObjectContext) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = UpdatePendingMessagesCount_Operation(context: context, pendingMessages: pendingMessages)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue)
        queue.addOperation(operation)
    }
    
    
    internal func fetchAgents() {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = AgentOperations.getOperationsToFetchAgents(using: context, showOnlyDisabledAccounts: showOnlyDisabledAccounts)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                case let operation as FetchMostRecentAgentsEntryOperation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        } else {
                            
                        }
                }
                case let operation as DownloadAgentsEntriesFromServerOperation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.publicDescription, cancellingOperationQueue: queue)
                }
                case let operation as DeleteRedundantAgentEntriesOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        }
                }
                /* Not in use
                case let operation as UpdateAgentEntriesOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        }
                }
                */
                case let operation as UpsertAgentEntriesInStoreOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        } else {
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                            }
                        }
                }
                
                
                
                
                case let operation as UpdatePendingMessagesCount_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        }
                }
                default: break
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
