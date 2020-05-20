//
//  NewConversationCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation

struct NewConversationJSON: Codable {
    let result:String?
    let message:String?
    let conversation:NewConversationProperties?
    private enum CodingKeys: String, CodingKey {
        case result, message, conversation = "data"
    }
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        result = try rootContainer.decodeIfPresent(String.self, forKey: .result)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        conversation = try rootContainer.decodeIfPresent(NewConversationProperties.self, forKey: .conversation)
    }
}


struct NewConversationProperties: Codable {
    let externalConversationId : Int?
    let node : String?
    let recipientNumber : String?
    let recipientPerson : String?
    let senderNumber : String?
    let senderPerson : String?
    
    private enum CodingKeys: String, CodingKey {
        case externalConversationId = "external_conversation_id"
        case node = "node"
        case recipientNumber = "recipient_number"
        case recipientPerson = "recipient_person"
        case senderNumber = "sender_number"
        case senderPerson = "sender_person"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        externalConversationId = try values.decodeIfPresent(Int.self, forKey: .externalConversationId)
        node = try values.decodeIfPresent(String.self, forKey: .node)
        recipientNumber = try values.decodeIfPresent(String.self, forKey: .recipientNumber)
        recipientPerson = try values.decodeIfPresent(String.self, forKey: .recipientPerson)
        senderNumber = try values.decodeIfPresent(String.self, forKey: .senderNumber)
        senderPerson = try values.decodeIfPresent(String.self, forKey: .senderPerson)
    }
}
