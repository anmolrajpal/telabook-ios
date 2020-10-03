//
//  BlacklistOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import os


struct BlacklistOperations {
    
    static func getOperationsToFetchBlacklist(using context: NSManagedObjectContext, page:Int) -> [Operation] {
        let fetchFromStore_Operation = FetchSavedBlacklistEntries_Operation(context: context)
        let fetchFromServer_Operation = FetchBlacklistFromServer_Operation(page: page)
        let deleteFromStore_Operation = DeleteRedundantBlacklistEntries_Operation(context: context)
        let addToStore_Operation = AddBlacklistEntriesFromServerToStore_Operation(context: context)
        
        
        let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned deleteFromStore_Operation] in
            guard case let .success(entries) = fetchFromStore_Operation.result else {
                #if !RELEASE
                print("Unresolved Error: Unable to get result(Blocked User) from fetchFromStore_Operation")
                #endif
                deleteFromStore_Operation.cancel()
                return
            }
            deleteFromStore_Operation.fetchedEntries = entries
        }
        
        passFetchResultsToStore_Operation.addDependency(fetchFromStore_Operation)
        deleteFromStore_Operation.addDependency(passFetchResultsToStore_Operation)
        
        
        let passServerResultsToStore_Operation = BlockOperation { [unowned fetchFromServer_Operation, unowned deleteFromStore_Operation, unowned addToStore_Operation] in
            guard case let .success(entries) = fetchFromServer_Operation.result else {
                #if !RELEASE
                print("Unresolved Error: Unable to get result(Blacklist) from fetchFromServer_Operation")
                #endif
                deleteFromStore_Operation.cancel()
                return
            }
            deleteFromStore_Operation.serverEntries = entries
            addToStore_Operation.serverEntries = entries
        }
        
        
        passServerResultsToStore_Operation.addDependency(fetchFromServer_Operation)
        deleteFromStore_Operation.addDependency(passServerResultsToStore_Operation)
        addToStore_Operation.addDependency(passServerResultsToStore_Operation)
        
        
        
        return [
            fetchFromStore_Operation,
            passFetchResultsToStore_Operation,
            fetchFromServer_Operation,
            passServerResultsToStore_Operation,
            deleteFromStore_Operation,
            addToStore_Operation
        ]
    }
    
    
    
    
    static func getOperationsToUnblockCustomer(using context: NSManagedObjectContext, blockedUser:BlockedUser, markUnblock:Bool = true) -> [Operation] {
        let unblockFromStore_Operation = MarkUnblockCustomerInStore_Operation(context: context, blockedUser: blockedUser, markUnblock: markUnblock)
        let unblockOnServer_Operation = UnblockCustomerOnServer_Operation(blockedUser: blockedUser)
        let deleteFromStore_Operation = DeleteBlockedUserEntryFromStore_Operation(context: context, blockedUser: blockedUser)
        
        let guardServerResponse_Operation = BlockOperation { [unowned unblockOnServer_Operation, unowned deleteFromStore_Operation] in
            guard case .success = unblockOnServer_Operation.result else {
                print("Unable to delete response on server")
                deleteFromStore_Operation.cancel()
                return
            }
        }
        guardServerResponse_Operation.addDependency(unblockOnServer_Operation)
        deleteFromStore_Operation.addDependency(guardServerResponse_Operation)
        
        return [
            unblockFromStore_Operation,
            unblockOnServer_Operation,
            guardServerResponse_Operation,
            deleteFromStore_Operation
        ]
    }
    
    
    
    
    static func getOperationsToBlockConversation(using context:NSManagedObjectContext, for customer:Customer, withReasonToBlock reason:String, markBlock:Bool = true) -> [Operation] {
        let blockInStore_Operation = MarkBlockCustomerInStore_Operation(context: context, customer: customer, markBlock: markBlock)
        let blockOnServer_Operation = BlockCustomerOnServer_Operation(customer: customer, blockingReason: reason)
        
        return [blockInStore_Operation, blockOnServer_Operation]
    }
    
}


/// Fetches saved Blocked Users Entries from the Core Data store.
class FetchSavedBlacklistEntries_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    private let context: NSManagedObjectContext

    var result: Result<[BlockedUser], OperationError>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        let request: NSFetchRequest<BlockedUser> = BlockedUser.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(BlockedUser.updatedAt), ascending: false)]
        
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








/// Fetches Blacklist from Server
class FetchBlacklistFromServer_Operation: Operation {
    var result: Result<[BlacklistJSON.ResultData.BlacklistMetaProperties.BlacklistProperties]?, APIService.APIError>?
    
    private var downloading = false
    
    private let params:[String:String]
    
    init(page:Int) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID,
            "page":String(page)
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
    
    func finish(result: Result<BlacklistJSON, APIService.APIError>) {
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
        guard serverResult == .success,
            let data = resultData.resultData,
            let blacklistProperties = data.blacklistMetaProperties else {
                self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
                didChangeValue(forKey: #keyPath(isFinished))
                didChangeValue(forKey: #keyPath(isExecuting))
                return
        }
        self.result = .success(blacklistProperties.blacklistProperties)
        
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
        APIServer<BlacklistJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchBlacklist, httpMethod: .GET, params: params, completion: finish)
    }
}



/// Deletes the redundant Blocked Users entries from core data store.
class DeleteRedundantBlacklistEntries_Operation: Operation {
    
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
    
    var serverEntries:[BlacklistJSON.ResultData.BlacklistMetaProperties.BlacklistProperties]?
    
    var fetchedEntries:[BlockedUser]?
    
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BlockedUser.fetchRequest()
        
        guard fetchedEntries != nil, !fetchedEntries!.isEmpty else {
            print("No Fetched Entries or nil")
            return
        }
        
        if let serverEntries = serverEntries,
            !serverEntries.isEmpty {
            let serverIDs = serverEntries.map { $0.id }.compactMap { $0 }
            
            let filterPredicate = NSPredicate(format: "NOT id IN %@", serverIDs)
            fetchRequest.predicate = filterPredicate
        } else {
            print("No Server Entries, deleting all entries")
        }
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        context.performAndWait {
            do {
                let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [PersistentContainer.shared.viewContext])
                }
                
                /*
                let entriesToDelete = try context.fetch(fetchRequest)
                _ = entriesToDelete.map { agent.removeFromCustomers($0) }
                _ = entriesToDelete.map { context.delete($0) }
                try context.save()
                */
            } catch {
                print("Error deleting entries: \(error)")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Add Blacklist entries returned from the server to the Core Data store.
class AddBlacklistEntriesFromServerToStore_Operation: Operation {
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
    
    var serverEntries:[BlacklistJSON.ResultData.BlacklistMetaProperties.BlacklistProperties]?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        guard let serverEntries = serverEntries else {
            #if !RELEASE
            print("No Server Entry to add, returning")
            #endif
            return
        }
        context.performAndWait {
            do {
                _ = serverEntries.map { BlockedUser(context: context, blockedUserEntryFromServer: $0) }
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
        
    }
}













/// Unblocks the customer from blacklist in the Core Data store.
class MarkUnblockCustomerInStore_Operation: Operation {
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
    private let blockedUser:BlockedUser
    private let markUnblock:Bool
    init(context: NSManagedObjectContext, blockedUser:BlockedUser, markUnblock:Bool) {
        self.context = context
        self.blockedUser = blockedUser
        self.markUnblock = markUnblock
    }
    
    override func main() {
        context.performAndWait {
            do {
                blockedUser.isUnblocking = markUnblock
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Unblock the customer from (blacklist) on the server.
class UnblockCustomerOnServer_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    struct Body:Codable {
        let external_conversation_id:Int
        let company_id:String
        let number:String
        let description:String
    }
    private let encoder = JSONEncoder()
    private var downloading = false
    
    let blockedUser:BlockedUser
    
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json")
    ]
    private let httpBody:Data
    init(blockedUser:BlockedUser) {
        self.blockedUser = blockedUser
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID,
            "external_conversation_id":String(blockedUser.conversationID),
            "id":String(blockedUser.id)
        ]
        let body = Body(external_conversation_id: Int(blockedUser.conversationID), company_id: companyID, number: blockedUser.phoneNumber ?? "", description: "")
        httpBody = try! encoder.encode(body)
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
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .UnblockConversation, httpMethod: .POST, params: params, httpBody: httpBody, headers: headers, completion: finish)
    }
}



/// Deletes existing Blocked User entry from the Core Data store.
class DeleteBlockedUserEntryFromStore_Operation: Operation {
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
    private let blockedUser:BlockedUser
    
    init(context: NSManagedObjectContext, blockedUser:BlockedUser) {
        self.context = context
        self.blockedUser = blockedUser
    }
    
    override func main() {
        context.performAndWait {
            do {
                let objectID = blockedUser.objectID
                let objectContext = context.object(with: objectID) as! BlockedUser
                context.delete(objectContext)
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}














/// Mark customer as Blocked in the customer list  in the Core Data store.
class MarkBlockCustomerInStore_Operation: Operation {
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
    private let markBlock:Bool
    init(context: NSManagedObjectContext, customer:Customer, markBlock:Bool) {
        self.context = context
        self.customer = customer
        self.markBlock = markBlock
    }
    
    override func main() {
        context.performAndWait {
            do {
                customer.isBlacklisted = markBlock
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Block the customer from customer list on the server.
class BlockCustomerOnServer_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    struct Body:Codable {
        let external_conversation_id:Int
        let company_id:String
        let number:String
        let description:String
    }
    private let encoder = JSONEncoder()
    private var downloading = false
    
    let customer:Customer
    
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json")
    ]
    private let httpBody:Data

    init(customer:Customer, blockingReason:String) {
        self.customer = customer
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID
        ]
        let body = Body(external_conversation_id: Int(customer.externalConversationID), company_id: companyID, number: customer.phoneNumber ?? "", description: blockingReason)
        httpBody = try! encoder.encode(body)
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
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .BlockConversation, httpMethod: .POST, params: params, httpBody: httpBody, headers: headers, completion: finish)
    }
}
