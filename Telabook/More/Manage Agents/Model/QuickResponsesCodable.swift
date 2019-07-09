//
//  QuickResponsesCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
struct QuickResponsesCodable : Codable {
    
    let answers : [Answer]?
    
    enum CodingKeys: String, CodingKey {
        case answers = "answers"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        answers = try values.decodeIfPresent([Answer].self, forKey: .answers)
    }
    struct Answer : Codable {
        
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
}
