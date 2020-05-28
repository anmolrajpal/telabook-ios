//
//  InternalConversation.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
class InternalConversation : NSManagedObject {
    @NSManaged var didNumber : String?
    @NSManaged var externalPendingMessages : Int16
    @NSManaged var internalConversationId : Int16
    @NSManaged var internalLastMessageDate : String?
    @NSManaged var internalLastMessageSeen : String?
    @NSManaged var internalNode : String?
    @NSManaged var personName : String?
    @NSManaged var phoneNumber : String?
    @NSManaged var priority1 : String?
    @NSManaged var priority2 : String?
    @NSManaged var priority3 : String?
    @NSManaged var profileImage : String?
    @NSManaged var profileImageUrl : String?
    @NSManaged var roleId : Int16
    @NSManaged var userId : Int16
    @NSManaged var username : String?
    @NSManaged var workerId : Int16
    @NSManaged var external: NSSet?
    
    func update(conversation:InternalConversation, context:NSManagedObjectContext, internalConversation:InternalConversationsCodable) {
        conversation.setValue(internalConversation.didNumber, forKey: "didNumber")
        conversation.setValue(internalConversation.externalPendingMessages, forKey: "externalPendingMessages")
        conversation.setValue(internalConversation.internalConversationId, forKey: "internalConversationId")
        conversation.setValue(internalConversation.internalLastMessageDate, forKey: "internalLastMessageDate")
        conversation.setValue(internalConversation.internalLastMessageSeen, forKey: "internalLastMessageSeen")
        conversation.setValue(internalConversation.internalNode, forKey: "internalNode")
        conversation.setValue(internalConversation.personName, forKey: "personName")
        conversation.setValue(internalConversation.phoneNumber, forKey: "phoneNumber")
        conversation.setValue(internalConversation.priority1, forKey: "priority1")
        conversation.setValue(internalConversation.priority2, forKey: "priority2")
        conversation.setValue(internalConversation.priority3, forKey: "priority3")
        conversation.setValue(internalConversation.profileImage, forKey: "profileImage")
        conversation.setValue(internalConversation.profileImageUrl, forKey: "profileImageUrl")
        conversation.setValue(internalConversation.roleId, forKey: "roleId")
        conversation.setValue(internalConversation.userId, forKey: "userId")
        conversation.setValue(internalConversation.username, forKey: "username")
        conversation.setValue(internalConversation.workerId, forKey: "workerId")
        do {
            try context.save()
        } catch let error {
            print("Insertion Error: \(error.localizedDescription)")
        }
    }
    static func insert(conversation:NSManagedObject, context:NSManagedObjectContext, internalConversation:InternalConversationsCodable) {
        conversation.setValue(internalConversation.didNumber, forKey: "didNumber")
        conversation.setValue(internalConversation.externalPendingMessages, forKey: "externalPendingMessages")
        conversation.setValue(internalConversation.internalConversationId, forKey: "internalConversationId")
        conversation.setValue(internalConversation.internalLastMessageDate, forKey: "internalLastMessageDate")
        conversation.setValue(internalConversation.internalLastMessageSeen, forKey: "internalLastMessageSeen")
        conversation.setValue(internalConversation.internalNode, forKey: "internalNode")
        conversation.setValue(internalConversation.personName, forKey: "personName")
        conversation.setValue(internalConversation.phoneNumber, forKey: "phoneNumber")
        conversation.setValue(internalConversation.priority1, forKey: "priority1")
        conversation.setValue(internalConversation.priority2, forKey: "priority2")
        conversation.setValue(internalConversation.priority3, forKey: "priority3")
        conversation.setValue(internalConversation.profileImage, forKey: "profileImage")
        conversation.setValue(internalConversation.profileImageUrl, forKey: "profileImageUrl")
        conversation.setValue(internalConversation.roleId, forKey: "roleId")
        conversation.setValue(internalConversation.userId, forKey: "userId")
        conversation.setValue(internalConversation.username, forKey: "username")
        conversation.setValue(internalConversation.workerId, forKey: "workerId")
        //        PersistenceService.shared.saveContext()
        do {
            try context.save()
        } catch let error {
            print("Insertion Error: \(error.localizedDescription)")
        }
    }
}







/*
 class InternalConversation : NSManagedObject, Codable {
 @NSManaged var didNumber : String?
 @NSManaged var externalPendingMessages : Int16
 @NSManaged var internalConversationId : Int16
 @NSManaged var internalLastMessageDate : String?
 @NSManaged var internalLastMessageSeen : String?
 @NSManaged var internalNode : String?
 @NSManaged var personName : String?
 @NSManaged var phoneNumber : String?
 @NSManaged var priority1 : String?
 @NSManaged var priority2 : String?
 @NSManaged var priority3 : String?
 @NSManaged var profileImage : String?
 @NSManaged var profileImageUrl : String?
 @NSManaged var roleId : Int16
 @NSManaged var userId : Int16
 @NSManaged var username : String?
 @NSManaged var workerId : Int16
 @NSManaged var external: NSSet?
 //    @NSManaged var archived: NSSet?
 
 enum CodingKeys: String, CodingKey {
 case didNumber = "did_number"
 case externalPendingMessages = "external_pending_messages"
 case internalConversationId = "internal_conversation_id"
 case internalLastMessageDate = "internal_last_message_date"
 case internalLastMessageSeen = "internal_last_message_seen"
 case internalNode = "internal_node"
 case personName = "person_name"
 case phoneNumber = "phone_number"
 case priority1 = "priority1"
 case priority2 = "priority2"
 case priority3 = "priority3"
 case profileImage = "profile_image"
 case profileImageUrl = "profile_image_url"
 case roleId = "role_id"
 case userId = "user_id"
 case username = "username"
 case workerId = "worker_id"
 }
 
 required convenience init(from decoder: Decoder) throws {
 guard let context = CodingUserInfoKey.context,
 let managedObjectContext = decoder.userInfo[context] as? NSManagedObjectContext,
 let entity = NSEntityDescription.entity(forEntityName: String(describing:InternalConversation.self), in: managedObjectContext) else {
 fatalError("Failed to decode User")
 }
 
 self.init(entity: entity, insertInto: managedObjectContext)
 let values = try decoder.container(keyedBy: CodingKeys.self)
 didNumber = try values.decodeIfPresent(String.self, forKey: .didNumber)
 externalPendingMessages = try values.decodeIfPresent(Int16.self, forKey: .externalPendingMessages) ?? 0
 internalConversationId = try values.decodeIfPresent(Int16.self, forKey: .internalConversationId) ?? 0
 internalLastMessageDate = try values.decodeIfPresent(String.self, forKey: .internalLastMessageDate)
 internalLastMessageSeen = try values.decodeIfPresent(String.self, forKey: .internalLastMessageSeen)
 internalNode = try values.decodeIfPresent(String.self, forKey: .internalNode)
 personName = try values.decodeIfPresent(String.self, forKey: .personName)
 phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
 priority1 = try values.decodeIfPresent(String.self, forKey: .priority1)
 priority2 = try values.decodeIfPresent(String.self, forKey: .priority2)
 priority3 = try values.decodeIfPresent(String.self, forKey: .priority3)
 profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
 profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
 roleId = try values.decodeIfPresent(Int16.self, forKey: .roleId) ?? 0
 userId = try values.decodeIfPresent(Int16.self, forKey: .userId) ?? 0
 username = try values.decodeIfPresent(String.self, forKey: .username)
 workerId = try values.decodeIfPresent(Int16.self, forKey: .workerId) ?? 0
 }
 
 func update(conversation:InternalConversation, context:NSManagedObjectContext) {
 conversation.setValue(conversation.didNumber, forKey: "didNumber")
 conversation.setValue(conversation.externalPendingMessages, forKey: "externalPendingMessages")
 conversation.setValue(conversation.internalConversationId, forKey: "internalConversationId")
 conversation.setValue(conversation.internalLastMessageDate, forKey: "internalLastMessageDate")
 conversation.setValue(conversation.internalLastMessageSeen, forKey: "internalLastMessageSeen")
 conversation.setValue(conversation.internalNode, forKey: "internalNode")
 conversation.setValue(conversation.personName, forKey: "personName")
 conversation.setValue(conversation.phoneNumber, forKey: "phoneNumber")
 conversation.setValue(conversation.priority1, forKey: "priority1")
 conversation.setValue(conversation.priority2, forKey: "priority2")
 conversation.setValue(conversation.priority3, forKey: "priority3")
 conversation.setValue(conversation.profileImage, forKey: "profileImage")
 conversation.setValue(conversation.profileImageUrl, forKey: "profileImageUrl")
 conversation.setValue(conversation.roleId, forKey: "roleId")
 conversation.setValue(conversation.userId, forKey: "userId")
 conversation.setValue(conversation.username, forKey: "username")
 do {
 try context.save()
 } catch let error {
 print("Insertion Error: \(error.localizedDescription)")
 }
 }
 func insert(conversation:InternalConversation, context:NSManagedObjectContext) {
 conversation.setValue(conversation.didNumber, forKey: "didNumber")
 conversation.setValue(conversation.externalPendingMessages, forKey: "externalPendingMessages")
 conversation.setValue(conversation.internalConversationId, forKey: "internalConversationId")
 conversation.setValue(conversation.internalLastMessageDate, forKey: "internalLastMessageDate")
 conversation.setValue(conversation.internalLastMessageSeen, forKey: "internalLastMessageSeen")
 conversation.setValue(conversation.internalNode, forKey: "internalNode")
 conversation.setValue(conversation.personName, forKey: "personName")
 conversation.setValue(conversation.phoneNumber, forKey: "phoneNumber")
 conversation.setValue(conversation.priority1, forKey: "priority1")
 conversation.setValue(conversation.priority2, forKey: "priority2")
 conversation.setValue(conversation.priority3, forKey: "priority3")
 conversation.setValue(conversation.profileImage, forKey: "profileImage")
 conversation.setValue(conversation.profileImageUrl, forKey: "profileImageUrl")
 conversation.setValue(conversation.roleId, forKey: "roleId")
 conversation.setValue(conversation.userId, forKey: "userId")
 conversation.setValue(conversation.username, forKey: "username")
 do {
 try context.save()
 } catch let error {
 print("Insertion Error: \(error.localizedDescription)")
 }
 }
 // MARK: - Encodable
 public func encode(to encoder: Encoder) throws {
 var container = encoder.container(keyedBy: CodingKeys.self)
 try container.encode(didNumber, forKey: .didNumber)
 try container.encode(externalPendingMessages, forKey: .externalPendingMessages)
 try container.encode(internalConversationId, forKey: .internalConversationId)
 try container.encode(internalLastMessageDate, forKey: .internalLastMessageDate)
 try container.encode(internalLastMessageSeen, forKey: .internalLastMessageSeen)
 try container.encode(internalNode, forKey: .internalNode)
 try container.encode(personName, forKey: .personName)
 try container.encode(phoneNumber, forKey: .phoneNumber)
 try container.encode(priority1, forKey: .priority1)
 try container.encode(priority2, forKey: .priority2)
 try container.encode(priority3, forKey: .priority3)
 try container.encode(profileImage, forKey: .profileImage)
 try container.encode(profileImageUrl, forKey: .profileImageUrl)
 try container.encode(roleId, forKey: .roleId)
 try container.encode(userId, forKey: .userId)
 try container.encode(username, forKey: .username)
 try container.encode(workerId, forKey: .workerId)
 }
 
 }
 */
