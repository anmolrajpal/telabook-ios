//
//  CustomerOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import os

struct CustomerOperations {
//    func huh() {
//        APIServer<APIService.EmptyData>(apiVersion: .v1).hitEndpoint(endpoint: .AutoResponse, httpMethod: .DELETE) { (result: Result<APIService.EmptyData, APIService.APIError>) in
//
//        }
//    }
    
    static func getOperationsToPersistData(using context:NSManagedObjectContext, forAgent agent:Agent, fromFirebaseEntries entries:[FirebaseCustomer]?) -> [Operation] {
        let fetchFromStore_Operation = FetchSavedCustomersEntries_Operation(context: context, agent: agent)
        let deleteRedundantEntriesFromStore_Operation = DeleteRedundantCustomerEntries_Operation(context: context, agent: agent, serverEntries: entries)
        let addToStore_Operation = AddCustomerEntriesFromServerToStore_Operation(context: context, agent: agent, serverEntries: entries)

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
    }
    
    
    
    
    
    
    
    
    //MARK: POST - Archive/Unarchive Agent's Conversation with Customer in store and on Server
    /// Returns an array of operations for archiving/unarchiving  Agent's conversation with Customer  from Core Data store to server.
    static func getArchivingOperations(using context: NSManagedObjectContext, for selectedCustomer:Customer, shouldArchive:Bool) -> [Operation] {
        
        let updateEntryInStore_Operation = UpdateConversationInStore_ArchivingOperation(context: context, selectedCustomer: selectedCustomer, shouldArchive: shouldArchive)
        let updateEntryOnServer_Operation = UpdateConversationOnServer_ArchivingOperation(selectedCustomer: selectedCustomer, shouldArchive: shouldArchive)
        
        return [
            updateEntryInStore_Operation,
            updateEntryOnServer_Operation
        ]
    }
    
    
    
    
    //MARK: DELETE - Delete Agent's Conversation with Customer in store and on Server
    /// Returns an array of operations for delete  Agent's conversation with Customer  from Core Data store to server.
    static func getDeletionOperations(using context:NSManagedObjectContext, for customer:Customer, shouldDelete:Bool = true) -> [Operation] {
        let markDeleteInStore_Operation = MarkDeleteCustomerInStore_Operation(context: context, customer: customer, markDeleted: shouldDelete)
        let deleteOnServer_Operation = DeleteCustomerOnServer_Operation(customer: customer)
        
        return [markDeleteInStore_Operation, deleteOnServer_Operation]
    }
    
}





/// Fetches saved Customers Entries from the Core Data store.
class FetchSavedCustomersEntries_Operation: Operation {
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
    var result: Result<[Customer], OperationError>?
    
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


/*
/// Downloads Customers entries from the server.
class DownloadCustomrersEntriesFromServer_Operation: Operation {
    var result: Result<[CustomerCodable.Datum.Conversation], APIService.APIError>?
    
    private var downloading = false
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
    ]
    init(workerID:Int) {
        params = [
            "company_id":String(AppData.companyId),
            "worker_id":String(workerID)
        ]
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
        
    }
    
    func finish(result: Result<CustomerCodable, APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        let errorMessage = "Error: No results from server"
        guard case let .success(resultData) = result,
            let serverResultValue = resultData.result else {
                finish(result: .failure(.resultError(message: errorMessage)))
                return
        }
        let serverResult = ServerResult(rawValue: serverResultValue)
        guard serverResult == .success, let data = resultData.data, let conversations = data.conversations else {
            finish(result: .failure(.resultError(message: resultData.message ?? errorMessage)))
            return
        }
        self.result = .success(conversations)
        
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
//        APIServer<CustomerCodable>(apiVersion: .v2).hitEndpoint(endpoint: .FetchCustomers, httpMethod: .POST, params: params, completion: finish)
    }
}
*/

/// Deletes the redundant Customer entries from core data store.
class DeleteRedundantCustomerEntries_Operation: Operation {
    
    private let context: NSManagedObjectContext
    
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error: OperationError?
    
    private let agent:Agent
    private let serverEntries:[FirebaseCustomer]?
    
    var fetchedEntries:[Customer]?
    
    
    
    init(context: NSManagedObjectContext, agent:Agent, serverEntries:[FirebaseCustomer]?) {
        self.context = context
        self.agent = agent
        self.serverEntries = serverEntries
    }
    convenience init(context: NSManagedObjectContext, fetchedEntries: [Customer]?, serverEntries:[FirebaseCustomer]?, agent:Agent) {
        self.init(context: context, agent:agent, serverEntries:serverEntries)
        self.fetchedEntries = fetchedEntries
    }
    
    override func main() {
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        
        guard fetchedEntries != nil, !fetchedEntries!.isEmpty else {
            print("No Fetched Entries or nil")
            return
        }
        
        if let serverEntries = serverEntries,
            !serverEntries.isEmpty {
            let serverIDs = serverEntries.map { $0.conversationID }.compactMap { $0 }
            let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
            let filterPredicate = NSPredicate(format: "NOT (\(#keyPath(Customer.externalConversationID)) IN %@)", serverIDs)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [agentPredicate, filterPredicate])
        } else {
            print("No Server Entries, deleting all entries")
        }
        
        context.performAndWait {
            do {
                let entriesToDelete = try context.fetch(fetchRequest)
                _ = entriesToDelete.map { agent.removeFromCustomers($0) }
//                _ = entriesToDelete.map { context.delete($0) }
                try context.save()
            } catch {
                print("Error deleting entries: \(error)")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Add Customers entries returned from the server to the Core Data store.
class AddCustomerEntriesFromServerToStore_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error:OperationError?
    var fetchedEntries:[Customer]?
    private let context: NSManagedObjectContext
    private let agent:Agent
    private let serverEntries:[FirebaseCustomer]?
    
    init(context: NSManagedObjectContext, agent:Agent, serverEntries:[FirebaseCustomer]?) {
        self.context = context
        self.agent = agent
        self.serverEntries = serverEntries
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        guard let serverEntries = serverEntries else {
            #if !RELEASE
            print("No Server Entry to add, returning")
            #endif
            return
        }
        
        // Process records in batches to avoid a high memory footprint.
        let batchSize = 100
        let count = serverEntries.count
        
        // Determine the total number of batches.
        var numBatches = count / batchSize
        numBatches += count % batchSize > 0 ? 1 : 0
        
        for batchNumber in 0 ..< numBatches {
            
            // Determine the range for this batch.
            let batchStart = batchNumber * batchSize
            let batchEnd = batchStart + min(batchSize, count - batchNumber * batchSize)
            let range = batchStart..<batchEnd
            
            // Create a batch for this range from the decoded JSON.
            let batch = Array(serverEntries[range])
            
            context.performAndWait {
                
                _ = batch.map { serverEntry -> Customer in
                    let existingConversation = fetchedEntries?.first(where: { $0.externalConversationID == serverEntry.conversationID })
                    let isPinned = existingConversation?.isPinned ?? false
                    let customerDetails = existingConversation?.customerDetails?.serverObject
                    let conversation = Customer(context: context, conversationEntryFromFirebase: serverEntry, agent: agent)
                    conversation.isPinned = isPinned
                    if let existingCustomerDetails = customerDetails {
                        _ = CustomerDetails(context: context, customerDetailsEntryFromServer: existingCustomerDetails, conversationWithCustomer: conversation)
                    }
                    return conversation
                }
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        print("Error upserting firebase conversations to core data: \(error)\nCould not save Core Data context.")
                        self.error = .coreDataError(error: error)
                        return
                    }
//                    context.reset()
                }
            }
        }
        /*
        context.performAndWait {
            _ = serverEntries.map { serverEntry -> Customer in
                let existingConversation = fetchedEntries?.first(where: { $0.externalConversationID == serverEntry.conversationID })
                let isPinned = existingConversation?.isPinned ?? false
                let customerDetails = existingConversation?.customerDetails?.serverObject
                let conversation = Customer(context: context, conversationEntryFromFirebase: serverEntry, agent: agent)
                conversation.isPinned = isPinned
                if let existingCustomerDetails = customerDetails {
                    _ = CustomerDetails(context: context, customerDetailsEntryFromServer: existingCustomerDetails, conversationWithCustomer: conversation)
                }
                return conversation
            }
            do {
                if context.hasChanges { try context.save() }
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
            context.reset()
        }
        */
    }
}



/// Updates the existing Agent's Conversation with Customer entry to Archive/Unarchive in the Core Data store.
class UpdateConversationInStore_ArchivingOperation: Operation {
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
    private let selectedCustomer:Customer
    private let shouldArchive:Bool
    
    init(context: NSManagedObjectContext, selectedCustomer:Customer, shouldArchive:Bool) {
        self.context = context
        self.selectedCustomer = selectedCustomer
        self.shouldArchive = shouldArchive
    }
    
    override func main() {
        context.performAndWait {
            do {
                selectedCustomer.isArchived = shouldArchive
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Updates the existing Agent's Conversation with Customer entry to Archive/Unarchive on the server.
class UpdateConversationOnServer_ArchivingOperation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    private var downloading = false
    
    let customer:Customer
    let shouldArchive:Bool
    
    private let params:[String:String]
    
    init(selectedCustomer:Customer, shouldArchive:Bool) {
        self.customer = selectedCustomer
        self.shouldArchive = shouldArchive
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID,
            "external_conversation_id":String(selectedCustomer.externalConversationID)
        ]
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
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        shouldArchive ?
            APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .ArchiveConversation, httpMethod: .POST, params: params, completion: finish) :
            APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .UnarchiveConversation, httpMethod: .POST, params: params, completion: finish)
    }
}






/* ----------------------------------------------------------------------------------------------------------------------- */


/// Updates the existing Agent's Conversation with Customer entry to Pin/Unpin in the Core Data store.
class UpdateConversationInStore_PinningOperation: Operation {
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
    private let selectedCustomer:Customer
    private let shouldPin:Bool
    
    init(context: NSManagedObjectContext, selectedCustomer:Customer, shouldPin:Bool) {
        self.context = context
        self.selectedCustomer = selectedCustomer
        self.shouldPin = shouldPin
    }
    
    override func main() {
        context.performAndWait {
            do {
                selectedCustomer.isPinned = shouldPin
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}








/// Start new conversation with a customer's number.
class StartNewConversation_Operation: Operation {
    var result: Result<NewConversationProperties, APIService.APIError>?
    
    private var downloading = false
    
    private let params:[String:String]
    
    init(agentSenderID:String, phoneNumber:String) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID,
            "phone_number":phoneNumber,
            "sender_id":agentSenderID
        ]
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
        
    }
    
    func finish(result: Result<NewConversationJSON, APIService.APIError>) {
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
        guard serverResult == .success, let conversation = resultData.conversation else {
            self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
            didChangeValue(forKey: #keyPath(isFinished))
            didChangeValue(forKey: #keyPath(isExecuting))
            return
        }
        self.result = .success(conversation)
        
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
        APIServer<NewConversationJSON>(apiVersion: .v2).hitEndpoint(endpoint: .StartNewConversation, httpMethod: .POST, params: params, completion: finish)
    }
}








/// Mark customer as Deleted in the customer list  in the Core Data store.
class MarkDeleteCustomerInStore_Operation: Operation {
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
    private let customer:Customer
    private let markDeleted:Bool
    init(context: NSManagedObjectContext, customer:Customer, markDeleted:Bool) {
        self.context = context
        self.customer = customer
        self.markDeleted = markDeleted
    }
    
    override func main() {
        context.performAndWait {
            do {
                customer.isCustomerDeleted = markDeleted
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Delete the customer from customer list on the server.
class DeleteCustomerOnServer_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    private var downloading = false
    
    
    let customer:Customer
    
    private let params:[String:String]

    init(customer:Customer) {
        self.customer = customer
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID
        ]
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
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .DeleteConversation(conversationID: Int(customer.externalConversationID)), httpMethod: .DELETE, params: params, completion: finish)
    }
}





/// [POST] Click to call operation on the server.
class Click2Call_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    private var downloading = false
    
    private let params:[String:String]

    init(fromPhoneNumber: String, toPhoneNumber: String, conversationID: String, isAgent: String) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id": companyID,
            "from": fromPhoneNumber,
            "to": toPhoneNumber,
            "idExternal": conversationID,
            "calltoagent": isAgent
        ]
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
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        let configuration: APIService.Configuration = .init(timeOutInterval: 90, apiCommonPath: "\(Config.APIConfig.urlPrefix)/\(APIService.APIVersion.v2)")
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .Click2Call, httpMethod: .POST, params: params, endpointConfiguration: configuration, completion: finish)
    }
}
