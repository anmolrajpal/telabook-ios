//
//  ChatVCCoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
extension ChatViewController {
    func fetchSavedExternalChats(context:NSManagedObjectContext) -> [ExternalChat]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalChat.self))
        let conversationIdPredicate = NSPredicate(format: "externalConvo.externalConversationId = %d", Int16(self.conversationId) ?? 0)
        let nodePredicate = NSPredicate(format: "externalConvo.node = %@", self.node)
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conversationIdPredicate, nodePredicate])
            fetchRequest.predicate = andPredicate
        do {
            return try context.fetch(fetchRequest) as? [ExternalChat]
        } catch let error {
            print("Error=> \(error.localizedDescription)")
            return nil
        }
    }
    func saveToCoreData(messages: [Message]) {
        let context = PersistenceService.shared.persistentContainer.viewContext
        self.syncMessages(fetchedMessages: messages, context: context)
    }
    func syncMessages(fetchedMessages:[Message], context:NSManagedObjectContext) {
        context.performAndWait {
            let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalChat.self))
            
            let messageIds = fetchedMessages.map { $0.messageId }.compactMap { $0 }
            print("Internet Fetched External Chat Message IDs => \(messageIds)")
            matchingRequest.predicate = NSPredicate(format: "messageId in %@", argumentArray: [messageIds])
            if let savedChats = self.fetchSavedExternalChats(context: context) {
                do {
                    print("saved external chats Count => \(savedChats.count)")
                    if let savedFilteredChats = try context.fetch(matchingRequest) as? [ExternalChat] {
                        print("Saved Filtered External Chats Count => \(savedFilteredChats.count)")
                        self.deleteChats(savedChats, savedFilteredChats, context)
                        self.updateChats(fetchedChats: fetchedMessages, savedFilteredChats: savedFilteredChats, context: context)
                        self.insertChats(fetchedChats: fetchedMessages, savedFilteredChats: savedFilteredChats, context: context)
                    }
                    
                } catch let error {
                    print("Bingo Error")
                    print(error.localizedDescription)
                }
            }
        }
    }
    func deleteChats(_ savedChats:[ExternalChat], _ savedFilteredChats:[ExternalChat], _ context:NSManagedObjectContext) {
        let chatsToDelete = savedChats.filter({!savedFilteredChats.contains($0)})
        print("External Chats to delete: Count=> \(chatsToDelete.count)")
        guard !chatsToDelete.isEmpty else {
            print("No External chats to delete")
            return
        }
        let messageIds = chatsToDelete.map { $0.messageId }.compactMap { $0 }
        print("External Chats Message IDs to delete => \(messageIds)")
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalChat.self))
        matchingRequest.predicate = NSPredicate(format: "messageId in %@", argumentArray: [messageIds])
        do {
            let objects = try context.fetch(matchingRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
            try context.save()
        } catch let error {
            print("Error deleting external chats: \(error.localizedDescription)")
        }
        PersistenceService.shared.saveContext()
    }
    func updateChats(fetchedChats:[Message], savedFilteredChats:[ExternalChat], context:NSManagedObjectContext) {
        
        let toUpateMessageIds = savedFilteredChats.map { $0.messageId }.compactMap { $0 }
        print("To update External chat message IDs => \(toUpateMessageIds)")
        guard !toUpateMessageIds.isEmpty else {
            print("No External chats to update")
            return
        }
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalChat.self))
        matchingRequest.predicate = NSPredicate(format: "messageId in %@", argumentArray: [toUpateMessageIds])
        do {
            let chatsToUpdate = try context.fetch(matchingRequest) as! [ExternalChat]
            chatsToUpdate.forEach { (chat) in
//                ExternalChat.update(chat: chat, fetchedChat: fetchedChats.first(where: { (fetchedChat) -> Bool in
//                    fetchedChat.messageId == chat.messageId
//                })!, context: context)
                ExternalChat.update(chat: chat, fetchedChat: fetchedChats.first(where: { $0.messageId == chat.messageId })!, context: context)
            }
        } catch let error {
            print("Error Updating Core Data External Chats")
            print(error.localizedDescription)
        }
    }
    func insertChats(fetchedChats:[Message], savedFilteredChats:[ExternalChat], context:NSManagedObjectContext) {
//        let newChats = fetchedChats.filter { (c) -> Bool in
//            !savedFilteredChats.contains(where: { $0.messageId == c.messageId })
//        }
        let newChats = fetchedChats.filter({ fetchedChat in return !savedFilteredChats.contains(where: { $0.messageId == fetchedChat.messageId })})
        guard !newChats.isEmpty else {
            print("No External Chats to insert")
            return
        }
        print("New External Chats available to insert. Count => \(newChats.count)")
        
        newChats.forEach { (newChat) in
            let entity =  NSEntityDescription.entity(forEntityName: String(describing: ExternalChat.self), in:context)!
            let chatObject = NSManagedObject(entity: entity, insertInto: context)
            ExternalChat.insert(chat: chatObject, fetchedChat: newChat, conversation: self.externalConversation!, context: context)
        }
        PersistenceService.shared.saveContext()
    }
}
