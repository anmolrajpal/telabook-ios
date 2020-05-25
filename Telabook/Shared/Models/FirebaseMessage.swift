//
//  FirebaseMessage.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseMessage {
    
    let ref: DatabaseReference?
    let firebaseKey: String
    let accountSID:String?
    let messageSID:String?
    let conversationID:Int
    let deleted:Bool
    let hasError:Bool
    let messageText:String?
    let messageImageURL:String?
    let messageType:MessageCategory
    let deliveredByProviderTimestamp:Date?
    let sentByApiTimestamp:Date?
    let sentByAppTimestamp:Date?
    let sentByProviderTimestamp:Date?
    let timestamp: Date?
    let updatedAt:Date?
    let senderIsWorker:Bool
    let tags:String?
    
    
    
    init?(snapshot: DataSnapshot) {
//        print(snapshot)
        guard let value = snapshot.value as? [String: AnyObject] else {
            print("Error: Failed to unwrap snapshot value")
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
        func mapToDouble(value:AnyObject?) -> Double {
            switch value {
                case let value as Double: return value
                case let value as Int: return Double(value)
                case let value as NSNumber: return value.doubleValue
                case let value as String: return Double(value) ?? 0
                default: return 0
            }
        }
        func mapToDate(value:AnyObject?) -> Date? {
            switch value {
                case let value as Int: return .getDate(fromSecondsOrMilliseconds: value)
                case let value as NSNumber: return .getDate(fromSecondsOrMilliseconds: value.intValue)
                case let value as String: return value.dateFromFormattedString
                default: return nil
            }
        }
        func mapToBool(value: AnyObject?) -> Bool {
            switch value {
                case let value as Bool: return value
                case let value as Int: return value.boolValue
                case let value as NSNumber: return value.boolValue
                case let value as String: return value.boolFromPossibleStringValues
                default: return false
            }
        }
        
        
        self.ref = snapshot.ref
        self.firebaseKey = snapshot.key
        
        self.accountSID = value["account_sid"] as? String
        self.messageSID = value["message_sid"] as? String
        self.conversationID = mapToInt(value: value["conversationId"])
        self.deleted = mapToBool(value: value["deleted"])
        self.hasError = mapToBool(value: value["error"])
        self.messageText = value["message"] as? String
        self.messageImageURL = value["img"] as? String
        let type = value["type"] as? String
        self.messageType = type != nil ? MessageCategory(stringValue: type!) : .text
        self.deliveredByProviderTimestamp = mapToDate(value: value["delivered_by_provider"])
        self.sentByApiTimestamp = mapToDate(value: value["sent_by_api"])
        self.sentByAppTimestamp = mapToDate(value: value["sent_by_app"])
        self.sentByProviderTimestamp = mapToDate(value: value["sent_by_provider"])
        self.timestamp = mapToDate(value: value["date"])
        self.updatedAt = mapToDate(value: value["updated_at"])
        self.senderIsWorker = mapToBool(value: value["sender_is_worker"])
        self.tags = value["tags"] as? String
    }
    
    
    
    func toAnyObject() -> Any {
        return [
            
        ]
    }
}
