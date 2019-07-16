//
//  CallGroupsCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
struct CallGroupsCodable : Codable {
    
    let groups : [Group]?
    
    enum CodingKeys: String, CodingKey {
        case groups = "groups"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        groups = try values.decodeIfPresent([Group].self, forKey: .groups)
    }
    
    
    struct Group : Codable {
        
        let id : Int?
        let name : String?
        let status : Int?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case status = "status"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
        }
        
    }
}
