//
//  ScheduledMessagesOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

struct ScheduledMessagesOperations {
    static func getOperationsToFetchScheduledMessages(using context:NSManagedObjectContext) -> [Operation] {
        
        let fetchFromServer_Operation = FetchScheduledMessagesFromServer_Operation(limit: 100000, page: 1)
        let upsertInStore_Operation = MergeScheduledMessagesFromServerToStore_Operation(context: context)
        
        
        let passToStore_Operation = BlockOperation { [unowned fetchFromServer_Operation, unowned upsertInStore_Operation] in
            guard case let .success(scheduledMessages) = fetchFromServer_Operation.result else {
                if case let .failure(error) = fetchFromServer_Operation.result {
                    printAndLog(message: "Unresolved Error: Unable to update message on Firebase: \(error)", log: .firebase, logType: .error)
                }
                upsertInStore_Operation.cancel()
                return
            }
            upsertInStore_Operation.serverEntries = scheduledMessages
        }
        passToStore_Operation.addDependency(fetchFromServer_Operation)
        upsertInStore_Operation.addDependency(passToStore_Operation)
        
        return [
            fetchFromServer_Operation,
            passToStore_Operation,
            upsertInStore_Operation
        ]
    }
}







/// Fetches scheduled messages from Server
class FetchScheduledMessagesFromServer_Operation: Operation {
    var result: Result<[ScheduledMessageProperties], APIService.APIError>?
    
    private var downloading = false
    
    private let params:[String:String]
    
    init(limit:Int, page:Int) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID,
            "limit":String(limit),
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
        finish(result: .failure(.cancelled))
        super.cancel()
    }
    
    func finish(result: Result<ScheduledMessageJSON, APIService.APIError>) {
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
        
        let serverResult = resultData.result
        guard serverResult == .success else {
            self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
            didChangeValue(forKey: #keyPath(isFinished))
            didChangeValue(forKey: #keyPath(isExecuting))
            return
        }
        let scheduledMessages = resultData.scheduledMessages
        self.result = .success(scheduledMessages)
        
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
        APIServer<ScheduledMessageJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchScheduledMessages, httpMethod: .GET, params: params, completion: finish, decoder: JSONDecoder.apiServiceDecoder)
    }
}


/// Upsert Scheduled Message entries returned from the server to the Core Data store.
class MergeScheduledMessagesFromServerToStore_Operation: Operation {
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
    var serverEntries = [ScheduledMessageProperties]()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func main() {
        guard !serverEntries.isEmpty else { return }
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
                _ = batch.map({ return ScheduledMessage(context: context, newScheduledMessageEntryFromServer: $0) })
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        print("Error: \(error)\nCould not save Core Data context.")
                        self.error = .coreDataError(error: error)
                        return
                    }
                    context.reset()
                }
            }
        }
    }
}







/// Schedule new message on the server.
class ScheduleNewMessageOnServer_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    struct Body:Encodable {
        let company_id:String
        let customer_id:Int
        let worker_id:Int
        let date:String
        let text:String
    }
    private let encoder = JSONEncoder()
    private var downloading = false
    
    
    
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json"),
        HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
    ]
    private let httpBody:Data
    init(customerID:Int, workerID:Int, deliveryTime:String, textMessage:String) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID
        ]
        let body = Body(company_id: companyID, customer_id: customerID, worker_id: workerID, date: deliveryTime, text: textMessage)
        print(body)
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
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .ScheduleNewMessage, httpMethod: .POST, params: params, httpBody: httpBody, headers: headers, completion: finish)
    }
}
