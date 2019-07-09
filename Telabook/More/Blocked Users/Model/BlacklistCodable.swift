//
//  BlacklistCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
struct BlacklistCodable : Codable {
    
    let descriptionField : String?
    let externalConversationId : Int?
    let id : Int?
    let number : String?
    
    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case externalConversationId = "external_conversation_id"
        case id = "id"
        case number = "number"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        externalConversationId = try values.decodeIfPresent(Int.self, forKey: .externalConversationId)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        number = try values.decodeIfPresent(String.self, forKey: .number)
    }
    
}
