//
//  SMSDetailVCCoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension SMSDetailViewController {
    func fetchSavedExternalConvos(isArchive:Bool?, context:NSManagedObjectContext) -> [ExternalConversation]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        let workerIdPredicate = NSPredicate(format: "internal.workerId = %d", self.workerId)
        if let isArchive = isArchive {
            let archiveCheckPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value:isArchive))
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workerIdPredicate, archiveCheckPredicate])
            fetchRequest.predicate = andPredicate
        } else {
            fetchRequest.predicate = workerIdPredicate
        }
        do {
            return try context.fetch(fetchRequest) as? [ExternalConversation]
        } catch let error {
            print("Error=> \(error.localizedDescription)")
            return nil
        }
    }
    func saveToCoreData(data: Data, isArchived:Bool) {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode([ExternalConversationsCodable].self, from: data)
            if !isArchived {
                DispatchQueue.main.async {
                    self.syncConversations(fetchedConvos: response, context: managedObjectContext, isArchived: false)
                }
//                response.forEach({$0.internal = self.internalConversation})
                try managedObjectContext.save()
            } else {
//                response.forEach({
//                    $0.internal = self.internalConversation
//                    $0.isArchived = true
//                })
                try managedObjectContext.save()
            }
            
        } catch let error {
            print("Error Processing Response Data: \(error)")
            DispatchQueue.main.async {
                
            }
        }
    }
    func syncConversations(fetchedConvos:[ExternalConversationsCodable], context:NSManagedObjectContext, isArchived:Bool) {
        context.performAndWait {
            let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
            
            let convoIds = fetchedConvos.map { $0.externalConversationId }.compactMap { $0 }
            print("Internet fetched External Convo IDs => \(convoIds)")
            matchingRequest.predicate = NSPredicate(format: "externalConversationId in %@", argumentArray: [convoIds])
            if let savedConvos = self.fetchSavedExternalConvos(isArchive: false, context: context) {
                do {
                    print("saved external count => \(savedConvos.count)")
                    if let savedFilteredConvos = try context.fetch(matchingRequest) as? [ExternalConversation] {
                        print("Saved Filtered External Convos Count => \(savedFilteredConvos.count)")
                        self.deleteConvos(savedConvos, savedFilteredConvos, context)
                        self.updateConvos(fetchedConvos: fetchedConvos, savedFilteredConvos: savedFilteredConvos, context: context)
                        self.insertConvos(fetchedConvos: fetchedConvos, savedFilteredConvos: savedFilteredConvos, context: context, isArchived: isArchived)
                    }
                    
                } catch let error {
                    print("Bingo Error")
                    print(error.localizedDescription)
                }
            }
        }
    }
    func deleteConvos(_ savedConvos:[ExternalConversation], _ savedFilteredConvos:[ExternalConversation], _ context:NSManagedObjectContext) {
        let convosToDelete = savedConvos.filter({!savedFilteredConvos.contains($0)})
        print("External Convos to delete: Count=> \(convosToDelete.count)")
        guard !convosToDelete.isEmpty else {
            print("No External Convos to delete")
            return
        }
        let convoIds = convosToDelete.map { $0.externalConversationId }.compactMap { $0 }
        print("External Convo IDs to delete => \(convoIds)")
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        matchingRequest.predicate = NSPredicate(format: "externalConversationId in %@", argumentArray: [convoIds])
        do {
            let objects = try context.fetch(matchingRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
            try context.save()
        } catch let error {
            print("Error deleting: \(error.localizedDescription)")
        }
        PersistenceService.shared.saveContext()
        self.setupInboxView()
    }
    func updateConvos(fetchedConvos:[ExternalConversationsCodable], savedFilteredConvos:[ExternalConversation], context:NSManagedObjectContext) {
        
        let toUpateConvoIds = savedFilteredConvos.map { $0.externalConversationId }.compactMap { $0 }
        print("To update Convo IDs => \(toUpateConvoIds)")
        guard !toUpateConvoIds.isEmpty else {
            print("No External Convos to update")
            return
        }
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        matchingRequest.predicate = NSPredicate(format: "externalConversationId in %@", argumentArray: [toUpateConvoIds])
        do {
            let convosToUpdate = try context.fetch(matchingRequest) as! [ExternalConversation]
            convosToUpdate.forEach { (convo) in
                ExternalConversation.update(conversation: convo, context: context, externalConversation: fetchedConvos.first(where: { (con) -> Bool in
                    con.externalConversationId == Int(convo.externalConversationId)
                })!)
            }
        } catch let error {
            print("Error Updating Core Data External Conversations")
            print(error.localizedDescription)
        }
    }
    func insertConvos(fetchedConvos:[ExternalConversationsCodable], savedFilteredConvos:[ExternalConversation], context:NSManagedObjectContext, isArchived:Bool) {
        let newConvos = fetchedConvos.filter { (coco) -> Bool in
            !savedFilteredConvos.contains(where: { Int($0.externalConversationId) == coco.externalConversationId })
        }
        
        guard !newConvos.isEmpty else {
            print("No External Convos to insert")
            return
        }
        print("New External Convos available to insert. Count => \(newConvos.count)")
        
        newConvos.forEach { (newConvo) in
            let entity =  NSEntityDescription.entity(forEntityName: String(describing: ExternalConversation.self), in:context)!
            let convoObject = NSManagedObject(entity: entity, insertInto: context)
            ExternalConversation.insert(conversation: convoObject, context: context, externalConversation: newConvo, internalConversation: self.internalConversation, isArchived: isArchived)
        }
        
        PersistenceService.shared.saveContext()
        isArchived ? self.setupArchivedView() : self.setupInboxView()
    }
}
