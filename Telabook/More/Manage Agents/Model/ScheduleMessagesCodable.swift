//
//  ScheduleMessagesCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation

struct ScheduleMessagesCodable : Codable {
    
    let scheduleMessages : [ScheduleMessage]?
    let scheduleMessagesPages : Int?
    
    enum CodingKeys: String, CodingKey {
        case scheduleMessages = "schedule_messages"
        case scheduleMessagesPages = "schedule_messages_pages"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scheduleMessages = try values.decodeIfPresent([ScheduleMessage].self, forKey: .scheduleMessages)
        scheduleMessagesPages = try values.decodeIfPresent(Int.self, forKey: .scheduleMessagesPages)
    }
    struct ScheduleMessage : Codable {
        
        let customer : String?
        let id : Int?
        let status : Int?
        let text : String?
        let waitTime : String?
        let worker : String?
        
        enum CodingKeys: String, CodingKey {
            case customer = "customer"
            case id = "id"
            case status = "status"
            case text = "text"
            case waitTime = "wait_time"
            case worker = "worker"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            customer = try values.decodeIfPresent(String.self, forKey: .customer)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            text = try values.decodeIfPresent(String.self, forKey: .text)
            waitTime = try values.decodeIfPresent(String.self, forKey: .waitTime)
            worker = try values.decodeIfPresent(String.self, forKey: .worker)
        }
        
    }
}
