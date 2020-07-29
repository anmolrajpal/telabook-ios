//
//  UserMessage+Firebase.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

extension UserMessage {
    func toFirebaseObject() -> Any {
        let time = sentByAppAt!.milliSecondsSince1970
        var dictionary:[String:Any] = [
            "conversationId"   : NSNumber(value: conversationID),
            "type"             : messageType.serverValue,
            "sent_by_app"      : time,
            "updated_at"       : time,
            "date"             : time,
            "sender_is_worker" : isSentByWorker
        ]
        if let forwardedFromNode = forwardedFrom {
            dictionary["forwarded_from_node"] = forwardedFromNode
        }
        if let textMessage = textMessage {
            dictionary["message"] = textMessage
        }
        if let imageUrlString = imageUrlString {
            dictionary["img"] = imageUrlString
            let size = NSNumber(value: mediaSize)
            dictionary["size"] = size
        }
        return dictionary
    }
    
    
    func getDeletedFirebaseObject(updatedAt: Date) -> [AnyHashable:Any] {
        return [
            "deleted"    : 1,
            "updated_at" : updatedAt.milliSecondsSince1970
        ]
    }
    
}
