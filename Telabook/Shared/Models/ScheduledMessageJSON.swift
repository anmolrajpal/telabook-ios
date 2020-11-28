//
//  ScheduledMessageJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/06/20.
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
         "schedule_messages": [
             {
               "id" : 6730,
               "workerId" : 95,
               "wait_time" : "2020-01-27 09:02:55",
               "customer" : "Rama Joseph Pierre",
               "worker_phone" : "+15032288760",
               "worker" : "Chanel Haynes",
               "company_id" : 1,
               "wait_timestamp" : 1580137375,
               "created_at" : "2020-01-27T15:02:25.000000Z",
               "text" : "you want to see me. My rates are $500 an hour.",
               "customer_phone" : "+14073946615",
               "status" : 1
             },
         ],
         "schedule_messages_pages": 1
     }
 }
 
 Stores current page index and an array of decoded ScheduledMessageProperties
*/
struct ScheduledMessageJSON:Decodable {
    private enum RootCodingKeys:String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys:String, CodingKey {
        case scheduleMessages, scheduleMessagesPages
    }
    
    let result:ServerResult
    let message:String?
    let page:Int?
    var scheduledMessages = [ScheduledMessageProperties]()
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        
        var scheduledMessagesContainer = try dataContainer.nestedUnkeyedContainer(forKey: .scheduleMessages)
        
        while !scheduledMessagesContainer.isAtEnd {
            let message = try scheduledMessagesContainer.decode(ScheduledMessageProperties.self)
            scheduledMessages.append(message)
        }
        page = try dataContainer.decodeIfPresent(Int.self, forKey: .scheduleMessagesPages)
    }
}
struct ScheduledMessageProperties: Decodable {
    let companyId:Int?          // 13
    let createdAt:Date?         // `"2020-06-26T18:51:30.000000Z"` decoded to `2020-06-26 18:51:30 +0000`
    let customer:String?        // "Rama Joseph Pierre"
    let customerPhone:String?   // "+14073946615"
    let id:Int?                 // 226
    let status:Int?             // 1
    let text:String?            // "This Message should be delivered on 27/06/2020 - 12:22 AM IST"
    let waitTime:Date?          // `"2020-06-26 12:52:00"` decoded to `2020-06-26 07:22:00 +0000` Note: - This seems to be wrong. Use `waitTimestamp` property instead
    let waitTimestamp:Date?     // `1593197520` decoded to `2020-06-26 18:52:00 +0000`
    let worker:String?          // "Esther Luna"
    let workerId:Int?           // 95
    let workerPhone:String?     // "+15032288760"
}







// MARK: - Core Data

extension ScheduledMessage {
    enum DeliveryStatus:Int {
        case pending = 0, delivered
        
        init(rawValue: Int) {
            switch rawValue {
                case 0: self = .pending
                case 1: self = .delivered
                default: fatalError("Unhandled case for delivery status")
            }
        }
        
    }
    convenience init(context: NSManagedObjectContext, newScheduledMessageEntryFromServer entry:ScheduledMessageProperties) {
        self.init(context: context)
        self.id = Int64(entry.id ?? 0)
        self.textMessage = entry.text
        self.workerID = Int64(entry.workerId ?? 0)
        self.workerName = entry.worker
        self.workerPhoneNumber = entry.workerPhone
        self.customerName = entry.customer
        self.customerPhoneNumber = entry.customerPhone
        self.companyID = Int64(entry.companyId ?? 0)
        self.statusValue = Int64(entry.status ?? 0)
        self.deliveryTime = entry.waitTimestamp
        self.createdAt = entry.createdAt
    }
    var deliveryStatus:DeliveryStatus {
        get {
            DeliveryStatus(rawValue: Int(statusValue))
        }
        set {
            statusValue = Int64(newValue.rawValue)
        }
    }
}




/*
struct ScheduledMessageJSON : Codable {
    
    let data : Datum?
    let message : String?
    let result : String?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
        case result = "result"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(Datum.self, forKey: .data)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        result = try values.decodeIfPresent(String.self, forKey: .result)
    }
    struct Datum : Codable {
        
        let scheduledMessages : [ScheduledMessage]?
        let page : Int?
        
        enum CodingKeys: String, CodingKey {
            case scheduledMessages = "schedule_messages"
            case page = "schedule_messages_pages"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            scheduledMessages = try values.decodeIfPresent([ScheduledMessage].self, forKey: .scheduledMessages)
            page = try values.decodeIfPresent(Int.self, forKey: .page)
        }
        struct ScheduledMessage : Codable {
            
            let companyId : Int?
            let createdAt : String?
            let customer : String?
            let id : Int?
            let status : Int?
            let text : String?
            let waitTime : String?
            let waitTimestamp : Int?
            let worker : String?
            
            enum CodingKeys: String, CodingKey {
                case companyId = "company_id"
                case createdAt = "created_at"
                case customer = "customer"
                case id = "id"
                case status = "status"
                case text = "text"
                case waitTime = "wait_time"
                case waitTimestamp = "wait_timestamp"
                case worker = "worker"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                companyId = try values.decodeIfPresent(Int.self, forKey: .companyId)
                createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
                customer = try values.decodeIfPresent(String.self, forKey: .customer)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                status = try values.decodeIfPresent(Int.self, forKey: .status)
                text = try values.decodeIfPresent(String.self, forKey: .text)
                waitTime = try values.decodeIfPresent(String.self, forKey: .waitTime)
                waitTimestamp = try values.decodeIfPresent(Int.self, forKey: .waitTimestamp)
                worker = try values.decodeIfPresent(String.self, forKey: .worker)
            }
        }
    }
}
*/
