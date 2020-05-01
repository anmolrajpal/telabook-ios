//
//  AgentOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData

struct AgentOperations {
    // Returns an array of operations for fetching the latest entries and then adding them to the Core Data store.
    static func getOperationsToFetchLatestEntries(using context: NSManagedObjectContext) -> [Operation] {
        let fetchMostRecentEntry = FetchMostRecentAgentsEntryOperation(context: context)
        let downloadFromServer = DownloadAgentsEntriesFromServerOperation()
//        let passTimestampToServer = BlockOperation { [unowned fetchMostRecentEntry, unowned downloadFromServer] in
//            guard let timestamp = fetchMostRecentEntry.result?.timestamp else {
//                downloadFromServer.cancel()
//                return
//            }
//            downloadFromServer.sinceDate = timestamp
//        }
//        passTimestampToServer.addDependency(fetchMostRecentEntry)
//        downloadFromServer.addDependency(passTimestampToServer)
        
        let addToStore = AddAgentsEntriesToStoreOperation(context: context)
        let passServerResultsToStore = BlockOperation { [unowned downloadFromServer, unowned addToStore] in
            guard case let .success(entries)? = downloadFromServer.result else {
                addToStore.cancel()
                return
            }
            addToStore.entries = entries
        }
        passServerResultsToStore.addDependency(downloadFromServer)
        addToStore.addDependency(passServerResultsToStore)
        
        return [fetchMostRecentEntry,
                downloadFromServer,
                passServerResultsToStore,
                addToStore]
    }
}



/// Fetches the most recent Agents entry from the Core Data store.
class FetchMostRecentAgentsEntryOperation: Operation {
    private let context: NSManagedObjectContext
    
    var result: Agent?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        let request: NSFetchRequest<Agent> = Agent.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.date), ascending: false)]
        request.fetchLimit = 1
        
        context.performAndWait {
            do {
                let fetchResult = try context.fetch(request)
                guard !fetchResult.isEmpty else { return }
                
                result = fetchResult[0]
            } catch {
                print("Error fetching from context: \(error)")
            }
        }
    }
}


// Downloads entries created after the specified date.
class DownloadAgentsEntriesFromServerOperation: Operation {
    var result: Result<[AgentCodable], APIService.APIError>?
    
    private var downloading = false
    private var session = URLSession.shared
    private var dataTask: URLSessionDataTask!
    
    private let params:[String:String] = [
        "company_id":String(AppData.companyId)
    ]
    
    override init() {
        super.init()
        print("About to Hit Endpoint")
        dataTask = APIService.shared.hitEndpoint(endpoint: .FetchAgents, httpMethod: .GET, params: params, completion: finish)
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
        if let dataTask = dataTask {
            dataTask.cancel()
        }
    }
    
    func finish(result: Result<[AgentCodable], APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        dataTask = nil
        
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
        dataTask.resume()
    }
}




/// Add Agents entries returned from the server to the Core Data store.
class AddAgentsEntriesToStoreOperation: Operation {
    private let context: NSManagedObjectContext
    var entries: [AgentCodable]?
    var delay: TimeInterval = 0

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(context: NSManagedObjectContext, entries: [AgentCodable], delay: TimeInterval? = nil) {
        self.init(context: context)
        self.entries = entries
        if let delay = delay {
            self.delay = delay
        }
    }
    
    override func main() {
        guard let entries = entries else { return }

        context.performAndWait {
            do {
                for entry in entries {
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
                print("Error adding entries to store: \(error)")
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
