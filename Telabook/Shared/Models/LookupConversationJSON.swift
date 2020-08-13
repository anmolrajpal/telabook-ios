//
//  LookupConversationJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

// MARK: - Decodable

/**
 A struct for decoding JSON with the following structure:

 {
     "result": "success",
     "message": "OK",
     "data": {
         "externalCs": [
             {
                 "external_conversation_id": 25791,
                 "sender_id": 164,
                 "sender_name": "Quincy Porter",
                 "company_id": 22,
                 "all_last_message_text": "Yoto",
                 "message_type": "TEXT_ONLY",
                 "last_message_date": 1596913360,
                 "last_message_datetime": 1596913360,
                 "node": "164-24683-Customer",
                 "last_message_key": "-MEEsULZlnPXvj5ECfSy",
                 "customer_id": 24683,
                 "customer_person": "RLT- AIM T100",
                 "customer_phone_number": "+18324101983",
                 "black_list": 0
             }
         ],
         "pages": 1
     }
 }
 
 Stores current page index and an array of decoded LookupConversationProperties
*/
struct LookupConversationJSON:Decodable {
    private enum RootCodingKeys:String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys:String, CodingKey {
        case conversations = "externalCs"
        case currentPageIndex = "pages"
    }
    
    let result:ServerResult
    let message:String?
    let page:Int
    var conversations = [LookupConversationProperties]()
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        
        var conversationsContainer = try dataContainer.nestedUnkeyedContainer(forKey: .conversations)
        
        while !conversationsContainer.isAtEnd {
            let conversation = try conversationsContainer.decode(LookupConversationProperties.self)
            conversations.append(conversation)
        }
        page = try dataContainer.decode(Int.self, forKey: .currentPageIndex)
    }
}
struct LookupConversationProperties: Decodable {
    let allLastMessageText : String?    // "Yoto"
    let blackList : Int?                // 0
    let companyId : Int?                // 22
    let customerId : Int?               // 24683
    let customerPerson : String?        // "RLT- AIM T100"
    let customerPhoneNumber : String?   // "+18324101983"
    let externalConversationId : Int?   // 25791
    let lastMessageDate : Date?         // 1596913360 => to Date object
    let lastMessageDatetime : Date?     // 1596913360 => to Date object
    let lastMessageKey : String?        // "-MEEsULZlnPXvj5ECfSy"
    let messageType : String?           // "TEXT_ONLY"
    let node : String?                  // "164-24683-Customer"
    let senderId : Int?                 // 164
    let senderName : String?            // "Quincy Porter"
}


extension LookupConversationProperties: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(externalConversationId)
    }
    static func == (lhs: LookupConversationProperties, rhs: LookupConversationProperties) -> Bool {
        return lhs.externalConversationId == rhs.externalConversationId
    }
}

