//
//  CustomersServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase
import CoreData

extension CustomersViewController {
    
    
    func fetchConversations() {
        isDownloading = true
        if !isFetchedResultsAvailable {
            showLoadingPlaceholers()
            selectedSegment == .Inbox ? startInboxSpinner() : startArchivedSpinner()
        }
        printAndLog(message: "Previous firebase conversations fetched at: \(String(describing: agent.allConversationsFetchedAt))", log: .ui, logType: .info)
        if !allConversations.isEmpty && agent.allConversationsFetchedAt != nil {
            print("Fetching recent conversations")
            fetchRecentConversations()
        } else {
            print("Fetching all conversations")
            fetchAllConversations()
        }
    }
    
    
    /* -------------------------------------------------- Firebase ---------------------------------------------------------- */
    func addFirebaseObservers() {
        childAddedHandle = observeConversationAdded()
        childUpdatedHandle = observeConversationUpdated()
        childDeletedHandle = observeConversationDeleted()
    }
    func removeFirebaseObservers() {
        if childAddedHandle != nil { reference.removeObserver(withHandle: childAddedHandle)}
        if childUpdatedHandle != nil { reference.removeObserver(withHandle: childUpdatedHandle) }
        if childDeletedHandle != nil { reference.removeObserver(withHandle: childDeletedHandle) }
    }
    
    func getFirebaseConversation(forConversationID conversationID: Int, completion: @escaping (_ firebaseConversation: FirebaseCustomer?) -> Void) {
        let workerIDstring = String(agent.workerID)
        
        reference.child("\(conversationID)").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                    completion(firebaseConversation)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        } withCancel: { error in
            let errorMessage = "*** \(self) > ### \(#function) > Error fetching conversation for conversationID: \(conversationID) | Error: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
            completion(nil)
        }
    }
    
    private func fetchAllConversations() {
        let workerIDstring = String(agent.workerID)
        reference.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isDownloading = false
            self.saveConversationsFetchTime()
            printAndLog(message: "All firebase conversations fetched at: \(String(describing: self.agent.allConversationsFetchedAt))", log: .ui, logType: .info)
            
            guard snapshot.exists() else {
                self.stopRefreshers()
                self.handleState()
                return
            }
            var conversations = [FirebaseCustomer]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let conversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                        conversations.append(conversation)
                    }
                }
            }
            self.persistFirebaseEntriesToCoreDataStore(entries: conversations)
        } withCancel: { error in
            let errorMessage = "*** \(self) > ### \(#function) > Error fetching all conversations from Firebase <single event value observer> | Error: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    private func fetchRecentConversations() {
        let workerIDstring = String(agent.workerID)
        reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: agent.allConversationsFetchedAt!.milliSecondsSince1970).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isDownloading = false
            self.saveConversationsFetchTime()
            printAndLog(message: "Recent firebase conversations fetched at: \(String(describing: self.agent.allConversationsFetchedAt))", log: .ui, logType: .info)
            
            guard snapshot.exists() else {
                self.stopRefreshers()
                self.handleState()
                return
            }
            var conversations = [FirebaseCustomer]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let conversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                        conversations.append(conversation)
                    }
                }
            }
            
            self.upsertRecentFirebaseConversationsInStore(entries: conversations)
        } withCancel: { error in
            let errorMessage = "*** \(self) > ### \(#function) > Error fetching all conversations from Firebase <single event value observer> | Error: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    private func observeConversationAdded() -> UInt {
        let workerID = String(agent.workerID)
        return reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: screenEnteredAt.milliSecondsSince1970).observe(.childAdded, with: { [weak self] snapshot in
            guard let self = self else { return }
            if snapshot.exists() {
                guard let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerID) else {
                    return
                }
                self.persistFirebaseConversationInStore(entry: firebaseConversation)
            }
        }) { error in
            printAndLog(message: "*** \(self) > ### \(#function) > Firebase Child Added Observer Event Error while observing new conversation: \(error)", log: .firebase, logType: .error)
        }
    }
    private func observeConversationUpdated() -> UInt {
        let workerID = String(agent.workerID)
        return reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: screenEnteredAt.milliSecondsSince1970).observe(.childChanged, with: { [weak self] snapshot in
            guard let self = self else { return }
            if snapshot.exists() {
                guard let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerID) else {
                    return
                }
                self.persistFirebaseConversationInStore(entry: firebaseConversation)
            }
        }) { error in
            printAndLog(message: "*** \(self) > ### \(#function) > Firebase Child Added Observer Event Error while observing new conversation: \(error)", log: .firebase, logType: .error)
        }
    }
    private func observeConversationDeleted() -> UInt {
        let workerID = String(agent.workerID)
        return reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: screenEnteredAt.milliSecondsSince1970).observe(.childRemoved, with: { [weak self] snapshot in
            guard let self = self else { return }
            if snapshot.exists() {
                guard let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerID) else {
                    return
                }
                let conversationID = firebaseConversation.conversationID
                guard let conversationToDelete = self.getConversationFromStore(conversationID: conversationID, agent: self.agent) else {
                    print("Cannot find conversation to delete in core data store. | Conversation ID: \(conversationID)")
                    return
                }
                guard let context = self.agent.managedObjectContext else {
                    fatalError()
                }
                context.performAndWait {
                    self.agent.removeFromCustomers(conversationToDelete)
                    context.delete(conversationToDelete)
                    do {
                        if context.hasChanges { try context.save() }
                    } catch {
                        print(error)
                    }
                }
//                self.persistFirebaseConversationInStore(entry: firebaseConversation)
            }
        }) { error in
            printAndLog(message: "*** \(self) > ### \(#function) > Firebase Child Added Observer Event Error while observing new conversation: \(error)", log: .firebase, logType: .error)
        }
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    /* -------------------------------------------------- Core Data ---------------------------------------------------------- */
    func saveConversationsFetchTime() {
        agent.allConversationsFetchedAt = Date()
        guard let context = agent.managedObjectContext else {
            fatalError()
        }
        context.perform {
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "*** \(self) > ### \(#function) > Error saving context after setting allConversationsFetchedAt value. Error: \(error.localizedDescription)", log: .coredata, logType: .error)
                fatalError()
            }
        }
    }
    
    func getConversationFromStore(conversationID: Int, agent: Agent) -> Customer? {
        var conversation: Customer? = nil
        let fetchRequest:NSFetchRequest = Customer.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@ AND \(#keyPath(Customer.externalConversationID)) = %d", agent, Int32(conversationID))
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        guard let context = agent.managedObjectContext else {
            fatalError()
        }
        context.performAndWait {
            do {
                conversation = try fetchRequest.execute().first
            } catch {
                print("*** \(self) > ### \(#function) > Error fetching conversation from store for conversation id: \(conversationID). | Error: \(error.localizedDescription)")
            }
        }
        return conversation
    }
    
    internal func persistFirebaseConversationInStore(entry: FirebaseCustomer) {
        let existingConversation = getConversationFromStore(conversationID: entry.conversationID, agent: agent)
        let isPinned = existingConversation?.isPinned ?? false
        let customerDetails = existingConversation?.customerDetails?.serverObject
        guard let context = agent.managedObjectContext else {
            fatalError()
        }
        context.performAndWait {
            let conversation = Customer(context: context, conversationEntryFromFirebase: entry, agent: agent)
            conversation.isPinned = isPinned
            if let existingCustomerDetails = customerDetails {
                _ = CustomerDetails(context: context, customerDetailsEntryFromServer: existingCustomerDetails, conversationWithCustomer: conversation)
            }
            do {
                if context.hasChanges { try context.save() }
            } catch let error {
                printAndLog(message: "Error persisting observed message: \(error)", log: .coredata, logType: .error)
            }
        }
        handleMessagePayload()
    }
    
    internal func upsertRecentFirebaseConversationsInStore(entries: [FirebaseCustomer]) {
        guard let context = agent.managedObjectContext else {
            fatalError()
        }
        context.performAndWait {
            _ = entries.map { entry -> Customer in
                let existingConversation = self.getConversationFromStore(conversationID: entry.conversationID, agent: agent)
                let isPinned = existingConversation?.isPinned ?? false
                let customerDetails = existingConversation?.customerDetails?.serverObject
                let conversation = Customer(context: context, conversationEntryFromFirebase: entry, agent: agent)
                conversation.isPinned = isPinned
                if let existingCustomerDetails = customerDetails {
                    _ = CustomerDetails(context: context, customerDetailsEntryFromServer: existingCustomerDetails, conversationWithCustomer: conversation)
                }
                return conversation
            }
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "### \(#function) > Error upserting conversations in core data: \(error.localizedDescription)", log: .coredata, logType: .error)
            }
        }
        handleMessagePayload()
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func persistFirebaseEntriesToCoreDataStore(entries:[FirebaseCustomer]) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operations = CustomerOperations.getOperationsToPersistData(using: context, forAgent: agentRefrenceObject, fromFirebaseEntries:entries)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: {_ in })
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func updateConversation(for customer:Customer, archiving:Bool, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
//        context.parent = context
        let operations = CustomerOperations.getArchivingOperations(using: context, for: customer, shouldArchive: archiving)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func updateConversationInStore(for customer:Customer, archiving:Bool, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        //        context.parent = context
        let operation = UpdateConversationInStore_ArchivingOperation(context: context, selectedCustomer: customer, shouldArchive: archiving)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: completion)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func updateConversationInStore(for customer:Customer, pinning:Bool, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
//        let context = PersistentContainer.shared.newBackgroundContext()
//        let objectID = agent.objectID
//        let agentRefrenceObject = context.object(with: objectID) as! Agent
        let operation = UpdateConversationInStore_PinningOperation(context: context, selectedCustomer: customer, shouldPin: pinning)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: completion)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func blockConversation(for customer:Customer, blockingReason:String, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = BlacklistOperations.getOperationsToBlockConversation(using: context, for: customer, withReasonToBlock: blockingReason)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    private func markConversationInStore(isBlocking:Bool, for customer:Customer) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        let context = PersistentContainer.shared.newBackgroundContext()
        let operation = MarkBlockCustomerInStore_Operation(context: context, customer: customer, markBlock: isBlocking)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: {_ in})
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func deleteConversation(for customer:Customer, completion:@escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = CustomerOperations.getDeletionOperations(using: context, for: customer)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue, completion: completion)
        queue.addOperations(operations, waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    private func markConversationInStore(isDeleted:Bool, for customer:Customer) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        let context = PersistentContainer.shared.newBackgroundContext()
        let operation = MarkDeleteCustomerInStore_Operation(context: context, customer: customer, markDeleted: isDeleted)
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue, completion: {_ in})
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue, completion: @escaping (Bool) -> Void) {
        operations.forEach { operation in
            switch operation {
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Sync Customer Conversations Operations completions
                case let operation as FetchSavedCustomersEntries_Operation:
                    operation.completionBlock = {
                        if case let .failure(error) = operation.result {
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        } else {
                            
                        }
                }
                case let operation as DeleteRedundantCustomerEntries_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        }
                }
                case let operation as AddCustomerEntriesFromServerToStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            print(error.localizedDescription)
                            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                        } else {
                            DispatchQueue.main.async {
                                self.stopRefreshers()
                                self.handleState()
                                self.handleMessagePayload()
                            }
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Archive/Unarchive Customer Conversation Operations completions
                case let operation as UpdateConversationInStore_ArchivingOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: "Error updating Archiving operation in Store: \(error.localizedDescription)", log: .coredata, logType: .error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                }
                case let operation as UpdateConversationOnServer_ArchivingOperation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        self.updateConversationInStore(for: operation.customer, archiving: !operation.shouldArchive, completion: {_ in})
                        self.showAlert(withErrorMessage: error.publicDescription, cancellingOperationQueue: queue)
                        printAndLog(message: "Error updating Archiving operation on Server: \(error.localizedDescription)", log: .network, logType: .error)
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Pin/Unpin Customer Conversation Operation completion
                case let operation as UpdateConversationInStore_PinningOperation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: "Error updating Pinning operation in Store: \(error.localizedDescription)", log: .coredata, logType: .error)
                            completion(false)
                        } else {
                            completion(true)
                            DispatchQueue.main.async {
                                self.tableView.scrollToTopRow()
                            }
                        }
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Block conversation Operations completions
                case let operation as MarkBlockCustomerInStore_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            printAndLog(message: "Error updating Blacklist operation in Store: \(error.localizedDescription)", log: .coredata, logType: .error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                }
                case let operation as BlockCustomerOnServer_Operation:
                    operation.completionBlock = {
                        guard case let .failure(error) = operation.result else { return }
                        self.markConversationInStore(isBlocking: false, for: operation.customer)
                        self.showAlert(withErrorMessage: error.publicDescription, cancellingOperationQueue: queue)
                        printAndLog(message: "Error updating Blacklist operation on Server: \(error.localizedDescription)", log: .network, logType: .error)
                }
                /* ------------------------------------------------------------------------------------------------------------ */
                
                
                
                
                /* ------------------------------------------------------------------------------------------------------------ */
               //MARK: Delete conversation Operations completions
               case let operation as MarkDeleteCustomerInStore_Operation:
                   operation.completionBlock = {
                       if let error = operation.error {
                        printAndLog(message: "Error updating Delete operation in Store: \(error.localizedDescription)", log: .coredata, logType: .error)
                           DispatchQueue.main.async {
                               completion(false)
                           }
                       } else {
                           DispatchQueue.main.async {
                               completion(true)
                           }
                       }
               }
               case let operation as DeleteCustomerOnServer_Operation:
                   operation.completionBlock = {
                       guard case let .failure(error) = operation.result else { return }
                       self.markConversationInStore(isDeleted: false, for: operation.customer)
                       self.showAlert(withErrorMessage: error.publicDescription, cancellingOperationQueue: queue)
                    printAndLog(message: "Error updating Delete operation on Server: \(error.localizedDescription)", log: .network, logType: .error)
               }
               /* ------------------------------------------------------------------------------------------------------------ */
                
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
