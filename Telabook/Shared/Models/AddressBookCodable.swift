//
//  AddressBookCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

struct AddressBookCodable: Decodable {
    
    let message : String?
    let result : String?
    let internalAddressBook:InternalAddressBookProperties?
    let externalAddressBook:ExternalAddressBookProperties?
    
    private enum RootCodingKeys: String, CodingKey {
        case result, message, data
    }
    private enum DataCodingKeys: String, CodingKey {
        case `internal`, external
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        result = try rootContainer.decodeIfPresent(String.self, forKey: .result)
        message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        internalAddressBook = try dataContainer.decodeIfPresent(InternalAddressBookProperties.self, forKey: .internal)
        externalAddressBook = try dataContainer.decodeIfPresent(ExternalAddressBookProperties.self, forKey: .internal)
    }
    
}




struct InternalAddressBookProperties: Decodable {
    let activeName : Int?
    let addressOne : String?
    let addressTwo : String?
    let companyId : Int?
    let createdAt : String?
    let customerId : Int?
    let descriptionField : String?
    let externalConversationId : Int?
    let id : Int?
    let isCustumer : Int?
    let names : String?
    let phone : String?
    let star : Int?
    let surnames : String?
    let updatedAt : String?
    let workerId : Int?
}



struct ExternalAddressBookProperties: Decodable {
    let addressOne : String?
    let addressTwo : String?
    let createdAt : String?
    let customerId : Int?
    let descriptionField : String?
    let id : Int?
    let internalNames : String?
    let makeInternal : Bool?
    let names : String?
    let ownerId : Int?
    let star : Int?
    let surnames : String?
    let updatedAt : String?
}
