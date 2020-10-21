//
//  UserJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/10/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

// MARK: - Decodable

/**
 A struct for decoding JSON with the following structure:

 {
    "result":"success",
    "message":"OK",
    "data":{
       "user":{
          "id":160,
          "worker_id":160,
          "name":"Supa",
          "last_name":"AIM",
          "username":"Developers Account",
          "email":"dev@aimservices.tech",
          "phone":"+1+1+1+12064389068",
          "contact_email":"dev@mailinator.com",
          "address":"Dev Addresss",
          "extension":{
             "number":"112160",
             "password":"$2y$10$3nLBVSdtVnZF3dETvC2h0OHBnlf97Sdh5EpBt646TbEyUUAU1G\/VK",
             "domain":"aquila.aimservices.tech"
          },
          "profile_image":"https:\/\/firebasestorage.googleapis.com\/v0\/b\/telebookchat.appspot.com\/o\/companies%2F13%2Fprofile-images%2FSUPER%20DEVAIM160?alt=media&token=82928209-5658-476c-96ec-0fdd36c480aa",
          "account_verified":0,
          "profile_image_url":"https:\/\/firebasestorage.googleapis.com\/v0\/b\/telebookchat.appspot.com\/o\/companies%2F13%2Fprofile-images%2FSUPER%20DEVAIM160?alt=media&token=82928209-5658-476c-96ec-0fdd36c480aa",
          "company":12,
          "company_name":"The Firm",
          "default_company":{
             "id":12,
             "name":"The Firm",
             "plan_id":null,
             "created_at":"2019-06-04 23:15:51",
             "updated_at":"2020-09-18 21:11:39",
             "account_id":13,
             "logo":null,
             "VAT":"12347",
             "active":false,
             "created_by":142,
             "postcode":"55555",
             "deleted_at":null,
             "renewal":0,
             "deactivate_at":null
          },
          "role":{
             "id":1,
             "name":"Super User",
             "deleted_at":null,
             "created_at":"2017-11-30 18:11:50",
             "updated_at":"2017-11-30 18:11:50"
          },
          "did":null
       },
       "roles":[
          {
             "id":1,
             "name":"Super User"
          }
       ],
       "permissions":[
          {
             "id":10,
             "name":"Blacklist",
             "view":1,
             "create":1,
             "update":1,
             "delete":1
          },
       ]
    }
 }
 
 Stores current page index and an array of decoded LookupConversationProperties
*/



struct UserJSON: Decodable {
    private enum RootCodingKeys: String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys: String, CodingKey {
        case user
    }
    
    let result: ServerResult
    let message: String?
    var userDetails: UserProperties?
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        
        userDetails = try dataContainer.decodeIfPresent(UserProperties.self, forKey: .user)
    }
}




struct UserProperties : Codable {
    let accountVerified: Int?
    let address: String?
    let company: Int?
    let companyName: String?
    let contactEmail: String?
    let defaultCompany: DefaultCompany?
    let did: Did?
    let email: String?
    let `extension`: Extension?
    let id: Int?
    let lastName: String?
    let name: String?
    let phone: String?
    let profileImage: String?
    let profileImageUrl: String?
    let role: Role?
    let username: String?
    let workerId: Int?
    
    
    struct Role: Codable {
        let createdAt: Date?
        let deletedAt: Date?
        let id: Int?
        let name: String?
        let updatedAt: Date?
    }
    struct Extension: Codable {
        let domain: String?
        let number: String?
        let password: String?
    }
    struct DefaultCompany: Codable {
        let accountId: Int?
        let active: Bool?
        let createdAt: Date?
        let createdBy: Int?
        let deactivateAt: Date?
        let deletedAt: Date?
        let id: Int?
        let logo: String?
        let name: String?
        let planId: Int?
        let postcode: String?
        let renewal: Int?
        let updatedAt: Date?
        let vAT: String?
    }
    struct Did: Codable {
        let companyId: Int?
        let createdAt: Date?
        let deletedAt: Date?
        let disconnected: Int?
        let id: Int?
        let number: String?
        let providerId: Int?
        let sid: String?
        let updatedAt: Date?
        let voicemailsTo: String?
    }
}


