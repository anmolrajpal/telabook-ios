//
//  AgentCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 30/04/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData



// MARK: - Decodable

/**
 A struct for decoding JSON with the following structure:

 {
     "result": "success",
     "message": "OK",
     "data": {
         "agents": [
             {
                 "internal_conversation_id": 264,
                 "worker_id": 144,
                 "username": "EstherLuna1559690982",
                 "profile_image_url": "https://firebasestorage.googleapis.com/v0/b/telebookchat.appspot.com/o/profile-image%2F1559770807069?alt=media&token=624e742a-4e08-471e-9e12-807523658cdf",
                 "profile_image": "https://firebasestorage.googleapis.com/v0/b/telebookchat.appspot.com/o/profile-image%2F1559770807069?alt=media&token=624e742a-4e08-471e-9e12-807523658cdf",
                 "role_id": 4,
                 "user_id": 144,
                 "person_name": "Esther Luna",
                 "phone_number": "+18005004240",
                 "did_number": "+17162411222",
                 "internal_node": "143-144-Worker",
                 "internal_last_message_date": "2019-09-06 13:05:52",
                 "internal_last_message_seen": "2019-06-04 23:35:21",
                 "external_pending_messages": 1,
                 "priority1": "1",
                 "priority2": "0",
                 "priority3": "0",
                 "date": 1597230124,
                 "deleted": 0
             }
         ]
     }
 }
 
 Stores current page index and an array of decoded LookupConversationProperties
*/
struct AgentsJSON: Decodable {
    private enum RootCodingKeys:String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys:String, CodingKey {
        case agents
    }
    
    let result:ServerResult
    let message:String?
    var agents = [AgentProperties]()
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        
        var agentsContainer = try dataContainer.nestedUnkeyedContainer(forKey: .agents)
        
        while !agentsContainer.isAtEnd {
            let agent = try agentsContainer.decode(AgentProperties.self)
            agents.append(agent)
        }
    }
}
struct AgentProperties: Decodable {
    let date: Date?                         // 1597230124 => to Date Object
    let deleted: Int?                       // 0
    let didNumber: String?                  // "+17162411222"
    let externalPendingMessages: Int?       // 1
    let internalConversationId: Int?        // 264
    let internalLastMessageDate: Date?      // "2019-09-06 13:05:52" => to Date Object
    let internalLastMessageSeen: Date?      // "2019-06-04 23:35:21" => to Date Object
    let internalNode: String?               // "143-144-Worker"
    let personName: String?                 // "Esther Luna"
    let phoneNumber: String?                // "+18005004240"
    let priority1: String?                  // "1"
    let priority2: String?                  // "0"
    let priority3: String?                  // "0"
    let profileImage: String?               // "profile_img"
    let profileImageUrl: String?            // "https://firebasestorage.googleapis.com/v0/b/telebookchat.appspot.com/o/profile-image.jpg"
    let roleId: Int?                        // 4
    let userId: Int?                        // 144
    let username: String?                   // "EstherLuna1559690982"
    let workerId: Int?                      // 144
}
extension AgentProperties: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(workerId)
    }
    static func == (lhs: AgentProperties, rhs: AgentProperties) -> Bool {
        return lhs.workerId == rhs.workerId
    }
}

extension AgentsJSON {
    static func generateMockAgents() -> [AgentProperties] {
        let decoder = JSONDecoder.apiServiceDecoder
        let mockData = agentsResponseMockData.data(using: .utf8)!
        return try! decoder.decode(AgentsJSON.self, from: mockData).agents
    }
    static func generateRandomMockAgents(limit: Int? = nil) -> [AgentProperties] {
        let sampleAgents = generateMockAgents().shuffled()
        if let limit = limit {
            return Array(sampleAgents.prefix(through: limit))
        } else {
            return sampleAgents
        }
    }
}






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
// Must be modified only when you change core data model
extension Agent {
    convenience init(context:NSManagedObjectContext, agentEntryFromServer agentEntry:AgentCodable, pendingMessagesCount:Int16) {
        self.init(context: context)
        self.date = (agentEntry.date != nil && agentEntry.date != 0) ? Date(timeIntervalSince1970: Double(agentEntry.date!)) : nil
        self.isDisabled = agentEntry.deleted != nil ? agentEntry.deleted!.boolValue : false
        self.didNumber = agentEntry.didNumber
        self.externalPendingMessagesCount = Int16(pendingMessagesCount)
        self.internalConversationID = agentEntry.internalConversationId != nil ? Int32(agentEntry.internalConversationId!) : 0
        self.lastMessageDate = (agentEntry.internalLastMessageDate != nil) ? Date.getDateFromString(dateString: agentEntry.internalLastMessageDate, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.lastMessageSeenDate = (agentEntry.internalLastMessageSeen != nil) ? Date.getDateFromString(dateString: agentEntry.internalLastMessageSeen, dateFormat: "yyyy-MM-dd HH:mm:ss") : nil
        self.internalNode = agentEntry.internalNode
        self.personName = agentEntry.personName
        self.phoneNumber = agentEntry.phoneNumber?.replacingOccurrences(of: "%2b", with: "+")
        self.priority1 = (agentEntry.priority1 != nil) ? Int(agentEntry.priority1 ?? "0")!.boolValue : false
        self.priority2 = (agentEntry.priority1 != nil) ? Int(agentEntry.priority2 ?? "0")!.boolValue : false
        self.priority3 = (agentEntry.priority1 != nil) ? Int(agentEntry.priority3 ?? "0")!.boolValue : false
        self.profileImageName = agentEntry.profileImage
        self.profileImageURL = agentEntry.profileImageUrl != nil ? URL(string: agentEntry.profileImageUrl!) : nil
        self.roleID = agentEntry.roleId != nil ? Int16(agentEntry.roleId!) : 0
        self.userID = agentEntry.userId != nil ? Int32(agentEntry.userId!) : 0
        self.workerID = agentEntry.workerId != nil ? Int32(agentEntry.workerId!) : 0
        self.lastRefreshedAt = Date()
    }
    
    
    
    
    convenience init(context: NSManagedObjectContext, agentEntryFromServer agentEntry: AgentProperties) {
        self.init(context: context)
        self.date = agentEntry.date
        self.isDisabled = agentEntry.deleted != nil ? agentEntry.deleted!.boolValue : false
        self.didNumber = agentEntry.didNumber
//        self.externalPendingMessagesCount = Int16(pendingMessagesCount)
        self.internalConversationID = agentEntry.internalConversationId != nil ? Int32(agentEntry.internalConversationId!) : 0
        self.lastMessageDate = agentEntry.internalLastMessageDate
        self.lastMessageSeenDate = agentEntry.internalLastMessageSeen
        self.internalNode = agentEntry.internalNode
        self.personName = agentEntry.personName
        self.phoneNumber = agentEntry.phoneNumber?.replacingOccurrences(of: "%2b", with: "+")
        self.priority1 = (agentEntry.priority1 != nil) ? Int(agentEntry.priority1 ?? "0")!.boolValue : false
        self.priority2 = (agentEntry.priority1 != nil) ? Int(agentEntry.priority2 ?? "0")!.boolValue : false
        self.priority3 = (agentEntry.priority1 != nil) ? Int(agentEntry.priority3 ?? "0")!.boolValue : false
        self.profileImageName = agentEntry.profileImage
        self.profileImageURL = agentEntry.profileImageUrl != nil ? URL(string: agentEntry.profileImageUrl!) : nil
        self.roleID = agentEntry.roleId != nil ? Int16(agentEntry.roleId!) : 0
        self.userID = agentEntry.userId != nil ? Int32(agentEntry.userId!) : 0
        self.workerID = agentEntry.workerId != nil ? Int32(agentEntry.workerId!) : 0
        self.lastRefreshedAt = Date()
    }
    
}


extension Agent {
    
    func mediaFolder() -> URL {
        let url = AppDelegate.agentGalleryMediaFolder.appendingPathComponent(String(workerID), isDirectory: true)
        // Create it if it doesn’t exist.
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                let errorMessage = "### \(#function): Failed to create agent gallery media folder URL: \(error)"
                printAndLog(message: errorMessage, log: .ui, logType: .error)
            }
        }
        return url
    }
}
