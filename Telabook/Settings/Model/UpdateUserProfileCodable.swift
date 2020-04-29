//
//  UpdateUserProfileCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation

struct UpdateUserProfileCodable : Codable {
    let address : String?
    let birthdate : String?
    let cityId : String?
    let countryId : String?
    let createdAt : String?
    let deletedAt : String?
    let email : String?
    let id : Int?
    let lastName : String?
    let name : String?
    let phoneNumber : String?
    let phonecc : String?
    let profileImage : String?
    let profileImageUrl : String?
    let stateId : String?
    let updatedAt : String?
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case birthdate = "birthdate"
        case cityId = "city_id"
        case countryId = "country_id"
        case createdAt = "created_at"
        case deletedAt = "deleted_at"
        case email = "email"
        case id = "id"
        case lastName = "last_name"
        case name = "name"
        case phoneNumber = "phone_number"
        case phonecc = "phonecc"
        case profileImage = "profile_image"
        case profileImageUrl = "profile_image_url"
        case stateId = "state_id"
        case updatedAt = "updated_at"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        birthdate = try values.decodeIfPresent(String.self, forKey: .birthdate)
        cityId = try values.decodeIfPresent(String.self, forKey: .cityId)
        countryId = try values.decodeIfPresent(String.self, forKey: .countryId)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        deletedAt = try values.decodeIfPresent(String.self, forKey: .deletedAt)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        phonecc = try values.decodeIfPresent(String.self, forKey: .phonecc)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
        stateId = try values.decodeIfPresent(String.self, forKey: .stateId)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}
