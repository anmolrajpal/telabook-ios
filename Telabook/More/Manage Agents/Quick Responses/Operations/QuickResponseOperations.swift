//
//  QuickResponseOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import os

struct QuickResponseOperations {
    //MARK: Get: Fetch and Sync Agent's Quick Responses
    /// Returns an array of operations for synchronizing Agent's Quick Responses.
    static func getOperationsToFetchAndSaveQuickResponses(using context: NSManagedObjectContext, userID:Int, forAgent agent:Agent) -> [Operation] {
        let fetchFromStore_Operation = FetchSavedQuickResponsesEntries_Operation(context: context)
        let downloadFromServer_Operation = DownloadQuickResponsesEntriesFromServer_Operation(userID: userID)
        let deleteRedundantEntriesFromStore_Operation = DeleteRedundantQuickResponsesEntries_Operation(context: context, agent: agent)
        let addToStore_Operation = AddQuickResponseEntryFromServerToStore_Operation(context: context, agent: agent)

        let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned deleteRedundantEntriesFromStore_Operation] in
            guard case let .success(entries) = fetchFromStore_Operation.result else {
                #if !RELEASE
                print("Unresolved Error: Unable to get result(QuickResponses) from fetchFromStore_Operation")
                #endif
                deleteRedundantEntriesFromStore_Operation.cancel()
                return
            }
            deleteRedundantEntriesFromStore_Operation.fetchedEntries = entries
        }
        passFetchResultsToStore_Operation.addDependency(fetchFromStore_Operation)
        deleteRedundantEntriesFromStore_Operation.addDependency(passFetchResultsToStore_Operation)
        
        let passServerResultsToStore_Operation = BlockOperation { [unowned downloadFromServer_Operation, unowned deleteRedundantEntriesFromStore_Operation, unowned addToStore_Operation] in
            guard case let .success(entries)? = downloadFromServer_Operation.result else {
                #if !RELEASE
                print("Unresolved Error: unable to get result from download from server operation")
                #endif
                deleteRedundantEntriesFromStore_Operation.cancel()
                addToStore_Operation.cancel()
                return
            }
            deleteRedundantEntriesFromStore_Operation.serverEntries = entries
            addToStore_Operation.serverEntries = entries
        }
        
        passServerResultsToStore_Operation.addDependency(downloadFromServer_Operation)
        deleteRedundantEntriesFromStore_Operation.addDependency(passServerResultsToStore_Operation)
        addToStore_Operation.addDependency(passServerResultsToStore_Operation)
        
        return [
            fetchFromStore_Operation,
            passFetchResultsToStore_Operation,
            downloadFromServer_Operation,
            deleteRedundantEntriesFromStore_Operation,
            passServerResultsToStore_Operation,
            addToStore_Operation
        ]
    }
    
    
    
    
    //MARK: PUT - Sync and Update Agent's Quick Response on Server
    /// Returns an array of operations for updating  Agent's Quick Response from Core Data store to server.
    static func getOperationsToSyncExistingQuickResponse(using context: NSManagedObjectContext, userID:Int, selectedResponse:QuickResponse, quickResposneToUpdate answer:String) -> [Operation] {
        
        let saveEntryToStore_Operation = UpdateExistingQuickResponseEntryInStore_Operation(context: context, selectedResponse: selectedResponse, answer: answer)
        let updateEntryOnServer_Operation = UpdateExistingQuickResponseEntryOnServer_Operation(responseID: Int(selectedResponse.id), userID: userID, answer: answer)
        
        return [
            saveEntryToStore_Operation,
            updateEntryOnServer_Operation
        ]
    }
    
    
    
    
    
    //MARK: DEL - DELETE & Sync Agent's Quick Response on Server and store
    /// Returns an array of operations for deleting Agent's Quick Response from Core Data store and server.
    static func getOperationsToDeleteExistingQuickResponse(using context: NSManagedObjectContext, selectedResponse:QuickResponse, forAgent agent:Agent) -> [Operation] {
        
        let markToDeleteFromStore_Operation = MarkToDeleteExistingQuickResponseEntryInStore_Operation(context: context, selectedResponse: selectedResponse)
        let deleteFromServer_Operation = DeleteExistingQuickResponseEntryOnServer_Operation(responseID: Int(selectedResponse.id))
        let deleteFromStoreOperation = DeleteExistingQuickResponseEntryFromStore_Operation(context: context, selectedResponse: selectedResponse, agent: agent)
        
        let guardServerResponse_Operation = BlockOperation { [unowned deleteFromServer_Operation, unowned deleteFromStoreOperation] in
            guard case .success = deleteFromServer_Operation.result else {
                print("Unable to delete response on server")
                deleteFromStoreOperation.cancel()
                return
            }
        }
        guardServerResponse_Operation.addDependency(deleteFromServer_Operation)
        deleteFromStoreOperation.addDependency(guardServerResponse_Operation)
        
        return [
            markToDeleteFromStore_Operation,
            deleteFromServer_Operation,
            guardServerResponse_Operation,
            deleteFromStoreOperation
        ]
    }
}





/// Fetches the  Agent's Quck Response entry from the Core Data store.
class FetchSavedQuickResponsesEntries_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    private let context: NSManagedObjectContext
    
    var result: Result<[QuickResponse], OperationError>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        let request: NSFetchRequest<QuickResponse> = QuickResponse.fetchRequest()
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



/// Downloads Agent's Quick Responses entries from the server.
class DownloadQuickResponsesEntriesFromServer_Operation: Operation {
    var result: Result<[QuickResponseCodable], APIService.APIError>?
    
    private var downloading = false
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
    ]
    init(userID:Int) {
        params = [
            "company_id":String(AppData.companyId),
            "user_id":String(userID)
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
    
    func finish(result: Result<[QuickResponseCodable], APIService.APIError>) {
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
        APIOperations.triggerAPIEndpointOperations(endpoint: .FetchQuickResponses, httpMethod: .GET, params: params, headers: headers, completion: finish)
    }
}


/// Deletes the redundant Agent's Quick Response entries from core data store.
class DeleteRedundantQuickResponsesEntries_Operation: Operation {
    
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
    var fetchedEntries:[QuickResponse]?
    var serverEntries:[QuickResponseCodable]?
    
    
    init(context: NSManagedObjectContext, agent:Agent) {
        self.context = context
        self.agent = agent
    }
    convenience init(context: NSManagedObjectContext, fetchedEntries: [QuickResponse]?, serverEntries:[QuickResponseCodable]?, agent:Agent) {
        self.init(context: context, agent:agent)
        self.fetchedEntries = fetchedEntries
        self.serverEntries = serverEntries
    }
    
    override func main() {
        let fetchRequest: NSFetchRequest<QuickResponse> = QuickResponse.fetchRequest()
        
        guard fetchedEntries != nil, !fetchedEntries!.isEmpty else {
            print("No Fetched Entries or nil")
            return
        }
        
        if let serverEntries = serverEntries,
            !serverEntries.isEmpty {
            let serverIDs = serverEntries.map { $0.id }.compactMap { $0 }
            fetchRequest.predicate = NSPredicate(format: "NOT (\(#keyPath(QuickResponse.id)) IN %@)", serverIDs)
        } else {
            print("No Server Entries, deleting all entries")
        }
        
        context.performAndWait {
            do {
                let entriesToDelete = try context.fetch(fetchRequest)
                _ = entriesToDelete.map { agent.removeFromQuickResponses($0) }
//                _ = entriesToDelete.map { context.delete($0) }
                try context.save()
            } catch {
                print("Error deleting entries: \(error)")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Add Agent's Quick Response  entries returned from the server to the Core Data store.
class AddQuickResponseEntryFromServerToStore_Operation: Operation {
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
    private let agent:Agent
    var serverEntries:[QuickResponseCodable]?
    
    init(context: NSManagedObjectContext, agent:Agent) {
        self.context = context
        self.agent = agent
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
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
                _ = serverEntries.map { QuickResponse(context: context, quickResponseEntryFromServer: $0, agent: agent, synced: true) }
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
        
    }
}










/// Creates new Agent's Quick Response entry on the server.
class CreateNewQuickResponseEntryOnServer_Operation: Operation {
    var result: Result<APIService.EmptyData, APIService.APIError>?
    
    struct Body:Codable {
        let user_id:Int
        let company_id:String
        let answer:String
    }
    private let encoder = JSONEncoder()
    private var downloading = false
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json")
    ]
    private let httpBody:Data
    init(userID:Int, answer:String) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":String(AppData.companyId),
        ]
        let body = Body(user_id: userID, company_id: companyID, answer: answer)
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
        
    }
    
    func finish(result: Result<APIService.EmptyData, APIService.APIError>) {
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
        APIOperations.triggerAPIEndpointOperations(endpoint: .CreateQuickResponse, httpMethod: .POST, params: params, httpBody: httpBody, headers: headers, guardResponse: .Created, expectData: false, completion: finish)
    }
}







/// Updates the existing Quick Response entry from user input to the Core Data store.
class UpdateExistingQuickResponseEntryInStore_Operation: Operation {
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
    private let selectedQuickResponse:QuickResponse
    private let answer:String
    
    init(context: NSManagedObjectContext, selectedResponse:QuickResponse, answer:String) {
        self.context = context
        self.selectedQuickResponse = selectedResponse
        self.answer = answer
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        context.performAndWait {
            do {
                selectedQuickResponse.answer = answer
                selectedQuickResponse.synced = false
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Updates Existing Agent's Quick Response entry on the server.
class UpdateExistingQuickResponseEntryOnServer_Operation: Operation {
    var result: Result<APIService.EmptyData, APIService.APIError>?
    
    struct Body:Codable {
        let user_id:Int
        let company_id:String
        let answer:String
    }
    private let encoder = JSONEncoder()
    private var downloading = false
    
    private let responseID:Int
    
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json"),
        HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
    ]
    private let httpBody:Data
    init(responseID:Int, userID:Int, answer:String) {
        self.responseID = responseID
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID,
        ]
        let body = Body(user_id: userID, company_id: companyID, answer: answer)
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
        
    }
    
    func finish(result: Result<APIService.EmptyData, APIService.APIError>) {
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
        APIOperations.triggerAPIEndpointOperations(endpoint: .UpdateQuickResponse(responseID: responseID), httpMethod: .PUT, params: params, httpBody: httpBody, headers: headers, guardResponse: .Created, expectData: false, completion: finish)
    }
}










//MARK: DEL: Deletes and sync Quick Response
/// Updates the existing Quick Response entry, changing it's markForDeletion value to TRUE  in the Core Data store.
class MarkToDeleteExistingQuickResponseEntryInStore_Operation: Operation {
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
    private let selectedQuickResponse:QuickResponse
    
    init(context: NSManagedObjectContext, selectedResponse:QuickResponse) {
        self.context = context
        self.selectedQuickResponse = selectedResponse
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        context.performAndWait {
            do {
                selectedQuickResponse.markForDeletion = true
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}



/// Deletes Existing Agent's Quick Response entry on the server.
class DeleteExistingQuickResponseEntryOnServer_Operation: Operation {
    var result: Result<APIService.EmptyData, APIService.APIError>?
    
    private var downloading = false
    
    private let responseID:Int
    
    private let params:[String:String]

    init(responseID:Int) {
        self.responseID = responseID
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
        
    }
    
    func finish(result: Result<APIService.EmptyData, APIService.APIError>) {
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
        APIOperations.triggerAPIEndpointOperations(endpoint: .DeleteQuickResponse(responseID: responseID), httpMethod: .DELETE, params: params, guardResponse: .Created, expectData: false, completion: finish)
    }
}


/// Deletes existing Quick Response entry from the Core Data store.
class DeleteExistingQuickResponseEntryFromStore_Operation: Operation {
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
    private let selectedQuickResponse:QuickResponse
    private let agent:Agent
    init(context: NSManagedObjectContext, selectedResponse:QuickResponse, agent:Agent) {
        self.context = context
        self.selectedQuickResponse = selectedResponse
        self.agent = agent
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
//        let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: allEntriesRequest)
//        deleteAllRequest.resultType = .resultTypeObjectIDs
//        let result = try context.execute(deleteAllRequest) as? NSBatchDeleteResult
//        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: result?.result as Any],
//                                            into: [self.viewContext])
        context.performAndWait {
            do {
//                context.delete(selectedQuickResponse)
                agent.removeFromQuickResponses(selectedQuickResponse)
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}
