//
//  AutoResponseOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

struct AutoResponseOperations {
    //MARK: Fetch Agent's Auto Response from Server and Synchronize
    /// Returns an array of operations for synchronizing Agent's Auto Response.
    static func getOperationsToFetchAndSaveAutoResponse(using context: NSManagedObjectContext, userID:Int, forAgent agent:Agent) -> [Operation] {
        let fetchFromStore_Operation = FetchSavedAgentAutoResponseEntry_Operation(context: context)
        let downloadFromServer_Operation = DownloadAgentAutoResponseEntryFromServer_Operation(userID: userID)
        let addToStore_Operation = AddAgentAutoResponseEntryToCoreDataStore_Operation(context: context, agent: agent)
        
        let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned addToStore_Operation] in
            guard case let .success(entry) = fetchFromStore_Operation.result else {
                #if !RELEASE
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
                #if !RELEASE
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
    
    
    
    
    //MARK: POST Agent's Auto Response to Server and Synchronize
    /// Returns an array of operations for updating  Agent's Auto Response from Core Data store to server.
    static func getOperationsToUpdateAutoResponseToServer(using context: NSManagedObjectContext, userID:Int, autoResponseID:Int, forAgent agent:Agent, smsReplyToUpdate:String) -> [Operation] {
        let saveEntryToStore_Operation = SaveUserUpdatedAutoResponseEntryToStore_Operation(context: context, agent: agent, smsReply: smsReplyToUpdate)
        let updateEntryOnServer_Operation = UpdateAgentAutoResponseEntryOnServer_Operation(autoResponseID: autoResponseID, smsReply: smsReplyToUpdate, userID: userID)
        let syncEntryToStore_Operation = SyncUserUpdatedAutoResponseEntryFromServerToStore_Operation(context: context, agent: agent)
        
        let passServerResultsToStore_Operation = BlockOperation { [unowned updateEntryOnServer_Operation, unowned syncEntryToStore_Operation] in
            guard case let .success(entry)? = updateEntryOnServer_Operation.result else {
                #if !RELEASE
                print("Unresolved Error: unable to get result from download from server operation")
                #endif
                syncEntryToStore_Operation.cancel()
                return
            }
            syncEntryToStore_Operation.serverEntry = entry
        }
        
        passServerResultsToStore_Operation.addDependency(updateEntryOnServer_Operation)
        syncEntryToStore_Operation.addDependency(passServerResultsToStore_Operation)
        
        return [
            saveEntryToStore_Operation,
            updateEntryOnServer_Operation,
            passServerResultsToStore_Operation,
            syncEntryToStore_Operation
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
                    #if !RELEASE
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
      APIOperations.triggerAPIEndpointOperations(endpoint: .AutoResponse,
                                                 httpMethod: .GET,
                                                 params: params,
                                                 decoder: defaultDecoder,
                                                 completion: finish)
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
            #if !RELEASE
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






/// Save updated Agent Auto Response  entry from user input to the Core Data store.
class SaveUserUpdatedAutoResponseEntryToStore_Operation: Operation {
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
    private let smsReply:String
    
    init(context: NSManagedObjectContext, agent:Agent, smsReply:String) {
        self.context = context
        self.agent = agent
        self.smsReply = smsReply
    }
    
    override func main() {
        //        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        context.performAndWait {
            do {
                agent.autoResponse?.smsReply = smsReply
                agent.autoResponse?.synced = false
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}


/// Updates Agent's Auto Response entry from core data store to the server.
class UpdateAgentAutoResponseEntryOnServer_Operation: Operation {
    var result: Result<AutoResponseCodable, APIService.APIError>?
    private let encoder = JSONEncoder()
    private var downloading = false
    private let params:[String:String]
    struct Body:Codable {
        let id:Int
        let user_id:Int
        let company_id:String
        let sms_replay:String
    }
    private let headers = [
        HTTPHeader(key: .contentType, value: "application/json"),
    ]
    private let httpBody:Data
    init(autoResponseID:Int, smsReply:String, userID:Int) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID
        ]
        let body = Body(id: autoResponseID, user_id: userID, company_id: companyID, sms_replay: smsReply)
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
      APIOperations.triggerAPIEndpointOperations(endpoint: .AutoResponse,
                                                 httpMethod: .POST,
                                                 params: params,
                                                 httpBody: httpBody,
                                                 headers: headers,
                                                 decoder: defaultDecoder,
                                                 completion: finish)
    }
}


/// Save updated Agent Auto Response  entry from user input to the Core Data store.
class SyncUserUpdatedAutoResponseEntryFromServerToStore_Operation: Operation {
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
    
    init(context: NSManagedObjectContext, agent:Agent) {
        self.context = context
        self.agent = agent
    }
    
    override func main() {
        //        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        guard let serverEntry = serverEntry else {
            #if !RELEASE
            print("Failed to unwrap server entry in SyncUserUpdatedAutoResponseEntryFromServerToStore Operation")
            #endif
            return
        }
        context.performAndWait {
            do {
                agent.autoResponse?.smsReply = serverEntry.smsReply
                agent.autoResponse?.updatedAt = serverEntry.updatedAt != nil ? Date.getDateFromString(dateString: serverEntry.updatedAt, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
                agent.autoResponse?.synced = true
                try context.save()
            } catch {
                print("Error adding entries to store: \(error))")
                self.error = .coreDataError(error: error)
            }
        }
    }
}
