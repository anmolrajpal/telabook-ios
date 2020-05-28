//
//  BlacklistJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

/**
 A struct for decoding JSON with the following structure:
 "{
    "result": "success",
    "message": "OK",
    "data": {
        "blacklisted": {
            "current_page": 1,
            "data": [
                {
                    "id": 134,
                    "external_conversation_id": 896,
                    "description": "Holy Moly",
                    "blocked_by": "Abigail Terry Alfreda Mitchell",
                    "number": "+18324101983",
                    "created_at": "2020-05-18 13:50:01",
                    "updated_at": "2020-05-18 13:50:01",
                    "customer_id": 1,
                    "company_id": 8
                }
            ],
            "first_page_url": "https://fornax.aimservices.tech/api/v2/blacklists/list?company_id=8&page=1",
            "from": 1,
            "last_page": 1,
            "last_page_url": "https://fornax.aimservices.tech/api/v2/blacklists/list?company_id=8&page=1",
            "next_page_url": "null",
            "path": "https://fornax.aimservices.tech/api/v2/blacklists/list",
            "per_page": 10,
            "prev_page_url": "null",
            "to": 7,
            "total": 7
        }
    }
 }"
 */
struct BlacklistJSON : Codable {

    let message : String?
    let result : String?
    let resultData : ResultData?
    
    enum CodingKeys: String, CodingKey {
        case resultData = "data"
        case message = "message"
        case result = "result"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        resultData = try values.decodeIfPresent(ResultData.self, forKey: .resultData)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        result = try values.decodeIfPresent(String.self, forKey: .result)
    }
    struct ResultData : Codable {
        
        let blacklistMetaProperties : BlacklistMetaProperties?
        
        enum CodingKeys: String, CodingKey {
            case blacklistMetaProperties = "blacklisted"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            blacklistMetaProperties = try values.decodeIfPresent(BlacklistMetaProperties.self, forKey: .blacklistMetaProperties)
        }
        struct BlacklistMetaProperties : Codable {
            
            let currentPage : Int?
            let blacklistProperties : [BlacklistProperties]?
            let firstPageUrl : String?
            let from : Int?
            let lastPage : Int?
            let lastPageUrl : String?
            let nextPageUrl : String?
            let path : String?
            let perPage : Int?
            let prevPageUrl : String?
            let to : Int?
            let total : Int?
            
            enum CodingKeys: String, CodingKey {
                case currentPage = "current_page"
                case blacklistProperties = "data"
                case firstPageUrl = "first_page_url"
                case from = "from"
                case lastPage = "last_page"
                case lastPageUrl = "last_page_url"
                case nextPageUrl = "next_page_url"
                case path = "path"
                case perPage = "per_page"
                case prevPageUrl = "prev_page_url"
                case to = "to"
                case total = "total"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                currentPage = try values.decodeIfPresent(Int.self, forKey: .currentPage)
                blacklistProperties = try values.decodeIfPresent([BlacklistProperties].self, forKey: .blacklistProperties)
                firstPageUrl = try values.decodeIfPresent(String.self, forKey: .firstPageUrl)
                from = try values.decodeIfPresent(Int.self, forKey: .from)
                lastPage = try values.decodeIfPresent(Int.self, forKey: .lastPage)
                lastPageUrl = try values.decodeIfPresent(String.self, forKey: .lastPageUrl)
                nextPageUrl = try values.decodeIfPresent(String.self, forKey: .nextPageUrl)
                path = try values.decodeIfPresent(String.self, forKey: .path)
                perPage = try values.decodeIfPresent(Int.self, forKey: .perPage)
                prevPageUrl = try values.decodeIfPresent(String.self, forKey: .prevPageUrl)
                to = try values.decodeIfPresent(Int.self, forKey: .to)
                total = try values.decodeIfPresent(Int.self, forKey: .total)
            }
            struct BlacklistProperties : Codable {
                
                let blockedBy : String?
                let companyId : Int?
                let createdAt : String?
                let customerId : Int?
                let descriptionField : String?
                let externalConversationId : Int?
                let id : Int?
                let number : String?
                let updatedAt : String?
                
                enum CodingKeys: String, CodingKey {
                    case blockedBy = "blocked_by"
                    case companyId = "company_id"
                    case createdAt = "created_at"
                    case customerId = "customer_id"
                    case descriptionField = "description"
                    case externalConversationId = "external_conversation_id"
                    case id = "id"
                    case number = "number"
                    case updatedAt = "updated_at"
                }
                
                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    blockedBy = try values.decodeIfPresent(String.self, forKey: .blockedBy)
                    companyId = try values.decodeIfPresent(Int.self, forKey: .companyId)
                    createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
                    customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
                    descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
                    externalConversationId = try values.decodeIfPresent(Int.self, forKey: .externalConversationId)
                    id = try values.decodeIfPresent(Int.self, forKey: .id)
                    number = try values.decodeIfPresent(String.self, forKey: .number)
                    updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
                }
            }
        }
    }
}



extension BlockedUser {
    convenience init(context: NSManagedObjectContext, blockedUserEntryFromServer entry:BlacklistJSON.ResultData.BlacklistMetaProperties.BlacklistProperties) {
        self.init(context: context)
        self.id = entry.id != nil ? Int64(entry.id!) : 0
        self.conversationID = entry.externalConversationId != nil ? Int64(entry.externalConversationId!) : 0
        self.customerID = entry.customerId != nil ? Int64(entry.customerId!) : 0
        self.companyID = entry.companyId != nil ? Int64(entry.companyId!) : 0
        self.blockingReason = entry.descriptionField
        self.blockedBy = entry.blockedBy
        self.phoneNumber = entry.number
        self.createdAt = Date.getDateFromString(dateString: entry.createdAt, dateFormat: "yyyy-MM-dd HH:mm:ss")
        self.updatedAt = Date.getDateFromString(dateString: entry.updatedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")
        self.lastRefreshedAt = Date()
    }
}
