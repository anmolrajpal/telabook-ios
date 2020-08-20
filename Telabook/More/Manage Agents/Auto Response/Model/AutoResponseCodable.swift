//
//  AutoResponseCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

struct AutoResponseCodable : Codable {
    
    let createdAt : String?
    let id : Int?
    let smsReply : String?
    let updatedAt : String?
    let userId : Int?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id = "id"
        case smsReply = "sms_replay"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        smsReply = try values.decodeIfPresent(String.self, forKey: .smsReply)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        let serverUserID = try values.decodeIfPresent(Int?.self, forKey: .userId) ?? values.decodeIfPresent(String?.self, forKey: .userId)
        userId = mapToInteger(value: serverUserID as AnyObject)
    }
}


extension AutoResponse {
    convenience init(context: NSManagedObjectContext, autoResponseEntry entry: AutoResponseCodable, agent: Agent, synced:Bool) {
        self.init(context: context)
        self.id = entry.id != nil ? Int32(entry.id!) : 0
        self.userID = entry.userId != nil ? Int32(entry.userId!) : 0
        self.smsReply = entry.smsReply
        self.createdAt = entry.createdAt != nil ? Date.getDateFromString(dateString: entry.createdAt!, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.createdAt = entry.updatedAt != nil ? Date.getDateFromString(dateString: entry.updatedAt!, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.lastRefreshedAt = Date()
        self.autoResponseSender = agent
        self.synced = synced
    }
}

