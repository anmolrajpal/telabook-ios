//
//  QuickResponseOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData
import os

struct QuickResponseOperations {
    /// Returns an array of operations for synchronizing Agent's Quick Responses.
    static func getOperationsToFetchAndSaveQuickResponses(using context: NSManagedObjectContext, userID:Int, forAgent agent:Agent) -> [Operation] {
        let fetchFromStore_Operation = FetchSavedQuickResponsesEntries_Operation(context: context)
        let downloadFromServer_Operation = DownloadQuickResponsesEntriesFromServer_Operation(userID: userID)
        let deleteRedundantEntriesFromStore_Operation = DeleteRedundantQuickResponsesEntries_Operation(context: context, agent: agent)
        let addToStore_Operation = AddQuickResponseEntryFromServerToStore_Operation(context: context, agent: agent)

        let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned deleteRedundantEntriesFromStore_Operation] in
            guard case let .success(entries) = fetchFromStore_Operation.result else {
                #if DEBUG
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
                #if DEBUG
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
}





/// Fetches the  Agent's Auto Response entry from the Core Data store.
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
                #if DEBUG
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
            #if DEBUG
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
