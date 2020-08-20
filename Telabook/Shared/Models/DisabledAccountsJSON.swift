//
//  DisabledAccountJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
// MARK: - Decodable

/**
 A struct for decoding JSON with the following structure:

 {
     "result": "success",
     "message": "OK",
     "data": [
         {
             "internal_conversation_id": 267,
             "worker_id": 148,
             "username": "DianaWoodard1559691321",
             "profile_image_url": "null",
             "profile_image": "null",
             "role_id": 4,
             "user_id": 148,
             "person_name": "Diana Woodard",
             "phone_number": "+18005004006",
             "did_number": "null",
             "internal_node": "143-148-Worker",
             "internal_last_message_date": "2019-06-05 15:57:38",
             "internal_last_message_seen": "2019-06-05 15:57:38",
             "external_pending_messages": 1,
             "priority1": "0",
             "priority2": "0",
             "priority3": "0"
         }
     ]
 }
 
 Stores current page index and an array of decoded ScheduledMessageProperties
*/
struct DisabledAccountsJSON:Decodable {
    private enum RootCodingKeys:String, CodingKey {
        case result, message, data
    }
    
    let result:ServerResult
    let message:String?
    var disabledAccounts = [AgentProperties]()
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        
        var dataContainer = try rootContainer.nestedUnkeyedContainer(forKey: .data)
        
        while !dataContainer.isAtEnd {
            let account = try dataContainer.decode(AgentProperties.self)
            disabledAccounts.append(account)
        }
    }
}
/*
struct DisabledAccountProperties: Decodable {
    let didNumber: String?                 // "(+17866344866)"
    let externalPendingMessages: Int?      // 2
    let internalConversationId: Int?       // 267
    let internalLastMessageDate: String?   // "2019-06-05 15:57:38"
    let internalLastMessageSeen: String?   // "2019-06-05 15:57:38"
    let internalNode: String?              // "143-148-Worker"
    let personName: String?                // "Diana Woodard"
    let phoneNumber: String?               // "+18005004006"
    let priority1: String?                 // "0"
    let priority2: String?                 // "0"
    let priority3: String?                 // "0"
    let profileImage: String?              // "img"
    let profileImageUrl: String?           // "www.img.com"
    let roleId: Int?                       // 4
    let userId: Int?                       // 148
    let username: String?                  // "DianaWoodard1559691321"
    let workerId: Int?                     // 148
}
*/
//extension DisabledAccountProperties: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(workerId)
//    }
//    static func == (lhs: DisabledAccountProperties, rhs: DisabledAccountProperties) -> Bool {
//        return lhs.workerId == rhs.workerId
//    }
//}
