//
//  FirebaseCustomer.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseCustomer {
    
    let ref: DatabaseReference?
    let key: String
    let allLastMessageSeenDate:String?
    let allLastMessageText: String?
    let isArchived:Int
    let blacklistReason:String?
    let colorCode:Int
    let customerID:Int
    let customerPerson:String?
    let customerPhoneNumber:String?
    let isDeleted:Int
    let deliveredByProvderAt:Int
    let isBlacklisted:Int
    let conversationID:Int
    let isIncoming:Int
    let addressBookID:Int
    let addressBookNameActive:Int
    let addressBookName:String?
    let lastMessageDate:Int
    let lastMessageDateTime:Int
    let lastMessageKey:String?
    let lastMessageType:String
    let node:String
    let priority:Int
    let senderID:Int
    let sentByAPIat:Int
    let sentByAppAt:Int
    let sentByProviderAt:Int
    let unreadMessagesCount:Int
    let updatedAt:Int
    let workerPerson:String?
    let workerPhoneNumber:String?
    
    
    init?(snapshot: DataSnapshot) {
//        print(snapshot)
        guard let key = Int(snapshot.key),
            key > 0,
            let value = snapshot.value as? [String: AnyObject] else {
//            print("Error: Failed to unwrap snapshot value")
            return nil
        }
        
        func mapToInt(value:AnyObject?) -> Int {
            switch value {
                case let value as Int: return value
                case let value as NSNumber: return value.intValue
                case let value as String: return Int(value) ?? 0
                default: return 0
            }
        }
        
        
        
        let all_last_message_seen = value["all_last_message_seen"] as? String
        let all_last_message_text = value["all_last_message_text"] as? String
        let is_archived:Int = value["archive"] as? Int ?? value["archived"] as? Int ?? 0
        let blacklist_reason = value["blacklist_reason"] as? String
        let colour = mapToInt(value: value["colour"])
        let customer_id = mapToInt(value: value["customer_id"])
        let customer_person = value["customer_person"] as? String
        let customer_phone_number = value["customer_phone_number"] as? String
        let is_deleted = mapToInt(value: value["deleted"])
        let delivered_by_provider = mapToInt(value: value["delivered_by_provider"])
        let external_conversation_black_list = mapToInt(value: value["external_conversation_black_list"])
        let external_conversation_id = mapToInt(value: value["external_conversation_id"]) != 0 ? mapToInt(value: value["external_conversation_id"]) : key
        let incoming = mapToInt(value: value["incoming"])
        let internal_address_book_id = mapToInt(value: value["internal_address_book_id"])
        let internal_address_book_name_active = mapToInt(value: value["internal_address_book_name_active"])
        let internal_address_book_names = value["internal_address_book_names"] as? String
        let last_message_date = mapToInt(value: value["last_message_date"])
        let last_message_datetime = mapToInt(value: value["last_message_datetime"])
        let last_message_key = value["last_message_key"] as? String
        let message_type = value["message_type"] as? String ?? MessageCategory.text.rawValue
        let node = value["node"] as? String
        let priority = mapToInt(value: value["priority"])
        let sender_id = mapToInt(value: value["sender_id"])
        let sent_by_api = mapToInt(value: value["sent_by_api"])
        let sent_by_app = mapToInt(value: value["sent_by_app"])
        let sent_by_provider = mapToInt(value: value["sent_by_provider"])
        let unread_messages = mapToInt(value: value["unread_messages"])
        let updated_at = mapToInt(value: value["updated_at"])
        let worker_person = value["worker_person"] as? String
        let worker_phone_number = value["worker_phone_number"] as? String
        
        
        
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        self.allLastMessageSeenDate = all_last_message_seen
        self.allLastMessageText = all_last_message_text
        self.isArchived = is_archived
        self.blacklistReason = blacklist_reason
        self.colorCode = colour
        self.customerID = customer_id
        self.customerPerson = customer_person
        self.customerPhoneNumber = customer_phone_number
        self.isDeleted = is_deleted
        self.deliveredByProvderAt = delivered_by_provider
        self.isBlacklisted = external_conversation_black_list
        self.conversationID = external_conversation_id
        self.isIncoming = incoming
        self.addressBookID = internal_address_book_id
        self.addressBookNameActive = internal_address_book_name_active
        self.addressBookName = internal_address_book_names
        self.lastMessageDate = last_message_date
        self.lastMessageDateTime = last_message_datetime
        self.lastMessageKey = last_message_key
        self.lastMessageType = message_type
        self.node = node ?? ""
        self.priority = priority
        self.senderID = sender_id
        self.sentByAPIat = sent_by_api
        self.sentByAppAt = sent_by_app
        self.sentByProviderAt = sent_by_provider
        self.unreadMessagesCount = unread_messages
        self.updatedAt = updated_at
        self.workerPerson = worker_person
        self.workerPhoneNumber = worker_phone_number
    }
    
    
    init?(snapshot: DataSnapshot, workerID:String) {
//        print(snapshot)
        guard let key = Int(snapshot.key),
            key > 0,
            let value = snapshot.value as? [String: AnyObject] else {
//            print("Error: Failed to unwrap snapshot value")
            return nil
        }
        
    
        let explicitNode = "\(workerID)-\(snapshot.key)-Customer"
        func mapToInt(value:AnyObject?) -> Int {
            switch value {
                case let value as Int: return value
                case let value as NSNumber: return value.intValue
                case let value as String: return Int(value) ?? 0
                default: return 0
            }
        }
        
        
        let all_last_message_seen = value["all_last_message_seen"] as? String
        let all_last_message_text = value["all_last_message_text"] as? String
        let is_archived:Int = value["archive"] as? Int ?? value["archived"] as? Int ?? 0
        let blacklist_reason = value["blacklist_reason"] as? String
        let colour = mapToInt(value: value["colour"])
        let customer_id = mapToInt(value: value["customer_id"])
        let customer_person = value["customer_person"] as? String
        let customer_phone_number = value["customer_phone_number"] as? String
        let is_deleted = mapToInt(value: value["deleted"])
        let delivered_by_provider = mapToInt(value: value["delivered_by_provider"])
        let external_conversation_black_list = mapToInt(value: value["external_conversation_black_list"])
        let external_conversation_id = mapToInt(value: value["external_conversation_id"]) != 0 ? mapToInt(value: value["external_conversation_id"]) : key
        let incoming = mapToInt(value: value["incoming"])
        let internal_address_book_id = mapToInt(value: value["internal_address_book_id"])
        let internal_address_book_name_active = mapToInt(value: value["internal_address_book_name_active"])
        let internal_address_book_names = value["internal_address_book_names"] as? String
        let last_message_date = mapToInt(value: value["last_message_date"])
        let last_message_datetime = mapToInt(value: value["last_message_datetime"])
        let last_message_key = value["last_message_key"] as? String
        let message_type = value["message_type"] as? String ?? MessageCategory.text.rawValue
        let node = value["node"] as? String ?? explicitNode
        let priority = mapToInt(value: value["priority"])
        let sender_id = mapToInt(value: value["sender_id"])
        let sent_by_api = mapToInt(value: value["sent_by_api"])
        let sent_by_app = mapToInt(value: value["sent_by_app"])
        let sent_by_provider = mapToInt(value: value["sent_by_provider"])
        let unread_messages = mapToInt(value: value["unread_messages"])
        let updated_at = mapToInt(value: value["updated_at"])
        let worker_person = value["worker_person"] as? String
        let worker_phone_number = value["worker_phone_number"] as? String
        
        
        
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        self.allLastMessageSeenDate = all_last_message_seen
        self.allLastMessageText = all_last_message_text
        self.isArchived = is_archived
        self.blacklistReason = blacklist_reason
        self.colorCode = colour
        self.customerID = customer_id
        self.customerPerson = customer_person
        self.customerPhoneNumber = customer_phone_number
        self.isDeleted = is_deleted
        self.deliveredByProvderAt = delivered_by_provider
        self.isBlacklisted = external_conversation_black_list
        self.conversationID = external_conversation_id
        self.isIncoming = incoming
        self.addressBookID = internal_address_book_id
        self.addressBookNameActive = internal_address_book_name_active
        self.addressBookName = internal_address_book_names
        self.lastMessageDate = last_message_date
        self.lastMessageDateTime = last_message_datetime
        self.lastMessageKey = last_message_key
        self.lastMessageType = message_type
        self.node = node
        self.priority = priority
        self.senderID = sender_id
        self.sentByAPIat = sent_by_api
        self.sentByAppAt = sent_by_app
        self.sentByProviderAt = sent_by_provider
        self.unreadMessagesCount = unread_messages
        self.updatedAt = updated_at
        self.workerPerson = worker_person
        self.workerPhoneNumber = worker_phone_number
    }
    
}



extension FirebaseCustomer {
    typealias UpdatedConversation = [AnyHashable:Any]
    static func getUpdatedConversationObject(fromLastMessage message:UserMessage) -> UpdatedConversation {
        var dictionary:UpdatedConversation = [
            "unread_messages":0,
            "last_message_key":message.messageId,
            "message_type":message.messageType.rawValue,
            "updated_at":Date().milliSecondsSince1970,
            "sent_by_app":message.sentDate.milliSecondsSince1970,
            "last_message_datetime":message.sentDate.milliSecondsSince1970,
            "sent_by_api":0,
            "sent_by_provider":0
        ]
        if let textMessage = message.textMessage {
            dictionary["all_last_message_text"] = textMessage
        }
        return dictionary
    }
    static func getClearMessagesCountConversationObject(updatedAt:Date) -> UpdatedConversation {
        return  [
            "unread_messages":0,
            "updated_at":updatedAt.milliSecondsSince1970
        ]
    }
}




