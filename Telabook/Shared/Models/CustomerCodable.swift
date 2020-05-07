//
//  CustomerCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData

struct CustomerCodable : Codable {
    
    let allLastMessageSeen : String?
    let allLastMessageText : String?
    let archive : Bool?
    let archived : Int?
    let blacklistReason : String?
    let colour : Int?
    let customerId : Int?
    let customerPerson : String?
    let customerPhoneNumber : String?
    let deleted : Bool?
    let deliveredByProvider : Int?
    let externalConversationBlackList : Int?
    let externalConversationId : Int?
    let incoming : Bool?
    let internalAddressBookId : Int?
    let internalAddressBookNameActive : Int?
    let internalAddressBookNames : String?
    let lastMessageDate : Int?
    let lastMessageDatetime : Int?
    let lastMessageKey : String?
    let messageType : String?
    let node : String?
    let priority : Int?
    let senderId : Int?
    let sentByApi : Int?
    let sentByApp : Int?
    let sentByProvider : Int?
    let unreadMessages : Int?
    let updatedAt : Int?
    let workerPerson : String?
    let workerPhoneNumber : String?
    
    enum CodingKeys: String, CodingKey {
        case allLastMessageSeen = "all_last_message_seen"
        case allLastMessageText = "all_last_message_text"
        case archive = "archive"
        case archived = "archived"
        case blacklistReason = "blacklist_reason"
        case colour = "colour"
        case customerId = "customer_id"
        case customerPerson = "customer_person"
        case customerPhoneNumber = "customer_phone_number"
        case deleted = "deleted"
        case deliveredByProvider = "delivered_by_provider"
        case externalConversationBlackList = "external_conversation_black_list"
        case externalConversationId = "external_conversation_id"
        case incoming = "incoming"
        case internalAddressBookId = "internal_address_book_id"
        case internalAddressBookNameActive = "internal_address_book_name_active"
        case internalAddressBookNames = "internal_address_book_names"
        case lastMessageDate = "last_message_date"
        case lastMessageDatetime = "last_message_datetime"
        case lastMessageKey = "last_message_key"
        case messageType = "message_type"
        case node = "node"
        case priority = "priority"
        case senderId = "sender_id"
        case sentByApi = "sent_by_api"
        case sentByApp = "sent_by_app"
        case sentByProvider = "sent_by_provider"
        case unreadMessages = "unread_messages"
        case updatedAt = "updated_at"
        case workerPerson = "worker_person"
        case workerPhoneNumber = "worker_phone_number"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        allLastMessageSeen = try values.decodeIfPresent(String.self, forKey: .allLastMessageSeen)
        allLastMessageText = try values.decodeIfPresent(String.self, forKey: .allLastMessageText)
        archive = try values.decodeIfPresent(Bool.self, forKey: .archive)
        archived = try values.decodeIfPresent(Int.self, forKey: .archived)
        blacklistReason = try values.decodeIfPresent(String.self, forKey: .blacklistReason)
        colour = try values.decodeIfPresent(Int.self, forKey: .colour)
        customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
        customerPerson = try values.decodeIfPresent(String.self, forKey: .customerPerson)
        customerPhoneNumber = try values.decodeIfPresent(String.self, forKey: .customerPhoneNumber)
        deleted = try values.decodeIfPresent(Bool.self, forKey: .deleted)
        deliveredByProvider = try values.decodeIfPresent(Int.self, forKey: .deliveredByProvider)
        externalConversationBlackList = try values.decodeIfPresent(Int.self, forKey: .externalConversationBlackList)
        externalConversationId = try values.decodeIfPresent(Int.self, forKey: .externalConversationId)
        incoming = try values.decodeIfPresent(Bool.self, forKey: .incoming)
        internalAddressBookId = try values.decodeIfPresent(Int.self, forKey: .internalAddressBookId)
        internalAddressBookNameActive = try values.decodeIfPresent(Int.self, forKey: .internalAddressBookNameActive)
        internalAddressBookNames = try values.decodeIfPresent(String.self, forKey: .internalAddressBookNames)
        lastMessageDate = try values.decodeIfPresent(Int.self, forKey: .lastMessageDate)
        lastMessageDatetime = try values.decodeIfPresent(Int.self, forKey: .lastMessageDatetime)
        lastMessageKey = try values.decodeIfPresent(String.self, forKey: .lastMessageKey)
        messageType = try values.decodeIfPresent(String.self, forKey: .messageType)
        node = try values.decodeIfPresent(String.self, forKey: .node)
        priority = try values.decodeIfPresent(Int.self, forKey: .priority)
        senderId = try values.decodeIfPresent(Int.self, forKey: .senderId)
        sentByApi = try values.decodeIfPresent(Int.self, forKey: .sentByApi)
        sentByApp = try values.decodeIfPresent(Int.self, forKey: .sentByApp)
        sentByProvider = try values.decodeIfPresent(Int.self, forKey: .sentByProvider)
        unreadMessages = try values.decodeIfPresent(Int.self, forKey: .unreadMessages)
        updatedAt = try values.decodeIfPresent(Int.self, forKey: .updatedAt)
        workerPerson = try values.decodeIfPresent(String.self, forKey: .workerPerson)
        workerPhoneNumber = try values.decodeIfPresent(String.self, forKey: .workerPhoneNumber)
    }
}

// MARK: An extension to create Customer Object Core Data Entity from CustomerCodable Server Response Data
extension Customer {
    convenience init(context: NSManagedObjectContext, customerEntryFromServer customerEntry: CustomerCodable) {
        self.init(context: context)
        self.lastMessageSeenDate = customerEntry.allLastMessageSeen != nil ? Date.getDateFromString(dateString: customerEntry.allLastMessageSeen!, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.lastMessageText = customerEntry.allLastMessageText
        self.isArchived = customerEntry.archive ?? false
        self.blacklistReason = customerEntry.blacklistReason
        self.colorCode = customerEntry.colour != nil ? Int16(customerEntry.colour!) : 0
        self.customerID = customerEntry.customerId != nil ? Int32(customerEntry.customerId!) : 0
        self.name = customerEntry.customerPerson
        self.phoneNumber = customerEntry.customerPhoneNumber
        self.isCustomerDeleted = customerEntry.deleted ?? false
        self.deliveredByProviderAt = customerEntry.deliveredByProvider != nil ? Date(milliSecondsSince1970: Int64(customerEntry.deliveredByProvider!)) : nil
        self.isBlacklisted = customerEntry.externalConversationBlackList != nil ? customerEntry.externalConversationBlackList!.boolValue : false
        self.externalConversationID = customerEntry.externalConversationId != nil ? Int32(customerEntry.externalConversationId!) : 0
        self.isIncoming = customerEntry.incoming ?? false
        self.addressBookID = customerEntry.internalAddressBookId != nil ? Int32(customerEntry.internalAddressBookId!) : 0
        self.isAddressBookNameActive = customerEntry.internalAddressBookNameActive != nil ? customerEntry.internalAddressBookNameActive!.boolValue : false
        self.addressBookName = customerEntry.internalAddressBookNames
        self.lastMessageDate = customerEntry.lastMessageDate != nil ? Date(timeIntervalSince1970: TimeInterval(customerEntry.lastMessageDate!)) : nil
        self.lastMessageDateTime = customerEntry.lastMessageDatetime != nil ? Date(timeIntervalSince1970: TimeInterval(customerEntry.lastMessageDatetime!)) : nil
        self.lastMessageKey = customerEntry.lastMessageKey
        self.messageType = customerEntry.messageType
        self.node = customerEntry.node
        self.priority = customerEntry.priority != nil ? Int16(customerEntry.priority!) : 0
        self.senderID = customerEntry.senderId != nil ? Int32(customerEntry.senderId!) : 0
        self.sentByApiAt = customerEntry.sentByApi != nil ? Date(milliSecondsSince1970: Int64(customerEntry.sentByApi!)) : nil
        self.sentByAppAt = customerEntry.sentByApp != nil ? Date(milliSecondsSince1970: Int64(customerEntry.sentByApp!)) : nil
        self.sentByProviderAt = customerEntry.sentByProvider != nil ? Date(milliSecondsSince1970: Int64(customerEntry.sentByProvider!)) : nil
        self.unreadMessagesCount = customerEntry.unreadMessages != nil ? Int16(customerEntry.unreadMessages!) : 0
        self.updatedAt = customerEntry.updatedAt != nil ? Date(milliSecondsSince1970: Int64(customerEntry.updatedAt!)) : nil
        self.workerPersonName = customerEntry.workerPerson
        self.workerPhoneNumber = customerEntry.workerPhoneNumber
    }
}


extension Date {
    var milliSecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000).rounded())
    }

    init(milliSecondsSince1970: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliSecondsSince1970 / 1000))
        self.addTimeInterval(TimeInterval(Double(milliSecondsSince1970 % 1000) / 1000 ))
    }
}
