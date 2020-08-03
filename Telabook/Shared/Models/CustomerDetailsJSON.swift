//
//  CustomerDetailsJSON.swift
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
     "data": {
         "id": 19,
         "owner_id": 162,
         "customer_id": 24785,
         "names": "Big Boss",
         "surnames": "",
         "created_at": "2020-08-03 06:05:04",
         "updated_at": "2020-08-03 06:05:04",
         "agent_only_name": "Pet Boss",
         "workerId": "164",
         "companyId": "22"
     }
 }
 
 Stores result, message and customer details
*/
struct CustomerDetailsJSON:Decodable {
    private enum RootCodingKeys:String, CodingKey {
        case result, message, data
    }
    
    let result:ServerResult
    let message:String?
    let customerDetails: CustomerDetailsProperties?
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let serverResult = try rootContainer.decode(String.self, forKey: .result)
        result = ServerResult(rawValue: serverResult)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        customerDetails = try rootContainer.decodeIfPresent(CustomerDetailsProperties.self, forKey: .data)
    }
}
struct CustomerDetailsProperties: Decodable {
    let agentOnlyName : String?     // "Pet Boss"
    let companyId : String?         // "22"
    let createdAt : String?         // "2020-08-03 06:05:04"
    let customerId : Int?           // 24785
    let id : Int?                   // 19
    let names : String?             // "Big Boss"  <- This is the Global Name
    let ownerId : Int?              // 162
    let surnames : String?          // ""
    let updatedAt : String?         // "2020-08-03 06:05:04"
    let workerId : String?          // "164"
}
