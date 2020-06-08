//
//  AgentOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

struct AgentOperations {
    /// Returns an array of operations for fetching the latest entries and then adding them to the Core Data store.
    static func getOperationsToFetchLatestEntries(using context: NSManagedObjectContext) -> [Operation] {
        let fetchMostRecentEntry = FetchMostRecentAgentsEntryOperation(context: context)
        let downloadFromServer = DownloadAgentsEntriesFromServerOperation()
        let deleteRedundantAgentEntriesOperation = DeleteRedundantAgentEntriesOperation(context: context)
        let updateAgentEntriesOperation = UpdateAgentEntriesOperation(context: context)
        let addToStore = AddAgentEntriesToStoreOperation(context: context)
        
        let passFetchedEntriesToStore = BlockOperation { [unowned fetchMostRecentEntry, unowned deleteRedundantAgentEntriesOperation, unowned addToStore] in
            guard case let .success(entries)? = fetchMostRecentEntry.result else {
                print("Unresolved Error: Unable to get result from fetchMostRecentEntriesOperation")
                deleteRedundantAgentEntriesOperation.cancel()
                addToStore.cancel()
                return
            }
            deleteRedundantAgentEntriesOperation.fetchedEntries = entries
            addToStore.fetchedEntries = entries
        }
        passFetchedEntriesToStore.addDependency(fetchMostRecentEntry)
        deleteRedundantAgentEntriesOperation.addDependency(passFetchedEntriesToStore)
        addToStore.addDependency(passFetchedEntriesToStore)
        
        let passServerResultsToStore = BlockOperation { [unowned downloadFromServer, unowned deleteRedundantAgentEntriesOperation, unowned updateAgentEntriesOperation, unowned addToStore] in
            guard case let .success(entries)? = downloadFromServer.result else {
                print("Unresolved Error: unable to get result from download from server operation")
                deleteRedundantAgentEntriesOperation.cancel()
                updateAgentEntriesOperation.cancel()
                addToStore.cancel()
                return
            }
            deleteRedundantAgentEntriesOperation.serverEntries = entries
            updateAgentEntriesOperation.serverEntries = entries
            addToStore.serverEntries = entries
        }
        
        passServerResultsToStore.addDependency(downloadFromServer)
        deleteRedundantAgentEntriesOperation.addDependency(passServerResultsToStore)
        updateAgentEntriesOperation.addDependency(passServerResultsToStore)
        addToStore.addDependency(passServerResultsToStore)
        
        return [fetchMostRecentEntry,
                passFetchedEntriesToStore,
                downloadFromServer,
                passServerResultsToStore,
                deleteRedundantAgentEntriesOperation,
                updateAgentEntriesOperation,
                addToStore]
    }
}



/// Fetches the most recent Agents entry from the Core Data store.
class FetchMostRecentAgentsEntryOperation: Operation {
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
    
    var result: Result<[Agent], OperationError>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        let request: NSFetchRequest<Agent> = Agent.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.date), ascending: false)]
        
        context.performAndWait {
            do {
                let fetchResults = try context.fetch(request)
                self.result = .success(fetchResults)
            } catch {
                print("Error fetching from context: \(error)")
                self.error = .coreDataError(error: error)
                self.result = .failure(.coreDataError(error: error))
            }
        }
    }
}


/// Downloads Agents entries from the server.
class DownloadAgentsEntriesFromServerOperation: Operation {
    var result: Result<[AgentCodable], APIService.APIError>?
    
    private var downloading = false
    
    private let params:[String:String] = [
        "company_id":String(AppData.companyId)
    ]
    
    
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
    
    func finish(result: Result<[AgentCodable], APIService.APIError>) {
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
        APIOperations.triggerAPIEndpointOperations(endpoint: .FetchAgents, httpMethod: .GET, params: params, completion: finish)
    }
}

/// Deletes the redundant agent entries from core data store.
class DeleteRedundantAgentEntriesOperation: Operation {
    
    private let context: NSManagedObjectContext
    
    var delay: TimeInterval = 0.0005
    
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    var error: OperationError?
    
    
    var fetchedEntries:[Agent]?
    var serverEntries:[AgentCodable]?
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    convenience init(context: NSManagedObjectContext, fetchedEntries: [Agent]?, serverEntries:[AgentCodable]?) {
        self.init(context: context)
        self.fetchedEntries = fetchedEntries
        self.serverEntries = serverEntries
    }
    
    override func main() {
        let fetchRequest: NSFetchRequest<Agent> = Agent.fetchRequest()
        
        guard fetchedEntries != nil, !fetchedEntries!.isEmpty else {
            print("No Fetched Entries or nil")
            return
        }
        
        if let serverEntries = serverEntries,
            !serverEntries.isEmpty {
            let serverAgentIDs = serverEntries.map { $0.userId }.compactMap { $0 }
            fetchRequest.predicate = NSPredicate(format: "NOT (\(#keyPath(Agent.userID)) IN %@)", serverAgentIDs)
        } else {
            print("No Server Entries, deleting all entries")
        }
        
        context.performAndWait {
            do {
                let entriesToDelete = try context.fetch(fetchRequest)
                _ = entriesToDelete.map { context.delete($0) }
                try context.save()
            } catch {
                print("Error deleting entries: \(error)")
                self.error = .coreDataError(error: error)
            }
        }
    }
}


/// Update Agents entries returned from the server to the Core Data store.
class UpdateAgentEntriesOperation: Operation {
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
    
    var serverEntries:[AgentCodable]?
    
    init(context: NSManagedObjectContext) {
        self.context = context
//        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    
    override func main() {
        let fetchRequest: NSFetchRequest<Agent> = Agent.fetchRequest()
        
        guard let serverEntries = serverEntries,
            !serverEntries.isEmpty else {
                print("No Server Entries to update, should return")
                return
        }
        
        let serverAgentIDs = serverEntries.map { $0.userId }.compactMap { $0 }
        
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Agent.userID)) IN %@", serverAgentIDs)
        
        context.performAndWait {
            do {
                let entriesToUpdate = try context.fetch(fetchRequest)
                guard !entriesToUpdate.isEmpty else  { return }
                for entry in entriesToUpdate {
                    if let serverEntry = serverEntries.first(where: { Int(entry.userID) == $0.userId }) {
                        _ = Agent(context: context, agentEntryFromServer: serverEntry)
                    }
                }
                try context.save()
            } catch {
                print("Error deleting entries: \(error)")
                self.error = .coreDataError(error: error)
            }
        }
    }
}




/// Add Agents entries returned from the server to the Core Data store.
class AddAgentEntriesToStoreOperation: Operation {
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
    
    var fetchedEntries:[Agent]?
    var serverEntries:[AgentCodable]?
    
    var delay: TimeInterval = 0
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(context: NSManagedObjectContext, serverEntries: [AgentCodable], delay: TimeInterval? = nil) {
        self.init(context: context)
        self.serverEntries = serverEntries
        if let delay = delay {
            self.delay = delay
        }
    }
    
    override func main() {
        //        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        guard let serverEntries = serverEntries, !serverEntries.isEmpty else {
            print("No Server Entry to add, returning")
            return
        }
        
        if let fetchedEntries = fetchedEntries,
            !fetchedEntries.isEmpty {
            
            let newServerEntries = serverEntries.filter { (agent) -> Bool in
                !fetchedEntries.contains(where: { Int($0.userID) == agent.userId })
            }
            context.performAndWait {
                do {
                    for entry in newServerEntries {
                        _ = Agent(context: context, agentEntryFromServer: entry)
                        
                        print("Adding Agent entry with name: \(entry.personName ?? "nil")")
                        
                        // Simulate a slow process by sleeping
                        if delay > 0 {
                            Thread.sleep(forTimeInterval: delay)
                        }
                        try context.save()
                        if isCancelled {
                            break
                        }
                    }
                } catch {
                    print("Error adding entries to store: \(error))")
                    self.error = .coreDataError(error: error)
                }
            }
        } else {
            context.performAndWait {
                do {
                    for entry in serverEntries {
                        _ = Agent(context: context, agentEntryFromServer: entry)
                        
                        print("Adding Agent entry with name: \(entry.personName ?? "nil")")
                        
                        // Simulate a slow process by sleeping
                        if delay > 0 {
                            Thread.sleep(forTimeInterval: delay)
                        }
                        try context.save()
                        if isCancelled {
                            break
                        }
                    }
                } catch {
                    print("Error adding entries to store: \(error))")
                    self.error = .coreDataError(error: error)
                }
            }
        }
    }
}

// Delete Agent entries that match the predicate parameter from the Core Data store.
class DeleteAgentEntriesOperation: Operation {
    private let context: NSManagedObjectContext
    var predicate: NSPredicate?
    var delay: TimeInterval = 0.0005
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(context: NSManagedObjectContext, predicate: NSPredicate?, delay: TimeInterval? = nil) {
        self.init(context: context)
        self.predicate = predicate
        if let delay = delay {
            self.delay = delay
        }
    }
    
    override func main() {
        let fetchRequest: NSFetchRequest<Agent> = Agent.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.date), ascending: true)]
        
        context.performAndWait {
            do {
                let entriesToDelete = try context.fetch(fetchRequest)
                for entry in entriesToDelete {
                    print("Deleting entry with timestamp: \(entry.date?.description ?? "(nil)")")
                    
                    context.delete(entry)
                    
                    // Simulate a slow process by sleeping.
                    if delay > 0 {
                        Thread.sleep(forTimeInterval: delay)
                    }
                    
                    if isCancelled {
                        break
                    }
                }
                try context.save()
            } catch {
                print("Error deleting entries: \(error)")
            }
        }
    }
}









/// Updatess the unread messages count property in the core data store.
class UpdatePendingMessagesCount_Operation: Operation {
    
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
    let pendingMessages:[PendingMessage]
    init(context: NSManagedObjectContext, pendingMessages:[PendingMessage]) {
        self.context = context
        self.pendingMessages = pendingMessages
    }
    
    override func main() {
        context.performAndWait {
            do {
                for object in pendingMessages {
                    object.agent.externalPendingMessagesCount = Int16(object.count)
                    try context.save()
                }
            } catch {
                let message = "Error updating pending messages count: \(error.localizedDescription)"
                printAndLog(message: message, log: .coredata, logType: .error)
                self.error = .coreDataError(error: error)
            }
        }
        context.reset()
    }
}
