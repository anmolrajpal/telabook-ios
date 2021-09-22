//
//  AddressBookOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

struct AddressBookOperations {
   /// Returns an array of operations for fetching the latest entries and then adding them to the Core Data store.
   static func getOperationsToFetchContacts(using context: NSManagedObjectContext, agent: Agent) -> [Operation] {
      let fetchFromStore_Operation = FetchSavedContactEntries_Operation(context: context, agent: agent)
      let fetchFromServer_Operation = FetchContactEntriesFromServer_Operation(workerId: agent.workerID.toInt)
      let deleteFromStore_Operation = DeleteRedundantContactEntries_Operation(context: context, agent: agent)
      let upsertInStore_Operation = UpsertContactEntriesInStore_Operation(context: context, agent: agent)
      
      let passFetchResultsToStore_Operation = BlockOperation { [unowned fetchFromStore_Operation, unowned deleteFromStore_Operation, unowned upsertInStore_Operation] in
         guard case let .success(entries)? = fetchFromStore_Operation.result else {
            print("Unresolved Error: Unable to get result from fetchFromStore_Operation")
            deleteFromStore_Operation.cancel()
            upsertInStore_Operation.cancel()
            return
         }
         deleteFromStore_Operation.fetchedEntries = entries
         upsertInStore_Operation.fetchedEntries = entries
      }
      passFetchResultsToStore_Operation.addDependency(fetchFromStore_Operation)
      deleteFromStore_Operation.addDependency(passFetchResultsToStore_Operation)
      upsertInStore_Operation.addDependency(passFetchResultsToStore_Operation)
      
      let passServerResultsToStore_Operation = BlockOperation { [unowned fetchFromServer_Operation, unowned deleteFromStore_Operation, unowned upsertInStore_Operation] in
         guard case let .success(entries)? = fetchFromServer_Operation.result else {
            print("Unresolved Error: unable to get result from download from server operation")
            deleteFromStore_Operation.cancel()
            upsertInStore_Operation.cancel()
            return
         }
         deleteFromStore_Operation.serverEntries = entries
         upsertInStore_Operation.serverEntries = entries
      }
      
      passServerResultsToStore_Operation.addDependency(fetchFromServer_Operation)
      deleteFromStore_Operation.addDependency(passServerResultsToStore_Operation)
      upsertInStore_Operation.addDependency(passServerResultsToStore_Operation)
      
      return [fetchFromStore_Operation,
              passFetchResultsToStore_Operation,
              fetchFromServer_Operation,
              passServerResultsToStore_Operation,
              deleteFromStore_Operation,
              upsertInStore_Operation]
   }
}



/// Fetches the most recent Agents entry from the Core Data store.
class FetchSavedContactEntries_Operation: Operation {
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
   private let agent: Agent
   
   var result: Result<[AddressBookContact], OperationError>?
   
   init(context: NSManagedObjectContext, agent: Agent) {
      self.context = context
      self.agent = agent
   }
   
   override func main() {
      let request: NSFetchRequest<AddressBookContact> = AddressBookContact.fetchRequest()
      request.predicate = NSPredicate(format: "\(#keyPath(AddressBookContact.agent)) == %@", agent)
      request.sortDescriptors = [NSSortDescriptor(key: #keyPath(AddressBookContact.contactConversationId), ascending: true)]
      
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
class FetchContactEntriesFromServer_Operation: Operation {
   
   private let params:[String:String]
   
   init(workerId:Int) {
      params = [
         "company_id":AppData.companyId.string,
         "worker_id":workerId.string
      ]
   }
   
   var result: Result<[AddressBookProperties], APIService.APIError>?
   
   private var downloading = false
   
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
   
   func fetchCompletion(result: Result<AddressBookJSON, APIService.APIError>) {
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
            self.result = .success(resultData.contacts)
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
      APIServer<AddressBookJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchContacts,
                                                              httpMethod: .GET,
                                                              params: params,
                                                              decoder: JSONDecoder.apiServiceDecoder,
                                                              completion: fetchCompletion)
   }
   private func finish() {
      fetchCompletion(result: .failure(.cancelled))
   }
}

/// Deletes the redundant address book contact entries from core data store.
class DeleteRedundantContactEntries_Operation: Operation {
   
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
   
   var fetchedEntries:[AddressBookContact]?
   var serverEntries:[AddressBookProperties]?
   private let agent: Agent
   
   init(context: NSManagedObjectContext, agent: Agent) {
      self.context = context
      self.agent = agent
   }
   convenience init(context: NSManagedObjectContext, fetchedEntries: [AddressBookContact]?, serverEntries:[AddressBookProperties]?, agent: Agent) {
      self.init(context: context, agent: agent)
      self.fetchedEntries = fetchedEntries
      self.serverEntries = serverEntries
   }
   
   override func main() {
      let fetchRequest: NSFetchRequest<AddressBookContact> = AddressBookContact.fetchRequest()
      
      guard fetchedEntries != nil, !fetchedEntries!.isEmpty else {
         print("No Fetched Entries or nil")
         return
      }
      
      if let serverEntries = serverEntries,
         !serverEntries.isEmpty {
         let serverIDs = serverEntries.map { $0.contactConversationId }.compactMap { $0 }
         let agentPredicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
         let filterPredicate = NSPredicate(format: "NOT (\(#keyPath(AddressBookContact.contactConversationId)) IN %@)", serverIDs)
         let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [agentPredicate, filterPredicate])
         fetchRequest.predicate = predicate
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


/// Upsert Address Book Contact entries returned from the server to the Core Data store.
class UpsertContactEntriesInStore_Operation: Operation {
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
   
   var fetchedEntries:[AddressBookContact]?
   var serverEntries:[AddressBookProperties]?
   private let agent:Agent
   
   init(context: NSManagedObjectContext, agent: Agent) {
      self.context = context
      self.agent = agent
   }
   
   convenience init(context: NSManagedObjectContext, serverEntries: [AddressBookProperties], agent: Agent) {
      self.init(context: context, agent: agent)
      self.serverEntries = serverEntries
   }
   
   override func main() {
      guard let serverEntries = serverEntries, !serverEntries.isEmpty else {
         print("No Server Entry to add.")
         return
      }
      context.performAndWait {
         _ = serverEntries.map { serverEntry -> AddressBookContact in
            let existingEntry = fetchedEntries?.first(where: { $0.contactConversationId == serverEntry.contactConversationId.toInt64 })
            if let existingAddresses = existingEntry?.addresses {
               for case let address as AddressEntity in existingAddresses {
                  existingEntry?.removeFromAddresses(address)
                  context.delete(address)
               }
            }
            let contact = AddressBookContact(context: context, addressBookProperties: serverEntry, agent: agent)
            return contact
         }
         do {
            if context.hasChanges { try context.save() }
         } catch {
            printAndLog(message: "Error upserting address book contact entries in core data store: \(error.localizedDescription))", log: .coredata, logType: .error)
            self.error = .coreDataError(error: error)
         }
         context.reset()
      }
   }
}
