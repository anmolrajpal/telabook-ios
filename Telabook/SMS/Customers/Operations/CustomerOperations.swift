//
//  CustomerOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData
import os

struct CustomerOperations {
    func huh() {
        APIServer<APIService.EmptyData>(apiVersion: .v1).hitEndpoint(endpoint: .AutoResponse, httpMethod: .DELETE) { (result: Result<APIService.EmptyData, APIService.APIError>) in

        }
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
        APIServer<CustomerCodable>(apiVersion: .v2).hitEndpoint(endpoint: .FetchCustomers, httpMethod: .POST, params: params, completion: finish)
    }
}


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
