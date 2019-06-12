//
//  ExternalConversation.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import CoreData

class ExternalConversation:NSManagedObject {
    @NSManaged var allLastMessageSeen : String?
    @NSManaged var allLastMessageText : String?
    @NSManaged var colour : Int16
    @NSManaged var customerId : Int16
    @NSManaged var customerPerson : String?
    @NSManaged var customerPhoneNumber : String?
    @NSManaged var externalConversationBlackList : Int16
    @NSManaged var externalConversationId : Int16
    @NSManaged var internalAddressBookId : Int16
    @NSManaged var internalAddressBookNameActive : Int16
    @NSManaged var internalAddressBookName : String?
    @NSManaged var lastMessageDatetime : Date
    @NSManaged var node : String?
    @NSManaged var priority : Int16
    @NSManaged var unreadMessages : Int16
    @NSManaged var workerPerson : String?
    @NSManaged var workerPhoneNumber : String?
    @NSManaged var `internal` : InternalConversation?
    @NSManaged var isArchived : Bool
    
    static func update(conversation:ExternalConversation, context:NSManagedObjectContext, externalConversation:ExternalConversationsCodable) {
        conversation.setValue(externalConversation.allLastMessageSeen, forKey: "allLastMessageSeen")
        conversation.setValue(externalConversation.allLastMessageText, forKey: "allLastMessageText")
        conversation.setValue(externalConversation.colour, forKey: "colour")
        conversation.setValue(externalConversation.customerId, forKey: "customerId")
        conversation.setValue(externalConversation.customerPerson, forKey: "customerPerson")
        conversation.setValue(externalConversation.customerPhoneNumber, forKey: "customerPhoneNumber")
        conversation.setValue(externalConversation.externalConversationBlackList, forKey: "externalConversationBlackList")
        conversation.setValue(externalConversation.externalConversationId, forKey: "externalConversationId")
        conversation.setValue(externalConversation.internalAddressBookId, forKey: "internalAddressBookId")
        conversation.setValue(externalConversation.internalAddressBookNameActive, forKey: "internalAddressBookNameActive")
        conversation.setValue(externalConversation.internalAddressBookNames, forKey: "internalAddressBookName")
        conversation.setValue(Date(timeIntervalSince1970: externalConversation.lastMessageDatetime ?? 0), forKey: "lastMessageDatetime")
        conversation.setValue(externalConversation.node, forKey: "node")
        conversation.setValue(externalConversation.priority, forKey: "priority")
        conversation.setValue(externalConversation.unreadMessages, forKey: "unreadMessages")
        conversation.setValue(externalConversation.workerPerson, forKey: "workerPerson")
        conversation.setValue(externalConversation.workerPhoneNumber, forKey: "workerPhoneNumber")
        do {
            try context.save()
        } catch let error {
            print("Insertion Error: \(error.localizedDescription)")
        }
        
    }
    
    static func insert(conversation:NSManagedObject, context:NSManagedObjectContext, externalConversation:ExternalConversationsCodable, internalConversation:InternalConversation, isArchived:Bool) {
        conversation.setValue(externalConversation.allLastMessageSeen, forKey: "allLastMessageSeen")
        conversation.setValue(externalConversation.allLastMessageText, forKey: "allLastMessageText")
        conversation.setValue(externalConversation.colour, forKey: "colour")
        conversation.setValue(externalConversation.customerId, forKey: "customerId")
        conversation.setValue(externalConversation.customerPerson, forKey: "customerPerson")
        conversation.setValue(externalConversation.customerPhoneNumber, forKey: "customerPhoneNumber")
        conversation.setValue(externalConversation.externalConversationBlackList, forKey: "externalConversationBlackList")
        conversation.setValue(externalConversation.externalConversationId, forKey: "externalConversationId")
        conversation.setValue(externalConversation.internalAddressBookId, forKey: "internalAddressBookId")
        conversation.setValue(externalConversation.internalAddressBookNameActive, forKey: "internalAddressBookNameActive")
        conversation.setValue(externalConversation.internalAddressBookNames, forKey: "internalAddressBookName")
        conversation.setValue(Date(timeIntervalSince1970: externalConversation.lastMessageDatetime ?? 0), forKey: "lastMessageDatetime")
        conversation.setValue(externalConversation.node, forKey: "node")
        conversation.setValue(externalConversation.priority, forKey: "priority")
        conversation.setValue(externalConversation.unreadMessages, forKey: "unreadMessages")
        conversation.setValue(externalConversation.workerPerson, forKey: "workerPerson")
        conversation.setValue(externalConversation.workerPhoneNumber, forKey: "workerPhoneNumber")
        conversation.setValue(internalConversation, forKey: "internal")
        conversation.setValue(isArchived, forKey: "isArchived")
        do {
            try context.save()
        } catch let error {
            print("Insertion Error: \(error.localizedDescription)")
        }
    }
}




/*
class ExternalConversation:NSManagedObject, Codable {
    @NSManaged var allLastMessageSeen : String?
    @NSManaged var allLastMessageText : String?
    @NSManaged var colour : Int16
    @NSManaged var customerId : Int16
    @NSManaged var customerPerson : String?
    @NSManaged var customerPhoneNumber : String?
    @NSManaged var externalConversationBlackList : Int16
    @NSManaged var externalConversationId : Int16
    @NSManaged var internalAddressBookId : Int16
    @NSManaged var internalAddressBookNameActive : Int16
    @NSManaged var internalAddressBookName : String?
    @NSManaged var lastMessageDatetime : Date
    @NSManaged var node : String?
    @NSManaged var priority : Int16
    @NSManaged var unreadMessages : Int16
    @NSManaged var workerPerson : String?
    @NSManaged var workerPhoneNumber : String?
    @NSManaged var `internal` : InternalConversation?
    @NSManaged var isArchived : Bool
//    @NSManaged var archived : [ExternalConversation]?
    
    enum CodingKeys: String, CodingKey {
        case allLastMessageSeen = "all_last_message_seen"
        case allLastMessageText = "all_last_message_text"
        case colour = "colour"
        case customerId = "customer_id"
        case customerPerson = "customer_person"
        case customerPhoneNumber = "customer_phone_number"
        case externalConversationBlackList = "external_conversation_black_list"
        case externalConversationId = "external_conversation_id"
        case internalAddressBookId = "internal_address_book_id"
        case internalAddressBookNameActive = "internal_address_book_name_active"
        case internalAddressBookName = "internal_address_book_names"
        case lastMessageDatetime = "last_message_datetime"
        case node = "node"
        case priority = "priority"
        case unreadMessages = "unread_messages"
        case workerPerson = "worker_person"
        case workerPhoneNumber = "worker_phone_number"
//        case `internal` = "internal"
        case isArchived = "isArchived"
    }
    
    //MARK: DECODABLE
    required convenience init(from decoder: Decoder) throws {
        guard let context = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: String(describing:ExternalConversation.self), in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        allLastMessageSeen = try values.decodeIfPresent(String.self, forKey: .allLastMessageSeen)
        allLastMessageText = try values.decodeIfPresent(String.self, forKey: .allLastMessageText)
        colour = try values.decodeIfPresent(Int16.self, forKey: .colour) ?? 0
        customerId = try values.decodeIfPresent(Int16.self, forKey: .customerId) ?? 0
        customerPerson = try values.decodeIfPresent(String.self, forKey: .customerPerson)
        customerPhoneNumber = try values.decodeIfPresent(String.self, forKey: .customerPhoneNumber)
        externalConversationBlackList = try values.decodeIfPresent(Int16.self, forKey: .externalConversationBlackList) ?? 0
        externalConversationId = try values.decodeIfPresent(Int16.self, forKey: .externalConversationId) ?? 0
        internalAddressBookId = try values.decodeIfPresent(Int16.self, forKey: .internalAddressBookId) ?? 0
        internalAddressBookNameActive = try values.decodeIfPresent(Int16.self, forKey: .internalAddressBookNameActive) ?? 0
        internalAddressBookName = try values.decodeIfPresent(String.self, forKey: .internalAddressBookName)
        lastMessageDatetime = Date(timeIntervalSince1970: try values.decodeIfPresent(Double.self, forKey: .lastMessageDatetime) ?? 0)
        node = try values.decodeIfPresent(String.self, forKey: .node)
        priority = try values.decodeIfPresent(Int16.self, forKey: .priority) ?? 1
        unreadMessages = try values.decodeIfPresent(Int16.self, forKey: .unreadMessages) ?? 0
        workerPerson = try values.decodeIfPresent(String.self, forKey: .workerPerson)
        workerPhoneNumber = try values.decodeIfPresent(String.self, forKey: .workerPhoneNumber)
//        `internal` = values. as? InternalConversation
        isArchived = try values.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(allLastMessageSeen, forKey: .allLastMessageSeen)
        try container.encode(allLastMessageText, forKey: .allLastMessageText)
        try container.encode(colour, forKey: .colour)
        try container.encode(customerId, forKey: .customerId)
        try container.encode(customerPerson, forKey: .customerPerson)
        try container.encode(customerPhoneNumber, forKey: .customerPhoneNumber)
        try container.encode(externalConversationBlackList, forKey: .externalConversationBlackList)
        try container.encode(externalConversationId, forKey: .externalConversationId)
        try container.encode(internalAddressBookId, forKey: .internalAddressBookId)
        try container.encode(internalAddressBookNameActive, forKey: .internalAddressBookNameActive)
        try container.encode(internalAddressBookName, forKey: .internalAddressBookName)
        try container.encode(lastMessageDatetime, forKey: .lastMessageDatetime)
        try container.encode(node, forKey: .node)
        try container.encode(priority, forKey: .priority)
        try container.encode(unreadMessages, forKey: .unreadMessages)
        try container.encode(workerPerson, forKey: .workerPerson)
        try container.encode(workerPhoneNumber, forKey: .workerPhoneNumber)
//        try container.encode(`internal`, forKey: .internal)
        try container.encode(isArchived, forKey: .isArchived)
    }
}
*/
