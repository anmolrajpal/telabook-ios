//
//  AutoResponseJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 15/08/20.
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
         "sms_auto_reply": {
             "user_id": "160",
             "sms_replay": "First Time SMS",
             "updated_at": "2020-08-15 08:54:57",
             "created_at": "2020-08-15 08:54:57",
             "id": 26
         }
     }
 }
 
 Stores result, message and customer details
*/
struct AutoResponseJSON:Decodable {
    private enum RootCodingKeys:String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys:String, CodingKey {
        case smsAutoReply // Original coding key is => "sms_auto_reply", but it needs to converted because of new decoder(camel case)
    }
    
    let result:ServerResult
    let message:String?
    let autoResponse: AutoResponseProperties?
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        autoResponse = try dataContainer.decode(AutoResponseProperties.self, forKey: .smsAutoReply)
    }
}
struct AutoResponseProperties: Decodable {
    let createdAt : Date?       // "2020-08-15 08:54:57" => to Date object
    let id : Int?               // 26
    let smsReplay : String?     // "First Time SMS"
    let updatedAt : Date?       // "2020-08-15 08:54:57" => to Date object
    let userId : Int?           // "160"
}


extension AutoResponse {
    convenience init(context: NSManagedObjectContext, autoResponseEntry entry: AutoResponseProperties, agent: Agent, synced:Bool) {
        self.init(context: context)
        updateValues(autoResponseEntry: entry)
        self.lastRefreshedAt = Date()
        self.autoResponseSender = agent
        self.synced = synced
    }
    func updateValues(autoResponseEntry entry: AutoResponseProperties) {
        self.id = entry.id != nil ? Int32(entry.id!) : 0
        self.userID = entry.userId != nil ? Int32(entry.userId!) : 0
        self.smsReply = entry.smsReplay
        self.createdAt = entry.createdAt
        self.createdAt = entry.updatedAt
    }
    var serverObject: AutoResponseProperties {
        return .init(createdAt: createdAt,
                     id: Int(id),
                     smsReplay: smsReply,
                     updatedAt: updatedAt,
                     userId: Int(userID))
    }
}
