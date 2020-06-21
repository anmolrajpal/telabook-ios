//
//  MessageOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import Firebase

struct MessageOperations {
    
    
    
    
    static func getOperationsToPersistMessagesInStore(using context:NSManagedObjectContext, forConversationWithCustomer customer:Customer, fromFirebaseEntries entries:[FirebaseMessage]?, fetchedEntries:[UserMessage]?) -> [Operation] {
        //        let fetchFromStore_Operation = FetchSavedCustomersEntries_Operation(context: context, agent: agent)
        //        let deleteRedundantEntriesFromStore_Operation = DeleteRedundantCustomerEntries_Operation(context: context, agent: agent, serverEntries: entries)
        let addToStore_Operation = MergeMessageEntriesFromFirebaseToStore_Operation(context: context, conversation: customer, serverEntries: entries, fetchedEntries: fetchedEntries)
        return [addToStore_Operation]
        /*
         let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned deleteRedundantEntriesFromStore_Operation, unowned addToStore_Operation] in
         guard case let .success(entries) = fetchFromStore_Operation.result else {
         #if !RELEASE
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
    
    
    
    
    
    static func getOperationsToSend(newTextMessage message:NewMessage, using context:NSManagedObjectContext, forConversationWithCustomer conversation:Customer, messageReference:DatabaseReference, conversationReference:DatabaseReference) -> [Operation] {
        let addToStore_Operation = AddNewMessageEntryToStore_Operation(context: context, conversation: conversation, message: message)
        let updateEntryToFirebase_Operation = UpdateNewMessageEntryToFirebase_Operation(messageReference: messageReference, conversationReference: conversationReference)
        let sendOnServer_Operation = SendNewTextMessageOnServer_Operation(customer: conversation)
        
        
        let passNewlyCreatedEntryFromStore_Operation = BlockOperation { [unowned addToStore_Operation, unowned updateEntryToFirebase_Operation, unowned sendOnServer_Operation] in
            guard let messageFromStore = addToStore_Operation.newMessageFromStore, addToStore_Operation.error == nil else {
                #if !RELEASE
                print("Unresolved Error: Unable to get newly created result(UserMessage) from addToStore_Operation")
                #endif
                updateEntryToFirebase_Operation.cancel()
                sendOnServer_Operation.cancel()
                return
            }
            updateEntryToFirebase_Operation.newMessageFromStore = messageFromStore
            sendOnServer_Operation.newlyCreatedMessage = messageFromStore
        }
        passNewlyCreatedEntryFromStore_Operation.addDependency(addToStore_Operation)
        updateEntryToFirebase_Operation.addDependency(passNewlyCreatedEntryFromStore_Operation)
        sendOnServer_Operation.addDependency(passNewlyCreatedEntryFromStore_Operation)
        
        
        let guardFirebaseEntry_Operation = BlockOperation { [unowned updateEntryToFirebase_Operation, unowned sendOnServer_Operation] in
            guard case let .success(success) = updateEntryToFirebase_Operation.result, success else {
                if case let .failure(error) = updateEntryToFirebase_Operation.result {
                    print(error)
                }
                #if !RELEASE
                print("Unresolved Error: Unable to update message on Firebase")
                #endif
                sendOnServer_Operation.cancel()
                return
            }
        }
        guardFirebaseEntry_Operation.addDependency(updateEntryToFirebase_Operation)
        sendOnServer_Operation.addDependency(guardFirebaseEntry_Operation)
        return [
            addToStore_Operation,
            passNewlyCreatedEntryFromStore_Operation,
            updateEntryToFirebase_Operation,
            guardFirebaseEntry_Operation,
            sendOnServer_Operation
        ]
    }
    
    
    
    static func getOperationsToSend(newMultimediaMessage message:NewMessage, using context:NSManagedObjectContext, forConversationWithCustomer conversation:Customer) -> [Operation] {
        let addToStore_Operation = AddNewMessageEntryToStore_Operation(context: context, conversation: conversation, message: message)
        let sendOnServer_Operation = SendNewTextMessageOnServer_Operation(customer: conversation)
        
        let passNewlyCreatedEntryFromStore_Operation = BlockOperation { [unowned addToStore_Operation, unowned sendOnServer_Operation] in
            guard let messageFromStore = addToStore_Operation.newMessageFromStore else {
                #if !RELEASE
                print("Unresolved Error: Unable to get newly created result(UserMessage) from addToStore_Operation")
                #endif
                sendOnServer_Operation.cancel()
                return
            }
            sendOnServer_Operation.newlyCreatedMessage = messageFromStore
        }
        passNewlyCreatedEntryFromStore_Operation.addDependency(addToStore_Operation)
        sendOnServer_Operation.addDependency(passNewlyCreatedEntryFromStore_Operation)
        return [
            addToStore_Operation,
            passNewlyCreatedEntryFromStore_Operation,
            sendOnServer_Operation
        ]
    }
    
    
    
    
    
    
    
    
    
    static func getOperationsToClearUnreadMessagesCount(using context:NSManagedObjectContext, forConversationWithCustomer conversation:Customer, unreadMessagesCountNodeReference:DatabaseReference, conversationReference:DatabaseReference, updatedAt:Date) -> [Operation] {
        let updateEntryInStore_Operation = ClearUnreadMessagesCountInStore_Operation(context: context, conversation: conversation, updatedAt: updatedAt)
        let updateEntryToFirebase_Operation = ClearUnreadMessagesCountOnFirebase_Operation(unreadMessagesCountNodeReference: unreadMessagesCountNodeReference, conversationReference: conversationReference, conversation: conversation, updatedAt: updatedAt)
        return [updateEntryInStore_Operation, updateEntryToFirebase_Operation]
    }
    
    
    
    
    
    
    
    
    static func getOperationsToDeleteUserMessage(using context:NSManagedObjectContext, message:UserMessage, messageReference:DatabaseReference, updatedAt:Date) -> [Operation] {
        let updateEntryInStore_Operation = MarkMessageDeletedInStore_Operation(context: context, message: message, updatedAt: updatedAt)
        let updateEntryToFirebase_Operation = MarkMessageDeletedOnFirebase_Operation(message: message, messageReference: messageReference, updatedAt: updatedAt)
        return [updateEntryInStore_Operation, updateEntryToFirebase_Operation]
    }
    
    
    
    
    
    
    
    
    
    
    fileprivate static func updateNewMessageToFirebase(message:UserMessage, messageReference:DatabaseReference, conversationReference:DatabaseReference, completion: @escaping (Result<Bool, FirebaseAuthService.FirebaseError>) -> ()) {
        messageReference.child(message.messageId).setValue(message.toFirebaseObject()) { (error, _) in
            if let error = error {
                #if !RELEASE
                print(error.localizedDescription)
                #endif
                completion(.failure(.databaseSetValueError(error)))
            } else {
                conversationReference.child(String(message.conversationID)).updateChildValues(FirebaseCustomer.getUpdatedConversationObject(fromLastMessage: message)) { (error, _) in
                    if let error = error {
                        #if !RELEASE
                        print(error.localizedDescription)
                        #endif
                        completion(.failure(.databaseUpdateValueError(error)))
                    } else {
                        completion(.success(true))
                    }
                }
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    fileprivate static func clearUnreadMessagesCountOnFirebase(conversationID:String, unreadMessagesCountNodeReference:DatabaseReference, conversationsNodeReference:DatabaseReference, updatedAt:Date, completion: @escaping (Result<Bool, FirebaseAuthService.FirebaseError>) -> ()) {
        unreadMessagesCountNodeReference.removeValue { (error, _) in
            if let error = error {
                #if !RELEASE
                print(error.localizedDescription)
                #endif
                completion(.failure(.databaseRemoveValueError(error)))
            } else {
                conversationsNodeReference.child(conversationID).updateChildValues(FirebaseCustomer.getClearMessagesCountConversationObject(updatedAt: updatedAt)) { (error, _) in
                    if let error = error {
                        #if !RELEASE
                        print(error.localizedDescription)
                        #endif
                        completion(.failure(.databaseUpdateValueError(error)))
                    } else {
                        completion(.success(true))
                    }
                }
            }
        }
    }
    
    
    
    
    
    fileprivate static func deleteUserMessageOnFirebase(message:UserMessage, updatedAt:Date, messageReference:DatabaseReference, completion: @escaping (Result<Bool, FirebaseAuthService.FirebaseError>) -> Void) {
        messageReference.updateChildValues(message.getDeletedFirebaseObject(updatedAt: updatedAt)) { (error, _) in
            if let error = error {
                #if !RELEASE
                print(error.localizedDescription)
                #endif
                completion(.failure(.databaseUpdateValueError(error)))
            } else {
                completion(.success(true))
            }
        }
    }
}






/*
 /// Fetches saved UserMessage Entries from the Core Data store.
 class FetchSavedUserMessageEntries_Operation: Operation {
 enum OperationError: Error, LocalizedError {
 case coreDataError(error:Error)
 
 var localizedDescription: String {
 switch self {
 case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
 }
 }
 }
 private let context: NSManagedObjectContext
 private let agent:Agent
 var result: Result<[UserMessage], OperationError>?
 
 init(context: NSManagedObjectContext, agent:Agent) {
 self.context = context
 self.agent = agent
 }
 
 override func main() {
 let request: NSFetchRequest<Customer> = Customer.fetchRequest()
 request.predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
 request.sortDescriptors = [NSSortDescriptor(key: #keyPath(QuickResponse.updatedAt), ascending: false)]
 
 context.performAndWait {
 do {
 let fetchResults = try context.fetch(request)
 self.result = .success(fetchResults)
 } catch {
 let message = "Error fetching from context: \(error)"
 #if !RELEASE
 print(message)
 #endif
 os_log("%@", log: .coredata, type: .error, message)
 self.result = .failure(.coreDataError(error: error))
 }
 }
 }
 }
 */


/// Add Message entries returned from the server to the Core Data store.
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
    
    private let context: NSManagedObjectContext
    private let conversation:Customer
    let serverEntries:[FirebaseMessage]?
    let fetchedEntries:[UserMessage]?
    init(context: NSManagedObjectContext, conversation:Customer, serverEntries:[FirebaseMessage]?, fetchedEntries:[UserMessage]?) {
        self.context = context
        self.conversation = conversation
        self.serverEntries = serverEntries
        self.fetchedEntries = fetchedEntries
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        guard let serverEntries = serverEntries else {
            printAndLog(message: "No firebase message entries to add", log: .firebase, logType: .info)
            return
        }
        context.performAndWait {
            do {
                
                _ = serverEntries.map { serverEntry -> UserMessage in
                    let fetchedEntry = fetchedEntries?.first(where: { $0.firebaseKey == serverEntry.firebaseKey })
                    let isSeen = fetchedEntry?.isSeen ?? true
                    let cachedImageUUID = fetchedEntry?.imageUUID
                    return UserMessage(context: context, messageEntryFromFirebase: serverEntry, forConversationWithCustomer: conversation, imageUUID: cachedImageUUID, isSeen: isSeen)
                }
                //_ = serverEntries.map { UserMessage(context: context, messageEntryFromFirebase: $0, forConversationWithCustomer: conversation, imageUUID: nil) }
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}







// MARK: - /**************************************** UPDATE USER MESSAGE- <SET SEEN = true> OPERATIONS <BEGIN> ****************************************/


/// Set  message's isSeen flag to`1`  in the Core Data store.
class MarkAllMessagesAsSeenInStore_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error:OperationError?
    private let context: NSManagedObjectContext
    private let conversation:Customer
    init(context: NSManagedObjectContext, conversation:Customer) {
        self.context = context
        self.conversation = conversation
    }
    
    override func main() {
        let request = NSBatchUpdateRequest(entityName: NSStringFromClass(UserMessage.self))
        request.predicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", conversation)
        request.propertiesToUpdate = ["isSeen" : true]
        request.resultType = .updatedObjectIDsResultType
        do {
            let batchUpdateResult = try self.context.execute(request) as? NSBatchUpdateResult
            if let updatedObjectIDs = batchUpdateResult?.result as? [NSManagedObjectID] {
                let changes = [NSUpdatedObjectsKey: updatedObjectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [PersistentContainer.shared.viewContext])
            }
        } catch {
            printAndLog(message: "Error batch updating user messages mark seen: \(error)", log: .coredata, logType: .error)
        }
    }
}










/// Add new user message entry created by user pressing send button to the Core Data store.
class AddNewMessageEntryToStore_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error:OperationError?
    private let context: NSManagedObjectContext
    private let conversation:Customer
    private let newMessage:NewMessage
    var newMessageFromStore:UserMessage?
    init(context: NSManagedObjectContext, conversation:Customer, message:NewMessage) {
        self.context = context
        self.conversation = conversation
        self.newMessage = message
    }
    
    override func main() {
        context.performAndWait {
            do {
                newMessageFromStore = UserMessage(context: context, newMessageEntryFromCurrentUser: newMessage, forConversationWithCustomer: conversation)
                try context.save()
            } catch {
                #if !RELEASE
                print("Error adding entries to store: \(error))")
                #endif
                self.error = .coreDataError(error: error)
            }
        }
        
    }
}




/// Update Newly created message entry from core date store to Firebase..
class UpdateNewMessageEntryToFirebase_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case messageReference(error:Error)
        case conversationReference(error:Error)
        var localizedDescription: String {
            switch self {
                case let .messageReference(error): return "Firebase Message Reference Error: \(error.localizedDescription)"
                case let .conversationReference(error): return "Firebase Conversation Reference Error: \(error.localizedDescription)"
            }
        }
    }
    var result:Result<Bool, FirebaseAuthService.FirebaseError>?
    private var downloading = false
    
    var newMessageFromStore:UserMessage?
    let messageReference:DatabaseReference
    let conversationReference:DatabaseReference
    
    init(messageReference:DatabaseReference, conversationReference:DatabaseReference) {
        self.messageReference = messageReference
        self.conversationReference = conversationReference
    }
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        finish(result: .failure(.cancelled))
    }
    
    func finish(result: Result<Bool, FirebaseAuthService.FirebaseError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        guard let message = newMessageFromStore else {
            #if !RELEASE
            print("Unresolved Error: Failed to unwrap new message entry from store.")
            #endif
            return
        }
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        MessageOperations.updateNewMessageToFirebase(message: message, messageReference: messageReference, conversationReference: conversationReference, completion: finish)
    }
}





/// Send New Text Message on the server operation.
class SendNewTextMessageOnServer_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    private var downloading = false
    
    let customer:Customer
    var newlyCreatedMessage:UserMessage?
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json")
    ]
    
    init(customer:Customer) {
        self.customer = customer
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        finish(result: .failure(.cancelled))
    }
    
    func finish(result: Result<APIService.RecurrentResult, APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        
        let errorMessage = "Error: No results from server"
        
        guard case let .success(resultData) = result else {
            if case let .failure(error) = result {
                self.result = .failure(error)
                didChangeValue(forKey: #keyPath(isFinished))
                didChangeValue(forKey: #keyPath(isExecuting))
            }
            return
        }
        guard let serverResultValue = resultData.result else {
            self.result = .failure(.resultError(message: errorMessage))
            didChangeValue(forKey: #keyPath(isFinished))
            didChangeValue(forKey: #keyPath(isExecuting))
            return
        }
        let serverResult = ServerResult(rawValue: serverResultValue)
        guard serverResult == .success else {
            self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
            didChangeValue(forKey: #keyPath(isFinished))
            didChangeValue(forKey: #keyPath(isExecuting))
            return
        }
        self.result = .success(true)
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        guard let message = newlyCreatedMessage else {
            return
        }
        let companyID = String(AppData.companyId)
        let params = [
            "company_id":companyID,
            "id":String(customer.externalConversationID),
            "fb_key":message.messageId,
            "message": message.textMessage ?? ""
        ]
        print(params)
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .SendMessage, httpMethod: .POST, params: params, headers: headers, completion: finish)
    }
}


















// MARK: - /**************************************** CLEAR UNREAD MESSAGES COUNT OPERATIONS <BEGIN> ****************************************/


/// Set `0` for unread messages count property for specified conversation with customer in the Core Data store.
class ClearUnreadMessagesCountInStore_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error:OperationError?
    private let context: NSManagedObjectContext
    private let conversation:Customer
    private let updatedAt:Date
    init(context: NSManagedObjectContext, conversation:Customer, updatedAt:Date) {
        self.context = context
        self.conversation = conversation
        self.updatedAt = updatedAt
    }
    
    override func main() {
        context.performAndWait {
            do {
                conversation.unreadMessagesCount = 0
                conversation.updatedAt = updatedAt
                try context.save()
            } catch {
                #if !RELEASE
                print("Error adding entries to store: \(error))")
                #endif
                self.error = .coreDataError(error: error)
            }
        }
        
    }
}




/// Update the Unread Message count value for conversation with customer on Firebase.
class ClearUnreadMessagesCountOnFirebase_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case conversationReference(error:Error)
        var localizedDescription: String {
            switch self {
                case let .conversationReference(error): return "Firebase Conversation Reference Error: \(error.localizedDescription)"
            }
        }
    }
    var result:Result<Bool, FirebaseAuthService.FirebaseError>?
    private var downloading = false
    
    let unreadMessagesCountNodeReference:DatabaseReference
    let conversationReference:DatabaseReference
    let conversation:Customer
    let updatedAt:Date
    init(unreadMessagesCountNodeReference:DatabaseReference, conversationReference:DatabaseReference, conversation:Customer, updatedAt:Date) {
        self.unreadMessagesCountNodeReference = unreadMessagesCountNodeReference
        self.conversationReference = conversationReference
        self.conversation = conversation
        self.updatedAt = updatedAt
    }
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        finish(result: .failure(.cancelled))
    }
    
    func finish(result: Result<Bool, FirebaseAuthService.FirebaseError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        MessageOperations.clearUnreadMessagesCountOnFirebase(conversationID: String(conversation.externalConversationID), unreadMessagesCountNodeReference: unreadMessagesCountNodeReference, conversationsNodeReference: conversationReference, updatedAt: updatedAt, completion: finish)
    }
}

// MARK: /**************************************** CLEAR UNREAD MESSAGES COUNT OPERATIONS <END> ****************************************/















// MARK: - /**************************************** DELETE USER MESSAGE OPERATIONS <BEGIN> ****************************************/


/// Set  message's deleted flag to`1`  in the Core Data store.
class MarkMessageDeletedInStore_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error:OperationError?
    private let context: NSManagedObjectContext
    private let updatedAt:Date
    private let message:UserMessage
    init(context: NSManagedObjectContext, message:UserMessage, updatedAt:Date) {
        self.context = context
        self.message = message
        self.updatedAt = updatedAt
    }
    
    override func main() {
        context.performAndWait {
            do {
                message.isMessageDeleted = true
                message.updatedAt = updatedAt
                try context.save()
            } catch {
                #if !RELEASE
                print("Error adding entries to store: \(error))")
                #endif
                self.error = .coreDataError(error: error)
            }
        }
        
    }
}




/// Update the User Message and set  message's deleted flag to`1`  on Firebase.
class MarkMessageDeletedOnFirebase_Operation: Operation {
    
    var result:Result<Bool, FirebaseAuthService.FirebaseError>?
    private var downloading = false
    
    let messageReference:DatabaseReference
    let message:UserMessage
    private let updatedAt:Date
    init(message:UserMessage, messageReference:DatabaseReference, updatedAt:Date) {
        self.message = message
        self.messageReference = messageReference
        self.updatedAt = updatedAt
    }
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        finish(result: .failure(.cancelled))
    }
    
    func finish(result: Result<Bool, FirebaseAuthService.FirebaseError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        MessageOperations.deleteUserMessageOnFirebase(message: message, updatedAt: updatedAt, messageReference: messageReference, completion: finish)
    }
}

// MARK: /**************************************** DELETE USER MESSAGE OPERATIONS <END> ****************************************/
