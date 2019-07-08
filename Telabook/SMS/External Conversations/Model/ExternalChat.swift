//
//  ExternalChat.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
class ExternalChat: NSManagedObject {
    @NSManaged var messageId:String?
    @NSManaged var message:String?
    @NSManaged var date:Date
    @NSManaged var senderId:Int32
    @NSManaged var senderName:String?
    @NSManaged var senderNumber:String?
    @NSManaged var imageURL:String?
    @NSManaged var externalConvo:ExternalConversation?
    
    
    static func insert(chat:NSManagedObject, fetchedChat:Message, conversation:ExternalConversation, context:NSManagedObjectContext) {
        chat.setValue(fetchedChat.messageId, forKey: "messageId")
        chat.setValue(fetchedChat.text, forKey: "message")
        chat.setValue(fetchedChat.sentDate, forKey: "date")
        chat.setValue(fetchedChat.sender.id, forKey: "senderId")
        chat.setValue(fetchedChat.sender.displayName, forKey: "senderName")
        chat.setValue(fetchedChat.imageURL, forKey: "imageURL")
        chat.setValue(conversation, forKey: "externalConvo")
        do {
            try context.save()
        } catch let error {
            print("Insertion Error: \(error.localizedDescription)")
        }
    }
    
    static func update(chat:ExternalChat, fetchedChat:Message, context:NSManagedObjectContext) {
        chat.setValue(fetchedChat.messageId, forKey: "messageId")
        chat.setValue(fetchedChat.text, forKey: "message")
        chat.setValue(fetchedChat.sentDate, forKey: "date")
        chat.setValue(fetchedChat.sender.id, forKey: "senderId")
        chat.setValue(fetchedChat.sender.displayName, forKey: "senderName")
        chat.setValue(fetchedChat.imageURL, forKey: "imageURL")
        do {
            try context.save()
        } catch let error {
            print("Insertion Error: \(error.localizedDescription)")
        }
    }
}
