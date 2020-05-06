//
//  QuickResponseCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData

struct QuickResponseCodable : Codable {
    
    let answer : String?
    let createdAt : String?
    let id : Int?
    let updatedAt : String?
    let userId : Int?
    
    enum CodingKeys: String, CodingKey {
        case answer = "answer"
        case createdAt = "created_at"
        case id = "id"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        answer = try values.decodeIfPresent(String.self, forKey: .answer)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
    }
}



extension QuickResponse {
    convenience init(context:NSManagedObjectContext, quickResponseEntryFromServer entry:QuickResponseCodable, agent:Agent, synced:Bool) {
        self.init(context: context)
        self.id = entry.id != nil ? Int32(entry.id!) : 0
        self.userID = entry.userId != nil ? Int32(entry.userId!) : 0
        self.answer = entry.answer
        self.createdAt = entry.createdAt != nil ? Date.getDateFromString(dateString: entry.createdAt, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.updatedAt = entry.updatedAt != nil ? Date.getDateFromString(dateString: entry.updatedAt, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.lastRefreshedAt = Date()
        self.sender = agent
        self.synced = synced
    }
}
