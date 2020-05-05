//
//  AutoResponseOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData

struct AutoResponseOperations {
    /// Returns an array of operations for synchronizing Agent's Auto Response.
    static func getOperationsToFetchAndSaveAutoResponse(using context: NSManagedObjectContext, userID:Int, forAgent agent:Agent) -> [Operation] {
        let fetchFromStore_Operation = FetchSavedAgentAutoResponseEntry_Operation(context: context)
        let downloadFromServer_Operation = DownloadAgentAutoResponseEntryFromServer_Operation(userID: userID)
        let addToStore_Operation = AddAgentAutoResponseEntryToCoreDataStore_Operation(context: context, agent: agent)
        
        let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned addToStore_Operation] in
            guard case let .success(entry) = fetchFromStore_Operation.result else {
                #if DEBUG
                print("no fetched result(AutoResponse) in passFetchResultsToStore_Operation")
                #endif
                return
            }
            addToStore_Operation.fetchedEntry = entry
        }
        passFetchResultsToStore_Operation.addDependency(fetchFromStore_Operation)
        addToStore_Operation.addDependency(passFetchResultsToStore_Operation)
        
        let passServerResultsToStore_Operation = BlockOperation { [unowned downloadFromServer_Operation, unowned addToStore_Operation] in
            guard case let .success(entry)? = downloadFromServer_Operation.result else {
                #if DEBUG
                print("Unresolved Error: unable to get result from download from server operation")
                #endif
                addToStore_Operation.cancel()
                return
            }
            addToStore_Operation.serverEntry = entry
        }
        
        passServerResultsToStore_Operation.addDependency(downloadFromServer_Operation)
        addToStore_Operation.addDependency(passServerResultsToStore_Operation)
        
        return [
            fetchFromStore_Operation,
            passFetchResultsToStore_Operation,
            downloadFromServer_Operation,
            passServerResultsToStore_Operation,
            addToStore_Operation
        ]
    }
}



/// Fetches the  Agent's Auto Response entry from the Core Data store.
class FetchSavedAgentAutoResponseEntry_Operation: Operation {
    enum OperationError: Error, LocalizedError {
        case coreDataError(error:Error)
        
        var localizedDescription: String {
            switch self {
                case let .coreDataError(error): return "Core Data Error: \(error.localizedDescription)"
            }
        }
    }
    private let context: NSManagedObjectContext
    
    var result: Result<AutoResponse, OperationError>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        let request: NSFetchRequest<AutoResponse> = AutoResponse.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(AutoResponse.updatedAt), ascending: false)]
        
        context.performAndWait {
            do {
                let fetchResults = try context.fetch(request)
                guard !fetchResults.isEmpty, let autoResponse = fetchResults.first else {
                    #if DEBUG
                    print("No Fetch Results in Fetch Auto Response from Core Data Operation")
                    #endif
                    return
                }
                self.result = .success(autoResponse)
            } catch {
                print("Error fetching from context: \(error)")
                self.result = .failure(.coreDataError(error: error))
            }
        }
    }
}


/// Downloads Agent's Auto Response entry from the server.
class DownloadAgentAutoResponseEntryFromServer_Operation: Operation {
    var result: Result<AutoResponseCodable, APIService.APIError>?
    
    private var downloading = false
    private let params:[String:String]
    
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
    
    func finish(result: Result<AutoResponseCodable, APIService.APIError>) {
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
        APIOperations.triggerAPIEndpointOperations(endpoint: .AutoResponse, httpMethod: .GET, params: params, completion: finish)
    }
}



/// Add Agent Auto Response  entry returned from the server to the Core Data store.
class AddAgentAutoResponseEntryToCoreDataStore_Operation: Operation {
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
    var serverEntry:AutoResponseCodable?
    var fetchedEntry:AutoResponse?
    
    init(context: NSManagedObjectContext, agent:Agent) {
        self.context = context
        self.agent = agent
    }
    
    override func main() {
        //        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        guard let serverEntry = serverEntry else {
            #if DEBUG
            print("No Server Entry to add, returning")
            #endif
            return
        }
        if let fetchedEntry = fetchedEntry {
            context.performAndWait {
                do {
                    fetchedEntry.smsReply = serverEntry.smsReply
                    fetchedEntry.updatedAt = Date()
                    fetchedEntry.synced = true
                    fetchedEntry.autoResponseSender = agent
                    try context.save()
                } catch {
                    print("Error adding entries to store: \(error))")
                    self.error = .coreDataError(error: error)
                }
            }
        } else {
            context.performAndWait {
                do {
                    _ = AutoResponse(context: context, autoResponseEntry: serverEntry, agent: agent, synced: true)
                    try context.save()
                } catch {
                    print("Error adding entries to store: \(error))")
                    self.error = .coreDataError(error: error)
                }
            }
        }
        
    }
}
