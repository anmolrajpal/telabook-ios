//
//  AgentCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 30/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData

struct AgentCodable : Codable {
    let date : Int?
    let deleted : Int?
    let didNumber : String?
    let externalPendingMessages : Int?
    let internalConversationId : Int?
    let internalLastMessageDate : String?
    let internalLastMessageSeen : String?
    let internalNode : String?
    let personName : String?
    let phoneNumber : String?
    let priority1 : String?
    let priority2 : String?
    let priority3 : String?
    let profileImage : String?
    let profileImageUrl : String?
    let roleId : Int?
    let userId : Int?
    let username : String?
    let workerId : Int?
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case deleted = "deleted"
        case didNumber = "did_number"
        case externalPendingMessages = "external_pending_messages"
        case internalConversationId = "internal_conversation_id"
        case internalLastMessageDate = "internal_last_message_date"
        case internalLastMessageSeen = "internal_last_message_seen"
        case internalNode = "internal_node"
        case personName = "person_name"
        case phoneNumber = "phone_number"
        case priority1 = "priority1"
        case priority2 = "priority2"
        case priority3 = "priority3"
        case profileImage = "profile_image"
        case profileImageUrl = "profile_image_url"
        case roleId = "role_id"
        case userId = "user_id"
        case username = "username"
        case workerId = "worker_id"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(Int.self, forKey: .date)
        deleted = try values.decodeIfPresent(Int.self, forKey: .deleted)
        didNumber = try values.decodeIfPresent(String.self, forKey: .didNumber)
        externalPendingMessages = try values.decodeIfPresent(Int.self, forKey: .externalPendingMessages)
        internalConversationId = try values.decodeIfPresent(Int.self, forKey: .internalConversationId)
        internalLastMessageDate = try values.decodeIfPresent(String.self, forKey: .internalLastMessageDate)
        internalLastMessageSeen = try values.decodeIfPresent(String.self, forKey: .internalLastMessageSeen)
        internalNode = try values.decodeIfPresent(String.self, forKey: .internalNode)
        personName = try values.decodeIfPresent(String.self, forKey: .personName)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        priority1 = try values.decodeIfPresent(String.self, forKey: .priority1)
        priority2 = try values.decodeIfPresent(String.self, forKey: .priority2)
        priority3 = try values.decodeIfPresent(String.self, forKey: .priority3)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
        roleId = try values.decodeIfPresent(Int.self, forKey: .roleId)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        workerId = try values.decodeIfPresent(Int.self, forKey: .workerId)
    }
}

// MARK: An extension to create Agent Object Core Data Entity from AgentCodable Server Response Data
extension Agent {
    convenience init(context:NSManagedObjectContext, agentEntryFromServer agentEntry:AgentCodable) {
        self.init(context: context)
        self.date = (agentEntry.date != nil && agentEntry.date != 0) ? Date(timeIntervalSince1970: Double(agentEntry.date!)) : nil
        self.isAgentDeleted = agentEntry.deleted != nil ? agentEntry.deleted!.boolValue : false
        self.didNumber = agentEntry.didNumber
        self.externalPendingMessagesCount = agentEntry.externalPendingMessages != nil ? Int16(agentEntry.externalPendingMessages!) : 0
        self.id = agentEntry.internalConversationId != nil ? Int32(agentEntry.internalConversationId!) : 0
        self.lastMessageDate = (agentEntry.internalLastMessageDate != nil) ? Date(timeIntervalSince1970: TimeInterval(agentEntry.internalLastMessageDate!)!) : nil
        self.lastMessageSeenDate = (agentEntry.internalLastMessageSeen != nil) ? Date(timeIntervalSince1970: TimeInterval(agentEntry.internalLastMessageSeen!)!) : nil
        self.internalNode = agentEntry.internalNode
        self.personName = agentEntry.personName
        self.phoneNumber = agentEntry.phoneNumber
        self.priority1 = (agentEntry.priority1 != nil) ? Int16(agentEntry.priority1!) ?? 0 : 0
        self.priority2 = (agentEntry.priority1 != nil) ? Int16(agentEntry.priority2!) ?? 0 : 0
        self.priority3 = (agentEntry.priority1 != nil) ? Int16(agentEntry.priority3!) ?? 0 : 0
        self.profileImageName = agentEntry.profileImage
        self.profileImageURL = agentEntry.profileImageUrl != nil ? URL(string: agentEntry.profileImageUrl!) : nil
        self.roleID = agentEntry.roleId != nil ? Int16(agentEntry.roleId!) : 0
        self.userID = agentEntry.userId != nil ? Int32(agentEntry.userId!) : 0
        self.workerID = agentEntry.workerId != nil ? Int32(agentEntry.workerId!) : 0
    }
}


