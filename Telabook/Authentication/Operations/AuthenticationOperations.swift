//
//  AuthenticationOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import os
struct AuthenticationOperations {
    
}



/// Deletes all entities from core data store.
class DeleteAllEntities_Operation: Operation {
    
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
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        
        let entityNames = [
            NSStringFromClass(Agent.self),
            NSStringFromClass(BlockedUser.self)
        ]
        context.performAndWait {
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                batchDeleteRequest.resultType = .resultTypeObjectIDs
                do {
                    let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                    if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs], into: [PersistentContainer.shared.viewContext])
                    }
                } catch {
                    #if !RELEASE
                    print("Error deleting entries: \(error)")
                    #endif
                    os_log("Error deleting all entities: %@", log: .coredata, type: .error, error.localizedDescription)
                    self.error = .coreDataError(error: error)
                }
            }
        }
    }
}
