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
    static func getOperationsToFetchAgents(using context: NSManagedObjectContext, showOnlyDisabledAccounts: Bool) -> [Operation] {
        let fetchExistingAgentsFromStoreOperation = FetchMostRecentAgentsEntryOperation(context: context, shouldFetchDisabledAccounts: showOnlyDisabledAccounts)
        let downloadFromServerOperation = DownloadAgentsEntriesFromServerOperation(showOnlyDisabledAccounts: showOnlyDisabledAccounts)
        let deleteRedundantAgentEntriesOperation = DeleteRedundantAgentEntriesOperation(context: context, shouldFetchDisabledAccounts: showOnlyDisabledAccounts)
        let upsertInStoreOperation = UpsertAgentEntriesInStoreOperation(context: context, showOnlyDisabledAccounts: showOnlyDisabledAccounts)
        
        let passFetchedEntriesToStoreBlockOperation = BlockOperation { [unowned fetchExistingAgentsFromStoreOperation, unowned deleteRedundantAgentEntriesOperation, unowned upsertInStoreOperation] in
            guard case let .success(entries)? = fetchExistingAgentsFromStoreOperation.result else {
                print("Unresolved Error: Unable to get result from fetchMostRecentEntriesOperation")
                deleteRedundantAgentEntriesOperation.cancel()
                upsertInStoreOperation.cancel()
                return
            }
            deleteRedundantAgentEntriesOperation.fetchedEntries = entries
            upsertInStoreOperation.fetchedEntries = entries
        }
        passFetchedEntriesToStoreBlockOperation.addDependency(fetchExistingAgentsFromStoreOperation)
        deleteRedundantAgentEntriesOperation.addDependency(passFetchedEntriesToStoreBlockOperation)
        upsertInStoreOperation.addDependency(passFetchedEntriesToStoreBlockOperation)
        
        let passServerResultsToStoreBlockOperation = BlockOperation { [unowned downloadFromServerOperation, unowned deleteRedundantAgentEntriesOperation, unowned upsertInStoreOperation] in
            guard case let .success(entries)? = downloadFromServerOperation.result else {
                print("Unresolved Error: unable to get result from download from server operation")
                deleteRedundantAgentEntriesOperation.cancel()
                upsertInStoreOperation.cancel()
                return
            }
            deleteRedundantAgentEntriesOperation.serverEntries = entries
            upsertInStoreOperation.serverEntries = entries
        }
        
        passServerResultsToStoreBlockOperation.addDependency(downloadFromServerOperation)
        deleteRedundantAgentEntriesOperation.addDependency(passServerResultsToStoreBlockOperation)
//        updateAgentEntriesOperation.addDependency(passServerResultsToStore)
        upsertInStoreOperation.addDependency(passServerResultsToStoreBlockOperation)
        
        return [fetchExistingAgentsFromStoreOperation,
                passFetchedEntriesToStoreBlockOperation,
                downloadFromServerOperation,
                passServerResultsToStoreBlockOperation,
                deleteRedundantAgentEntriesOperation,
                upsertInStoreOperation]
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
    private let shouldFetchDisabledAccounts: Bool
    var result: Result<[Agent], OperationError>?
    
    init(context: NSManagedObjectContext, shouldFetchDisabledAccounts: Bool) {
        self.context = context
        self.shouldFetchDisabledAccounts = shouldFetchDisabledAccounts
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        let request: NSFetchRequest<Agent> = Agent.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Agent.isDisabled)) = %d", shouldFetchDisabledAccounts)
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
    
    private let showOnlyDisabledAccounts: Bool
    
    init(showOnlyDisabledAccounts: Bool) {
        self.showOnlyDisabledAccounts = showOnlyDisabledAccounts
    }
    
    var result: Result<[AgentProperties], APIService.APIError>?
    
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
        finish()
    }
    
    func agentsFetchCompletion(result: Result<AgentsJSON, APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        switch result {
            case .failure(let error):
                self.result = .failure(error)
            case .success(let resultData):
                let errorMessage = "Failed to get results from server. Please try again."
                let serverResult = resultData.result
                switch serverResult {
                    case .failure:
                        self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
                    case .success:
                        self.result = .success(resultData.agents)
            }
        }
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    func disabledAccountsFetchCompletion(result: Result<DisabledAccountsJSON, APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        switch result {
            case .failure(let error):
                self.result = .failure(error)
            case .success(let resultData):
                let errorMessage = "Failed to get results from server. Please try again."
                let serverResult = resultData.result
                switch serverResult {
                    case .failure:
                        self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
                    case .success:
                        self.result = .success(resultData.disabledAccounts)
            }
        }
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        if isCancelled {
            finish()
            return
        }
//        APIOperations.triggerAPIEndpointOperations(endpoint: .FetchAgents, httpMethod: .GET, params: params, completion: finish, decoder: defaultDecoder)
        if !showOnlyDisabledAccounts {
            APIServer<AgentsJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchAgents, httpMethod: .GET, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: agentsFetchCompletion)
        } else {
            APIServer<DisabledAccountsJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchDisabledAccounts, httpMethod: .GET, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: disabledAccountsFetchCompletion)
        }
    }
    private func finish() {
        if showOnlyDisabledAccounts {
            disabledAccountsFetchCompletion(result: .failure(.cancelled))
        } else {
            agentsFetchCompletion(result: .failure(.cancelled))
        }
    }
}


/*
/// Download Disbaled Agents entries from the server.
class DownloadDisabledAgentsEntriesFromServerOperation: Operation {
    var result: Result<[AgentProperties], APIService.APIError>?
    
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
        finish(result: .failure(.cancelled))
    }
    
    func finish(result: Result<AgentsJSON, APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        switch result {
            case .failure(let error):
                self.result = .failure(error)
            case .success(let resultData):
                let errorMessage = "Failed to get results from server. Please try again."
                let serverResult = resultData.result
                switch serverResult {
                    case .failure:
                        self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
                    case .success:
                        self.result = .success(resultData.agents)
            }
        }
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        if isCancelled {
            finish(result: .failure(.cancelled))
            return
        }
//        APIOperations.triggerAPIEndpointOperations(endpoint: .FetchAgents, httpMethod: .GET, params: params, completion: finish, decoder: defaultDecoder)
        APIServer<AgentsJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchDisabledAccounts, httpMethod: .GET, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: finish)
    }
}

*/


/// Deletes the redundant agent entries from core data store.
class DeleteRedundantAgentEntriesOperation: Operation {
    
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
    
    
    var fetchedEntries:[Agent]?
    var serverEntries:[AgentProperties]?
    let shouldFetchDisabledAccounts: Bool
    
    init(context: NSManagedObjectContext, shouldFetchDisabledAccounts: Bool) {
        self.context = context
        self.shouldFetchDisabledAccounts = shouldFetchDisabledAccounts
    }
    convenience init(context: NSManagedObjectContext, fetchedEntries: [Agent]?, serverEntries:[AgentProperties]?, shouldFetchDisabledAccounts: Bool) {
        self.init(context: context, shouldFetchDisabledAccounts: shouldFetchDisabledAccounts)
        self.fetchedEntries = fetchedEntries
        self.serverEntries = serverEntries
    }
    
    override func main() {
        let fetchRequest: NSFetchRequest<Agent> = Agent.fetchRequest()
        
        guard fetchedEntries != nil, !fetchedEntries!.isEmpty else {
            print("No Fetched Entries or nil")
            return
        }
        let disabledAccountsPredicate = NSPredicate(format: "\(#keyPath(Agent.isDisabled)) = %d", shouldFetchDisabledAccounts)
        if let serverEntries = serverEntries,
            !serverEntries.isEmpty {
            let serverAgentIDs = serverEntries.map { $0.userId }.compactMap { $0 }
//            fetchRequest.predicate = NSPredicate(format: "NOT (\(#keyPath(Agent.userID)) IN %@)", serverAgentIDs)
            let agentIDsPredicate = NSPredicate(format: "NOT (\(#keyPath(Agent.userID)) IN %@)", serverAgentIDs)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [disabledAccountsPredicate, agentIDsPredicate])
            fetchRequest.predicate = predicate
        } else {
            print("No Server Entries, deleting all entries")
            fetchRequest.predicate = disabledAccountsPredicate
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





/// Upsert Agents entries returned from the server to the Core Data store.
class UpsertAgentEntriesInStoreOperation: Operation {
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
    var serverEntries:[AgentProperties]?
    let showOnlyDisabledAccounts: Bool
    
    init(context: NSManagedObjectContext, showOnlyDisabledAccounts: Bool) {
        self.context = context
        self.showOnlyDisabledAccounts = showOnlyDisabledAccounts
    }
    
    convenience init(context: NSManagedObjectContext, serverEntries: [AgentProperties], showOnlyDisabledAccounts: Bool) {
        self.init(context: context, showOnlyDisabledAccounts: showOnlyDisabledAccounts)
        self.serverEntries = serverEntries
    }
    
    override func main() {
        //        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        guard let serverEntries = serverEntries, !serverEntries.isEmpty else {
            print("No Server Entry to add, returning")
            return
        }
        context.performAndWait {
            _ = serverEntries.map { serverEntry -> Agent in
                let existingAgent = fetchedEntries?.first(where: { Int($0.workerID) == serverEntry.workerId })
                let count = existingAgent?.externalPendingMessagesCount ?? 0
                let autoResponseServerObject = existingAgent?.autoResponse?.serverObject
                let agent = Agent(context: context, agentEntryFromServer: serverEntry)
                agent.isDisabled = showOnlyDisabledAccounts
                agent.externalPendingMessagesCount = count
                if let autoResponse = autoResponseServerObject {
                    _ = AutoResponse(context: context, autoResponseEntry: autoResponse, agent: agent, synced: true)
                }
                return agent
            }
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "Error upserting agent entries in core data store: \(error.localizedDescription))", log: .coredata, logType: .error)
                self.error = .coreDataError(error: error)
            }
            context.reset()
        }
    }
}











/// - tag: Not in use since AddToStore operation upserts all entities with the help of TrumpMerge Policy
/*
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
                        _ = Agent(context: context, agentEntryFromServer: serverEntry, pendingMessagesCount: 0)
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
*/







/// - tag: Not in use
/*
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

*/







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
                    if let date = object.lastMessageDate {
                        object.agent.lastMessageDate = date
                        object.agent.date = date
                    }
                }
                try context.save()
            } catch {
                let message = "Error updating pending messages count: \(error.localizedDescription)"
                printAndLog(message: message, log: .coredata, logType: .error)
                self.error = .coreDataError(error: error)
            }
        }
//        context.reset()
    }
}







/// Upsert Agent's gallery media item entries returned from the firebase to the Core Data store.
class MergeGalleryItemEntriesFromFirebaseToStore_Operation: Operation {
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
    let firebaseEntries:[FirebaseAgentGalleryItem]?
    let fetchedEntries:[AgentGalleryItem]
    init(context: NSManagedObjectContext, agent:Agent, firebaseEntries:[FirebaseAgentGalleryItem]?, fetchedEntries:[AgentGalleryItem]) {
        self.context = context
        self.agent = agent
        self.firebaseEntries = firebaseEntries
        self.fetchedEntries = fetchedEntries
    }
    
    override func main() {
        guard let firebaseEntries = firebaseEntries else {
            printAndLog(message: "No firebase agent gallery items entries to add", log: .firebase, logType: .info)
            return
        }
        let fetchRequest:NSFetchRequest = AgentGalleryItem.fetchRequest()
        let serverIDs = firebaseEntries.map { $0.key }.compactMap { $0 }
        let agentPredicate = NSPredicate(format: "\(#keyPath(AgentGalleryItem.agent)) == %@", agent)
        let filterPredicate = NSPredicate(format: "NOT (\(#keyPath(AgentGalleryItem.firebaseKey)) IN %@)", serverIDs)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [agentPredicate, filterPredicate])
        
        context.performAndWait {
            do {
                // Delete redundant entries
                let entriesToDelete = try context.fetch(fetchRequest)
                _ = entriesToDelete.map { agent.removeFromGalleryItems($0) }
                
                // Upsert entries from firebase
                _ = firebaseEntries.map { firebaseEntry -> AgentGalleryItem in
                    let fetchedEntry = fetchedEntries.first(where: { $0.firebaseKey == firebaseEntry.key })
                    let cachedImageUUID = fetchedEntry?.uuid
                    let state:AgentGalleryItem.MediaState = fetchedEntry?.state ?? .new
                    return AgentGalleryItem(context: context, agentGalleryItemEntryFromFirebase: firebaseEntry, agent: agent, uuid: cachedImageUUID, state: state)
                }
                
                
                try context.save()
            } catch {
                let errorMessage = "Error adding entries to store: \(error))"
                printAndLog(message: errorMessage, log: .coredata, logType: .error)
                self.error = .coreDataError(error: error)
            }
        }
    }
}
