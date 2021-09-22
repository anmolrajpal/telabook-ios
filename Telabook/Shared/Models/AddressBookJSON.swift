//
//  AddressBookJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import GooglePlaces

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
struct UpdateContactJSONResponse:Decodable {
   private enum RootCodingKeys: String, CodingKey {
      case result, message, data
   }
   
   let result: ServerResult
   let message: String?
   let contact: AddressBookProperties?
   
   init(from decoder: Decoder) throws {
      let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
      let serverResult = try rootContainer.decode(String.self, forKey: .result)
      result = ServerResult(rawValue: serverResult)
      message = try rootContainer.decodeIfPresent(String.self, forKey: .message)
      contact = try rootContainer.decodeIfPresent(AddressBookProperties.self, forKey: .data)
   }
}

struct AddressBookProperties: Codable {
   var address: [Address]?
   var addressBookId: Int?
   var addressBookName: String?
   var companyId: Int?
   var companyName: String?
   var contactConversationId: Int?
   var contactConversationNode: String?
   var contactGlobalName: String?
   var contactId: Int?
   var contactName: String?
   var contactPhoneNumber: String?
   var groupId: Int?
   var groupName: String?
   var priority: Int?
   
   struct Address: Codable {
      var addressName: String?
      var defaultAddress: Bool?
      var mainAddress: MainAddress?
      var secondAddress: String?
      
      struct MainAddress: Codable {
         let addressComponents: [AddressComponent]?
         let adrAddress: String?
         let formattedAddress: String?
         let geometry: Geometry?
         let icon: String?
         let name: String?
         let photos: [Photo]?
         let placeId: String?
         let reference: String?
         let types: [String]?
         let url: String?
         let utcOffset: Int?
         let utcOffsetMinutes: Int?
         let vicinity: String?
         
         struct AddressComponent: Codable {
            let longName: String?
            let shortName: String?
            let types: [String]?
         }
         
         struct Geometry: Codable {
            let location: Location?
            let viewport: Viewport?
            
            struct Location: Codable {
               let lat: Float?
               let lng: Float?
            }
            
            struct Viewport : Codable {
               let east: Float?
               let north: Float?
               let south: Float?
               let west: Float?
            }
         }
         
         struct Photo: Codable {
            let height: Int?
            let htmlAttributions: [String]?
            let width: Int?
         }
      }
   }
}

extension AddressBookProperties.Address.MainAddress {
   init(gmsPlace: GMSPlace) {
      addressComponents = gmsPlace.addressComponents.map({
         $0.map({ .init(components: $0) })
      })
      adrAddress = nil
      formattedAddress = gmsPlace.formattedAddress
      geometry = .init(coordinates: gmsPlace.coordinate, viewportInfo: gmsPlace.viewportInfo)
      icon = nil
      name = gmsPlace.name
      photos = gmsPlace.photos.map({
         $0.map({ .init(photoMetadata: $0) })
      })
      placeId = gmsPlace.placeID
      reference = gmsPlace.placeID
      types = gmsPlace.types
      url = gmsPlace.website?.absoluteString
      utcOffset = gmsPlace.utcOffsetMinutes?.intValue
      utcOffsetMinutes = gmsPlace.utcOffsetMinutes?.intValue
      vicinity = gmsPlace.addressComponents?.first(where: { $0.types.contains("locality") })?.name
   }
}

extension AddressBookProperties.Address.MainAddress.Photo {
   init(photoMetadata: GMSPlacePhotoMetadata) {
      height = photoMetadata.maxSize.height.intValue
      width = photoMetadata.maxSize.width.intValue
      
      if let attributedString = photoMetadata.attributions {
         let nsrange = NSMakeRange(0, (attributedString.string as NSString).length)
         if let data = try? attributedString.data(from: nsrange, documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html]),
            let string = String(data: data, encoding: .utf8),
            let htmlString = string.slice(from: "<a href", to: "</a>") {
            htmlAttributions = [htmlString]
         } else {
            htmlAttributions = []
         }
         /*
          // Below method also works. It's just a matter of choice
         attributedString.enumerateAttributes(in: nsrange, options: .longestEffectiveRangeNotRequired) { attributes,_,_ in
            if let nsUrl = attributes.filter({ $0.key == .link }).compactMap({ $0.value }).first as? NSURL,
                  let absoluteString = nsUrl.absoluteString {
               print("Absolute String: \(absoluteString)")
               
            }
         }
         */
      } else {
         htmlAttributions = []
      }
   }
}

extension AddressBookProperties.Address.MainAddress.AddressComponent {
   init(components: GMSAddressComponent) {
      longName = components.name
      shortName = components.shortName
      types = components.types
   }
}
extension AddressBookProperties.Address.MainAddress.Geometry {
   init(coordinates: CLLocationCoordinate2D, viewportInfo: GMSPlaceViewportInfo?) {
      location = Location(lat: coordinates.latitude.floatValue, lng: coordinates.longitude.floatValue)
      if let viewportInfo = viewportInfo {
      viewport = Viewport(east: viewportInfo.northEast.longitude.floatValue,
                          north: viewportInfo.northEast.latitude.floatValue,
                          south: viewportInfo.southWest.latitude.floatValue,
                          west: viewportInfo.southWest.longitude.floatValue)
      } else {
         viewport = nil
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
   
   var serverObject: AddressBookProperties {
      .init(address: (addresses as! Set<AddressEntity>).map({ $0.serverObject }),
            addressBookId: addressBookId.toInt,
            addressBookName: addressBookName,
            companyId: companyId.toInt,
            companyName: companyName,
            contactConversationId: contactConversationId.toInt,
            contactConversationNode: contactConversationNode,
            contactGlobalName: contactGlobalName,
            contactId: contactId.toInt,
            contactName: contactName,
            contactPhoneNumber: contactPhoneNumber,
            groupId: groupId.toInt,
            groupName: groupName,
            priority: isFavourited.intValue)
   }
}

extension AddressEntity {
   convenience init(context: NSManagedObjectContext, addressProperties properties: AddressBookProperties.Address, contact: AddressBookContact) {
      self.init(context: context)
      updateData(fromAddressProperties: properties, context)
      self.contact = contact
   }
   func updateData(fromAddressProperties entry: AddressBookProperties.Address, _ context: NSManagedObjectContext) {
      self.uuid = UUID()
      self.addressName = entry.addressName
      self.defaultAddress = entry.defaultAddress ?? false
      self.secondAddress = entry.secondAddress
      if let mainAddress = entry.mainAddress {
         self.mainAddress = MainAddressEntity(context: context, mainAddressProperties: mainAddress)
      }
   }
   
   static func fetchRequest(for contact: AddressBookContact) -> NSFetchRequest<AddressEntity> {
      let fetchRequest:NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
      let predicate = NSPredicate(format: "\(#keyPath(AddressEntity.contact)) == %@", contact)
      fetchRequest.predicate = predicate
      return fetchRequest
   }
   
   var serverObject: AddressBookProperties.Address {
      .init(addressName: addressName,
            defaultAddress: defaultAddress,
            mainAddress: mainAddress?.serverObject,
            secondAddress: secondAddress)
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
      self.insert(properties.photos, context: context)
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
   private func insert(_ addressPhotos: [AddressBookProperties.Address.MainAddress.Photo]?, context: NSManagedObjectContext) {
      if let photos = addressPhotos {
         _ = photos.map({
            AddressPhotoEntity(context: context, addressPhotoProperties: $0, mainAddress: self)
         })
      }
   }
   
   var serverObject: AddressBookProperties.Address.MainAddress {
      .init(addressComponents: (addressComponents as! Set<MainAddressComponent>).map({ $0.serverObject }),
            adrAddress: adrAddress,
            formattedAddress: formattedAddress,
            geometry: geometry?.serverObject,
            icon: icon,
            name: name,
            photos: (photos as! Set<AddressPhotoEntity>).map({ $0.serverObject }),
            placeId: placeId,
            reference: reference,
            types: types,
            url: url?.absoluteString,
            utcOffset: utcOffset.toInt,
            utcOffsetMinutes: utcOffsetMinutes.toInt,
            vicinity: vicinity)
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
   
   var serverObject: AddressBookProperties.Address.MainAddress.AddressComponent {
      .init(longName: longName,
            shortName: shortName,
            types: types)
   }
}

extension AddressPhotoEntity {
   convenience init?(context: NSManagedObjectContext, addressPhotoProperties properties: AddressBookProperties.Address.MainAddress.Photo, mainAddress: MainAddressEntity) {
      self.init(context: context)
      updateData(fromAddressPhotoProperties: properties, context, mainAddress: mainAddress)
   }
   func updateData(fromAddressPhotoProperties properties: AddressBookProperties.Address.MainAddress.Photo, _ context: NSManagedObjectContext, mainAddress: MainAddressEntity) {
      self.width = properties.width.toInt64
      self.height = properties.height.toInt64
      self.htmlAttributes = properties.htmlAttributions
      self.mainAddress = mainAddress
   }
   
   var serverObject: AddressBookProperties.Address.MainAddress.Photo {
      .init(height: height.toInt,
            htmlAttributions: htmlAttributes,
            width: width.toInt)
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
   var serverObject: AddressBookProperties.Address.MainAddress.Geometry {
      .init(location: .init(lat: locationLatitude, lng: locationLongitude),
            viewport: .init(east: viewportEast, north: viewportNorth, south: viewportSouth, west: viewportWest))
   }
}
