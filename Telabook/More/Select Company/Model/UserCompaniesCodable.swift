//
//  UserCompaniesCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
struct UserCompaniesCodable : Codable {
    let automaticPayments : String?
    let contractId : Int?
    let contrat : Int?
    let createdAt : String?
    let id : Int?
    let name : String?
    let owner : String?
    let plan : String?
    let renew : String?
    let status : String?
    
    enum CodingKeys: String, CodingKey {
        case automaticPayments = "automatic_payments"
        case contractId = "contract_id"
        case contrat = "contrat"
        case createdAt = "created_at"
        case id = "id"
        case name = "name"
        case owner = "owner"
        case plan = "plan"
        case renew = "renew"
        case status = "status"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        automaticPayments = try values.decodeIfPresent(String.self, forKey: .automaticPayments)
        contractId = try values.decodeIfPresent(Int.self, forKey: .contractId)
        contrat = try values.decodeIfPresent(Int.self, forKey: .contrat)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        owner = try values.decodeIfPresent(String.self, forKey: .owner)
        plan = try values.decodeIfPresent(String.self, forKey: .plan)
        renew = try values.decodeIfPresent(String.self, forKey: .renew)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}
extension UserCompaniesCodable: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (left: UserCompaniesCodable, right: UserCompaniesCodable) -> Bool {
        left.id == right.id
    }
}
