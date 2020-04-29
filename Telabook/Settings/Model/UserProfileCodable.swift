//
//  UserProfileCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 11/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation

struct UserProfileCodable : Codable {
    
    let dids : [Did]?
    let roles : [Role]?
    let users : [User]?
    
    enum CodingKeys: String, CodingKey {
        case dids = "dids"
        case roles = "roles"
        case users = "users"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dids = try values.decodeIfPresent([Did].self, forKey: .dids)
        roles = try values.decodeIfPresent([Role].self, forKey: .roles)
        users = try values.decodeIfPresent([User].self, forKey: .users)
    }
    
    
    struct User : Codable {
        
        let address : String?
        let backupEmail : String?
        let did : String?
        let didId : Int?
        let email : String?
        let id : Int?
        let lastName : String?
        let name : String?
        let phoneNumber : String?
        let profileImage : String?
        let profileImageUrl : String?
        let role : String?
        let roleId : Int?
        let username : String?
        
        enum CodingKeys: String, CodingKey {
            case address = "address"
            case backupEmail = "backup_email"
            case did = "did"
            case didId = "did_id"
            case email = "email"
            case id = "id"
            case lastName = "last_name"
            case name = "name"
            case phoneNumber = "phone_number"
            case profileImage = "profile_image"
            case profileImageUrl = "profile_image_url"
            case role = "role"
            case roleId = "role_id"
            case username = "username"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            address = try values.decodeIfPresent(String.self, forKey: .address)
            backupEmail = try values.decodeIfPresent(String.self, forKey: .backupEmail)
            did = try values.decodeIfPresent(String.self, forKey: .did)
            didId = try values.decodeIfPresent(Int.self, forKey: .didId)
            email = try values.decodeIfPresent(String.self, forKey: .email)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
            profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
            profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
            role = try values.decodeIfPresent(String.self, forKey: .role)
            roleId = try values.decodeIfPresent(Int.self, forKey: .roleId)
            username = try values.decodeIfPresent(String.self, forKey: .username)
        }
        
    }
    
    
    
    struct Role : Codable {
        
        let id : Int?
        let name : String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
        }
        
    }
    
    
    struct Did : Codable {
        
        let id : Int?
        let number : String?
        let provider : Int?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case number = "number"
            case provider = "provider"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            number = try values.decodeIfPresent(String.self, forKey: .number)
            provider = try values.decodeIfPresent(Int.self, forKey: .provider)
        }
        
    }
}



