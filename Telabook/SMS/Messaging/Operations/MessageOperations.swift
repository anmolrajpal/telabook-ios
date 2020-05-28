//
//  MessageOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

struct MessageOperations {
    
    
    
    
    static func getOperationsToPersistMessagesInStore(using context:NSManagedObjectContext, forConversationWithCustomer customer:Customer, fromFirebaseEntries entries:[FirebaseMessage]?) -> [Operation] {
//        let fetchFromStore_Operation = FetchSavedCustomersEntries_Operation(context: context, agent: agent)
//        let deleteRedundantEntriesFromStore_Operation = DeleteRedundantCustomerEntries_Operation(context: context, agent: agent, serverEntries: entries)
        let addToStore_Operation = MergeMessageEntriesFromFirebaseToStore_Operation(context: context, conversation: customer, serverEntries: entries)
        return [addToStore_Operation]
        /*
        let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned deleteRedundantEntriesFromStore_Operation, unowned addToStore_Operation] in
            guard case let .success(entries) = fetchFromStore_Operation.result else {
                #if DEBUG
                print("Unresolved Error: Unable to get result(Customer) from fetchFromStore_Operation")
                #endif
                deleteRedundantEntriesFromStore_Operation.cancel()
                return
            }
            deleteRedundantEntriesFromStore_Operation.fetchedEntries = entries
            addToStore_Operation.fetchedEntries = entries
        }
        passFetchResultsToStore_Operation.addDependency(fetchFromStore_Operation)
        deleteRedundantEntriesFromStore_Operation.addDependency(passFetchResultsToStore_Operation)
        addToStore_Operation.addDependency(passFetchResultsToStore_Operation)
        
        return [
            fetchFromStore_Operation,
            passFetchResultsToStore_Operation,
            deleteRedundantEntriesFromStore_Operation,
            addToStore_Operation
        ]
         */
    }
}




/// Add Customers entries returned from the server to the Core Data store.
class MergeMessageEntriesFromFirebaseToStore_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error:OperationError?
//    var fetchedEntries:[Customer]?
    private let context: NSManagedObjectContext
    private let conversation:Customer
    private let serverEntries:[FirebaseMessage]?
    
    init(context: NSManagedObjectContext, conversation:Customer, serverEntries:[FirebaseMessage]?) {
        self.context = context
        self.conversation = conversation
        self.serverEntries = serverEntries
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        guard let serverEntries = serverEntries else {
            #if DEBUG
            print("No Server Entry to add, returning")
            #endif
            return
        }
        context.performAndWait {
            do {
//                _ = serverEntries.map { serverEntry -> Customer in
//                    let isPinned = fetchedEntries?.first(where: { conversation -> Bool in
//                        conversation.externalConversationID == serverEntry.conversationID
//                    })?.isPinned ?? false
                
//                    return Customer(context: context, conversationEntryFromFirebase: serverEntry, agent: agent, isPinned: isPinned)
                _ = serverEntries.map { UserMessage(context: context, messageEntryFromFirebase: $0, forConversationWithCustomer: conversation) }
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
        
    }
}
