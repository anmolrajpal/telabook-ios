//
//  AddressBookJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Decodable

/**
 A struct for decoding JSON with the following structure:
 {
 "result": "success",
 "message": "OK",
 "data": [
 {
 "company_id": 1,
 "company_name": "Harold Ulloa's Company",
 "address_book_id": 11,
 "address_book_name": "Lucy",
 "contact_id": 320,
 "contact_conversation_id": 345,
 "contact_conversation_node": "11-320-Customer",
 "contact_phone_number": "+12512314874",
 "contact_name": "Seahawks",
 "address": [
 {
 "address_name": "Lumen",
 "main_address": {
 "url": "https://maps.google.com/?q=Lumen+Ln,+Highland,+NY+12528,+EE.+UU.&ftid=0x89dd1622666eb11f:0xa6411b7e83a1e0b7",
 "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png",
 "name": "Lumen Lane",
 "types": [
 "route"
 ],
 "geometry": {
 "location": {
 "lat": 41.738771,
 "lng": -73.95985499999999
 },
 "viewport": {
 "east": -73.95850601970848,
 "west": -73.9612039802915,
 "north": 41.7401199802915,
 "south": 41.7374220197085
 }
 },
 "place_id": "EiFMdW1lbiBMbiwgSGlnaGxhbmQsIE5ZIDEyNTI4LCBVU0EiLiosChQKEgkfsW5mIhbdiRG34KGDfhtBphIUChIJPwRBMkI93YkRhGUt0HmyS2w",
 "vicinity": "Highland",
 "reference": "EiFMdW1lbiBMbiwgSGlnaGxhbmQsIE5ZIDEyNTI4LCBVU0EiLiosChQKEgkfsW5mIhbdiRG34KGDfhtBphIUChIJPwRBMkI93YkRhGUt0HmyS2w",
 "utc_offset": -240,
 "adr_address": "<span class=\"street-address\">Lumen Ln</span>, <span class=\"locality\">Highland</span>, <span class=\"region\">NY</span> <span class=\"postal-code\">12528</span>, <span class=\"country-name\">EE. UU.</span>",
 "formatted_address": "Lumen Ln, Highland, NY 12528, EE. UU.",
 "html_attributions": [],
 "address_components": [
 {
 "types": [
 "route"
 ],
 "long_name": "Lumen Lane",
 "short_name": "Lumen Ln"
 },
 {
 "types": [
 "locality",
 "political"
 ],
 "long_name": "Highland",
 "short_name": "Highland"
 },
 {
 "types": [
 "administrative_area_level_3",
 "political"
 ],
 "long_name": "Lloyd",
 "short_name": "Lloyd"
 },
 {
 "types": [
 "administrative_area_level_2",
 "political"
 ],
 "long_name": "Ulster County",
 "short_name": "Ulster County"
 },
 {
 "types": [
 "administrative_area_level_1",
 "political"
 ],
 "long_name": "New York",
 "short_name": "NY"
 },
 {
 "types": [
 "country",
 "political"
 ],
 "long_name": "Estados Unidos",
 "short_name": "US"
 },
 {
 "types": [
 "postal_code"
 ],
 "long_name": "12528",
 "short_name": "12528"
 }
 ],
 "utc_offset_minutes": -240
 },
 "second_address": null,
 "default_address": true
 }
 ],
 "contact_global_name": "Seattle",
 "priority": 0,
 "group_id": null,
 "group_name": ""
 }
 ]
 }
 */
struct AddressBookJSON:Decodable {
   private enum RootCodingKeys: String, CodingKey {
      case result, message, data
   }
   
   let result: ServerResult
   let message: String?
   var contacts = [AddressBookProperties]()
   
   init(from decoder: Decoder) throws {
      let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
      let serverResult = try rootContainer.decode(String.self, forKey: .result)
      result = ServerResult(rawValue: serverResult)
      message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
      
      var dataContainer = try rootContainer.nestedUnkeyedContainer(forKey: .data)
      
      while !dataContainer.isAtEnd {
         let contact = try dataContainer.decode(AddressBookProperties.self)
         contacts.append(contact)
      }
   }
}

struct AddressBookProperties: Decodable {
   let address : [Address]?
   let addressBookId : Int?
   let addressBookName : String?
   let companyId : Int?
   let companyName : String?
   let contactConversationId : Int?
   let contactConversationNode : String?
   let contactGlobalName : String?
   let contactId : Int?
   let contactName : String?
   let contactPhoneNumber : String?
   let groupId : Int?
   let groupName : String?
   let priority : Int?
   
   struct Address: Decodable {
      let addressName : String?
      let defaultAddress : Bool?
      let mainAddress : MainAddress?
      let secondAddress : String?
      
      struct MainAddress : Decodable {
         let addressComponents : [AddressComponent]?
         let adrAddress : String?
         let formattedAddress : String?
         let geometry : Geometry?
         let htmlAttributions : [String]?
         let icon : String?
         let name : String?
         let placeId : String?
         let reference : String?
         let types : [String]?
         let url : String?
         let utcOffset : Int?
         let utcOffsetMinutes : Int?
         let vicinity : String?
         
         struct AddressComponent : Codable {
            let longName : String?
            let shortName : String?
            let types : [String]?
         }
         
         struct Geometry : Decodable {
            let location : Location?
            let viewport : Viewport?
            
            struct Location : Decodable {
               let lat : Float?
               let lng : Float?
            }
            
            struct Viewport : Decodable {
               let east : Float?
               let north : Float?
               let south : Float?
               let west : Float?
            }
         }
      }
   }
}

extension AddressBookContact {
   
   convenience init(context: NSManagedObjectContext, addressBookProperties properties: AddressBookProperties, agent: Agent) {
      self.init(context: context)
      guard properties.contactConversationId != 0 else { return }
      updateData(fromAddressBookProperties: properties, context)
      self.agent = agent
   }
   
   func updateData(fromAddressBookProperties entry: AddressBookProperties, _ context: NSManagedObjectContext) {
      self.addressBookId = entry.addressBookId.toInt64
      self.addressBookName = entry.addressBookName
      self.companyId = entry.companyId.toInt64
      self.companyName = entry.companyName
      self.contactConversationId = entry.contactConversationId.toInt64
      self.contactConversationNode = entry.contactConversationNode
      self.contactGlobalName = entry.contactGlobalName
      self.contactId = entry.contactId.toInt64
      self.contactName = entry.contactName
      self.contactPhoneNumber = entry.contactPhoneNumber
      self.firstLetter = getFirstLetter(from: entry.contactName)
      self.groupId = entry.groupId.toInt64
      self.groupName = entry.groupName
      self.isFavourited = entry.priority.boolValue
      self.locallyRefreshedAt = Date()
      self.insert(entry.address, context: context)
      
   }
   private func insert(_ addresses: [AddressBookProperties.Address]?, context: NSManagedObjectContext) {
      if let addresses = addresses {
         _ = addresses.map({
            AddressEntity(context: context, addressProperties: $0, contact: self)
         })
      }
   }
   func getFirstLetter(from contactName: String?) -> String {
      let letter = (contactName ?? "#").uppercased().prefix(1).string
      let alphabet = (Constants.alphabet.uppercased()).map(String.init)
      if alphabet.contains(letter) {
         return letter
      }
      return "#"
   }
//   @objc
//   var firstLetter: String {
//      willAccessValue(forKey: "firstLetter")
//      let letter = contactName!.prefix(1).string.uppercased()
////      let letter = ((self.contactName ?? "#") as NSString).substring(to: 1).uppercased()
//      didAccessValue(forKey: "firstLetter")
//      return letter
//   }
}

extension AddressEntity {
   convenience init?(context: NSManagedObjectContext, addressProperties properties: AddressBookProperties.Address, contact: AddressBookContact) {
      self.init(context: context)
      updateData(fromAddressProperties: properties, context)
      self.contact = contact
   }
   func updateData(fromAddressProperties entry: AddressBookProperties.Address, _ context: NSManagedObjectContext) {
      self.addressName = entry.addressName
      self.defaultAddress = entry.defaultAddress ?? false
      self.secondAddress = entry.secondAddress
      if let mainAddress = entry.mainAddress {
         self.mainAddress = MainAddressEntity(context: context, mainAddressProperties: mainAddress)
      }
   }
}

extension MainAddressEntity {
   convenience init?(context: NSManagedObjectContext, mainAddressProperties properties: AddressBookProperties.Address.MainAddress) {
      self.init(context: context)
      updateData(fromMainAddressProperties: properties, context)
   }
   func updateData(fromMainAddressProperties properties: AddressBookProperties.Address.MainAddress, _ context: NSManagedObjectContext) {
      self.adrAddress = properties.adrAddress
      self.formattedAddress = properties.formattedAddress
      self.icon = properties.icon
      self.name = properties.name
      self.placeId = properties.placeId
      self.reference = properties.reference
      self.types = properties.types
      if let urlString = properties.url,
         let uri = URL(string: urlString) {
         self.url = uri
      }
      self.utcOffset = properties.utcOffset.toInt64
      self.utcOffsetMinutes = properties.utcOffsetMinutes.toInt64
      self.vicinity = properties.vicinity
      
      self.insert(properties.addressComponents, context: context)
      self.insert(properties.geometry, context: context)
   }
   private func insert(_ addressComponents: [AddressBookProperties.Address.MainAddress.AddressComponent]?, context: NSManagedObjectContext) {
      if let components = addressComponents {
         _ = components.map({
            MainAddressComponent(context: context, addressComponentProperties: $0, mainAddress: self)
         })
      }
   }
   private func insert(_ geometryProperties: AddressBookProperties.Address.MainAddress.Geometry?, context: NSManagedObjectContext) {
      if let geometry = geometryProperties {
         self.geometry = GeometryEntity(context: context, geometryProperties: geometry)
      }
   }
}

extension MainAddressComponent {
   convenience init?(context: NSManagedObjectContext, addressComponentProperties properties: AddressBookProperties.Address.MainAddress.AddressComponent, mainAddress: MainAddressEntity) {
      self.init(context: context)
      updateData(fromAddressComponentProperties: properties, context, mainAddress: mainAddress)
   }
   func updateData(fromAddressComponentProperties properties: AddressBookProperties.Address.MainAddress.AddressComponent, _ context: NSManagedObjectContext, mainAddress: MainAddressEntity) {
      self.longName = properties.longName
      self.shortName = properties.shortName
      self.types = properties.types
      self.mainAddress = mainAddress
   }
}

extension GeometryEntity {
   convenience init?(context: NSManagedObjectContext, geometryProperties properties: AddressBookProperties.Address.MainAddress.Geometry) {
      self.init(context: context)
      updateData(fromGeometryProperties: properties, context)
   }
   func updateData(fromGeometryProperties properties: AddressBookProperties.Address.MainAddress.Geometry, _ context: NSManagedObjectContext) {
      self.locationLatitude = properties.location?.lat ?? 0
      self.locationLatitude = properties.location?.lng ?? 0
      self.viewportEast = properties.viewport?.east ?? 0
      self.viewportNorth = properties.viewport?.north ?? 0
      self.viewportSouth = properties.viewport?.south ?? 0
      self.viewportWest = properties.viewport?.west ?? 0
   }
}
