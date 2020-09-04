//
//  AgentCallsJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/08/20.
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
    "data":  {
        "results": [
             {
                 "_id": "5e8617a171e33d669e04c609",
                 "company_id": 13,
                 "company_name": "Charlie's",
                 "company_owner_id": 142,
                 "company_owner_name": "Rob Boss",
                 "customer_cid": "+11585729965",
                 "customer_id": 688,
                 "customer_name": "",
                 "worker_did": "+17162411222",
                 "worker_id": 144,
                 "worker_name": "Esther Luna",
                 "worker_cid": "+18005004240",
                 "direction": "INBOUND",
                 "uniqueid": "15845757543",
                 "recordingfile": "https://file-examples.com/wp-content/uploads/2017/11/file_example_WAV_1MG.wav",
                 "duration": "9",
                 "status": "ANSWERED",
                 "date": "20-04-01 16:40:18",
                 "timestamp_date": 1585759218,
                 "human_date": "April 1st 2020, 4:40:18 pm",
                 "updated_at": "2020-04-02 10:49:37",
                 "created_at": "2020-04-02 10:49:37"
             }
         ],
         "offset": 0,
         "limit": 25
     }
 }
 
 Stores current page index and an array of decoded LookupConversationProperties
*/
struct AgentCallsJSON:Decodable {
    private enum RootCodingKeys: String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys: String, CodingKey {
        case results, offset, limit
    }
    
    let result: ServerResult
    let message: String?
    let offset: Int
    let limit: Int
    var agentCalls = [AgentCallProperties]()
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        
        var agentCallsContainer = try dataContainer.nestedUnkeyedContainer(forKey: .results)
        
        while !agentCallsContainer.isAtEnd {
            let agentCall = try agentCallsContainer.decode(AgentCallProperties.self)
            agentCalls.append(agentCall)
        }
        offset = try dataContainer.decode(Int.self, forKey: .offset)
        limit = try dataContainer.decode(Int.self, forKey: .limit)
    }
}

struct AgentCallProperties: Decodable {
    let _id: String?                // "5e8617a171e33d669e04c609"
    let companyId: Int?             // 13
    let companyName: String?        // "Charlie's"
    let companyOwnerId: Int?        // 142
    let companyOwnerName: String?   // "Rob Boss"
    let createdAt: Date?            // "2020-04-02 10:49:37" => to Date object
    let customerCid: String?        // "+11585729965"
    let customerId: Int?            // 688
    let customerName: String?       // "Someone"
    let date: Date?                 // "20-04-01 16:40:18" => to Date object
    let direction: String?          // "INBOUND"
    let duration: String?           // "9"
    let humanDate: String?          // "April 1st 2020, 4:40:18 pm"
    let recordingfile: String?      // "https://file-examples.com/wp-content/uploads/2017/11/file_example_WAV_1MG.wav"
    let status: String?             // "ANSWERED"
    let timestampDate: Date?        // 1585759218 => to Date object
    let uniqueid: String?           // "15845757543"
    let updatedAt: Date?            // "2020-04-02 10:49:37" => to Date object
    let workerCid: String?          // "+18005004240"
    let workerDid: String?          // "+17162411222"
    let workerId: Int?              // 144
    let workerName: String?         // "Esther Luna"
}
extension AgentCallProperties {
    var callStatus: AgentCall.CallStatus {
        guard let status = status else {
            fatalError("Call Status is nil")
        }
        return .init(status)
    }
    var callDirection: AgentCall.CallDirection {
        guard let direction = direction else {
            fatalError("Call Direction is nil")
        }
        return .init(direction)
    }
}

extension AgentCallProperties: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
    static func == (lhs: AgentCallProperties, rhs: AgentCallProperties) -> Bool {
        return lhs._id == rhs._id
    }
}
extension AgentCallsJSON {
    static func generateMockAgentCalls() -> [AgentCallProperties] {
        let decoder = JSONDecoder.apiServiceDecoder
        let mockData = agentCallsMockData.data(using: .utf8)!
        return try! decoder.decode(AgentCallsJSON.self, from: mockData).agentCalls
    }
    static func generateRandomMockAgentCalls(limit: Int? = nil) -> [AgentCallProperties] {
        let sampleCalls = generateMockAgentCalls().shuffled()
        if let limit = limit {
            return Array(sampleCalls.prefix(through: limit))
        } else {
            return sampleCalls
        }
    }
}


// MARK: - An extension to create AgentCall Object Core Data Entity from AgentCallProperties JSON Server Response Data

extension AgentCall {
    
    convenience init?(context: NSManagedObjectContext, agentCallEntryFromServer entry: AgentCallProperties, agent: Agent) {
        self.init(context: context)
        guard let id = entry._id, !id.isBlank,
            entry.direction?.isBlank == false,
            entry.status?.isBlank == false
            else { return nil }
        updateData(fromAgentCallEntryFromServer: entry)
        self.worker = agent
    }
    
    func updateData(fromAgentCallEntryFromServer entry: AgentCallProperties) {
        self.id = entry._id
        self.companyID = Int64(entry.companyId ?? 0)
        self.companyName = entry.companyName
        self.companyOwnerID = Int64(entry.companyOwnerId ?? 0)
        self.companyOwnerName = entry.companyOwnerName
        self.createdAt = entry.createdAt
        self.customerCallerID = entry.customerCid
        self.customerID = Int64(entry.customerId ?? 0)
        self.customerName = entry.customerName
        self.callDirection = .init(entry.direction!)
        self.duration = Int64(entry.duration ?? "0") ?? 0
        if let urlString = entry.recordingfile,
            let url = URL(string: urlString) {
            self.recordingFileURL = url
        }
        self.callStatus = .init(entry.status!)
        self.timestamp = entry.timestampDate
        self.uniqueID = entry.uniqueid
        self.updatedAt = entry.updatedAt
        self.workerCallerID = entry.workerCid
        self.workerDID = entry.workerDid
        self.workerID = Int64(entry.workerId ?? 0)
        self.workerName = entry.workerName
    }
    
    var callStatus: CallStatus {
        get {
            .init(status ?? "")
        }
        set {
            status = newValue.rawValue.uppercased()
        }
    }
    var callDirection: CallDirection {
        get {
            .init(direction ?? "")
        }
        set {
            direction = newValue.rawValue.uppercased()
        }
    }
    
    
    
    enum CallStatus: String {
        case answered, unanswered
        
        init(_ rawValue: String) {
            switch rawValue {
                case CallStatus.answered.rawValue.uppercased(): self = .answered
                case CallStatus.unanswered.rawValue.uppercased(), "UNASWERED": self = .unanswered
                default:
                    let message = rawValue == "" ? "Call Status not initialized yet" : "Call Status Unhandled Case: \(rawValue)"
                    fatalError(message)
            }
        }
    }
    enum CallDirection: String {
        case inbound, outbound
        
        init(_ rawValue: String) {
            switch rawValue {
                case CallDirection.inbound.rawValue.uppercased(): self = .inbound
                case CallDirection.outbound.rawValue.uppercased(): self = .outbound
                default:
                    let message = rawValue == "" ? "Call Direction not initialized yet" : "Call Direction Unhandled Case: \(rawValue)"
                    fatalError(message)
            }
        }
    }
}
