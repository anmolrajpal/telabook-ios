//
//  AgentsServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os
import Firebase
import CoreData


struct PendingMessage {
    let agent:Agent
    let count:Int
    let lastMessageDate:Date?
}
private extension Int {
    var formattedBadgeValue:String? {
        if self > 99 {
            return "99+"
        } else if self > 0 {
            return String(self)
        } else {
            return nil
        }
    }
}

extension AgentsViewController {
    
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
           /*
           ["unread_messages": 3,
            "error": 0,
            "sent_by_api": 0,
            "delivered_by_provider": 0,
            "archive": 0,
            "all_last_message_seen": 2021-07-26T14:33:32.471251Z,
            "last_read_time": 1645579210121,
            "blacklist_reason": no reason,
            "last_message_date": 1645605882,
            "external_conversation_id": 94140,
            "customer_id": 64622,
            "external_conversation_black_list": 0,
            "updated_at": 1645605881733,
            "message_type": MULTIMEDIA,
            "last_message_key": -Mw_kFTmJ0rXcYfJZyAP,
            "archived": 0,
            "priority": 0,
            "node": 232-64622-Customer,
            "deleted": 0,
            "worker_phone_number": +18135885444,
            "colour": 3,
            "incoming": 1,
            "lastmessages": {
               "-Mw_kEKtjFkaMJ4dDohx" =     {
                   conversationId = 94140;
                   date = 1645605876943;
                   incoming = 1;
                   isImage = 0;
                   message = "Rachel, 25,";
                   sender = 64622;
                   "sender_is_worker" = 0;
                   "sender_name" = "";
                   "sender_number" = "+14349620029";
                   type = sms;
                   "updated_at" = 1645605876942;
               };
           },
            "last_message_datetime": 1645605882,
            "sent_by_app": 0,
            "customer_phone_number": +14349620029,
            "all_last_message_text": ,
            "worker_person": LA Recruiting,
            "sender_id": 232,
            "sent_by_provider": 0]
           */
            
           let context = PersistentContainer.shared.newBackgroundContext()
            let agents = self.agents.compactMap { context.object(with: $0.objectID) as? Agent }
            var totalCount = 0
            var pendingMessages:[PendingMessage] = []
           
            for agent in agents {
                var count = 0
                var lastMessageDate:Date?
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let value = snapshot.value as? [String: AnyObject] {
                        let workerID = mapToInt(value: value["sender_id"])
                        if workerID == agent.workerID {
                            count = mapToInt(value: value["unread_messages"])
                            lastMessageDate = mapToDate(value: value["date"])
                        }
                    }
                }
                totalCount += count
                pendingMessages.append(.init(agent: agent, count: count, lastMessageDate: lastMessageDate))
            }
            self.updateTabBarBadge(withCount: totalCount)
            self.updateAgents(with: pendingMessages, context: context)
           
           /*
           for child in snapshot.children {
              if let snapshot = child as? DataSnapshot,
                 let value = snapshot.value as? [String: AnyObject] {
                 let workerID = mapToInt(value: value["sender_id"])
                 let count = mapToInt(value: value["unread_messages"])
                 let lastMessageDate = mapToDate(value: value["date"])
//                 updateCounter(ofAgentWithID: workerID, count: count, lastMessageDate: lastMessageDate)
              }
           }
           */
           
        }) { error in
            let message = "### \(#function) - Error observing wasnotseen reference node: \(error.localizedDescription)"
            printAndLog(message: message, log: .firebase, logType: .error)
        }
    }
   
   private func updateCounter(ofAgentWithID workerID: Int, count: Int, lastMessageDate:Date?) {
      
   }
    func setInitialPendingMessagesCount() {
        let count = Int(agents.map({ $0.externalPendingMessagesCount }).sum())
        updateTabBarBadge(withCount: count)
    }
    private func updateTabBarBadge(withCount count: Int) {
        guard let tbc = tabBarController as? TabBarController,
              let items = tbc.tabBar.items,
              items.count == 3 else {
            return
        }
        items[TabBarController.Tabs.tab1.rawValue].badgeValue = count.formattedBadgeValue
    }
    
    
    private func updateAgents(with pendingMessages: [PendingMessage], context:NSManagedObjectContext) {
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
                            self.isDownloading = false
                            self.stopRefreshers()
                            self.handleState()
                        } else {
                            
                        }
                }
                case let operation as DownloadAgentsEntriesFromServerOperation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        self.isDownloading = false
                        self.stopRefreshers()
                        self.handleState()
                        self.showAlert(withErrorMessage: error.publicDescription, cancellingOperationQueue: queue)
                }
                case let operation as DeleteRedundantAgentEntriesOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            self.isDownloading = false
                            self.stopRefreshers()
                            self.handleState()
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
                            self.isDownloading = false
                            self.stopRefreshers()
                            self.handleState()
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        } else {
                            DispatchQueue.main.async {
                                self.isDownloading = false
                                self.stopRefreshers()
                                self.handleState()
                                self.handleMessagePayload()
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
