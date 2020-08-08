//
//  CustomerDetailsJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/08/20.
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
    let createdAt : Date?           // "2020-08-03 06:05:04" to Date Object
    let customerId : Int?           // 24785
    let id : Int?                   // 19
    let names : String?             // "Big Boss"  <- This is the Global Name
    let ownerId : Int?              // 162
    let surnames : String?          // ""
    let updatedAt : Date?           // "2020-08-03 06:05:04" to Date Object
    let workerId : String?          // "164"
}


// MARK: - An extension to create CustomerDetails Object Core Data Entity from CustomerDetailsProperties Server Response Data
extension CustomerDetails {
    convenience init?(context: NSManagedObjectContext, customerDetailsEntryFromServer entry: CustomerDetailsProperties, conversationWithCustomer conversation: Customer) {
        self.init(context: context)
        guard let id = entry.id, id != 0 else { return nil }
        self.id = Int64(id)
        self.companyID = Int64(entry.companyId ?? "0") ?? 0
        self.createdAt = entry.createdAt
        self.customerID = Int64(entry.customerId ?? 0)
        self.globalName = entry.names
        self.agentOnlyName = entry.agentOnlyName
        self.ownerID = Int64(entry.ownerId ?? 0)
        self.updatedAt = entry.updatedAt
        self.workerID = Int64(entry.workerId ?? "0") ?? 0
        self.conversation = conversation
    }
}
