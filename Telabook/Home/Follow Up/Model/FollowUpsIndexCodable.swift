//
//  FollowUpsIndexCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
struct FollowUpsIndexCodable : Codable {
    
    let createdAt : String?
    let datesms : String?
    let id : Int?
    let lastName : String?
    let name : String?
    let node : String?
    let phoneNumber : String?
    let priority : Int?
    let senderId : Int?
    let senderType : String?
    let text : String?
    let token : String?
    let updatedAt : String?
    let userId : Int?
    let workerId : Int?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case datesms = "datesms"
        case id = "id"
        case lastName = "last_name"
        case name = "name"
        case node = "node"
        case phoneNumber = "phone_number"
        case priority = "priority"
        case senderId = "sender_id"
        case senderType = "sender_type"
        case text = "text"
        case token = "token"
        case updatedAt = "updated_at"
        case userId = "user_id"
        case workerId = "worker_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        datesms = try values.decodeIfPresent(String.self, forKey: .datesms)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        node = try values.decodeIfPresent(String.self, forKey: .node)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        priority = try values.decodeIfPresent(Int.self, forKey: .priority)
        senderId = try values.decodeIfPresent(Int.self, forKey: .senderId)
        senderType = try values.decodeIfPresent(String.self, forKey: .senderType)
        text = try values.decodeIfPresent(String.self, forKey: .text)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        workerId = try values.decodeIfPresent(Int.self, forKey: .workerId)
    }
}
