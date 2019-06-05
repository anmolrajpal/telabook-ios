//
//  Codable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation

import CoreData
struct UnarchiveConversationCodable : Codable {
    
    let archive : Bool?
    let blackList : Int?
    let colour : Int?
    let createdAt : String?
    let customName : String?
    let id : Int?
    let lastMessageDate : String?
    let lastMessageSeen : String?
    let lastMessageText : String?
    let messageType : String?
    let multimediaExtension : String?
    let noArchiveDate : NoArchiveDate?
    let node : String?
    let priority : String?
    let recipientId : Int?
    let recipientName : String?
    let recipientPhoneNumber : String?
    let sender : Sender?
    let senderDidNumber : String?
    let senderId : Int?
    let senderName : String?
    let senderPhoneNumber : String?
    let unreadMessage : Int?
    let updatedAt : String?
    
    enum CodingKeys: String, CodingKey {
        case archive = "archive"
        case blackList = "black_list"
        case colour = "colour"
        case createdAt = "created_at"
        case customName = "custom_name"
        case id = "id"
        case lastMessageDate = "last_message_date"
        case lastMessageSeen = "last_message_seen"
        case lastMessageText = "last_message_text"
        case messageType = "message_type"
        case multimediaExtension = "multimedia_extension"
        case noArchiveDate = "no_archive_date"
        case node = "node"
        case priority = "priority"
        case recipientId = "recipient_id"
        case recipientName = "recipient_name"
        case recipientPhoneNumber = "recipient_phone_number"
        case sender = "sender"
        case senderDidNumber = "sender_did_number"
        case senderId = "sender_id"
        case senderName = "sender_name"
        case senderPhoneNumber = "sender_phone_number"
        case unreadMessage = "unread_message"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        archive = try values.decodeIfPresent(Bool.self, forKey: .archive)
        blackList = try values.decodeIfPresent(Int.self, forKey: .blackList)
        colour = try values.decodeIfPresent(Int.self, forKey: .colour)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        customName = try values.decodeIfPresent(String.self, forKey: .customName)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        lastMessageDate = try values.decodeIfPresent(String.self, forKey: .lastMessageDate)
        lastMessageSeen = try values.decodeIfPresent(String.self, forKey: .lastMessageSeen)
        lastMessageText = try values.decodeIfPresent(String.self, forKey: .lastMessageText)
        messageType = try values.decodeIfPresent(String.self, forKey: .messageType)
        multimediaExtension = try values.decodeIfPresent(String.self, forKey: .multimediaExtension)
        noArchiveDate = try values.decodeIfPresent(NoArchiveDate.self, forKey: .noArchiveDate)
        node = try values.decodeIfPresent(String.self, forKey: .node)
        priority = try values.decodeIfPresent(String.self, forKey: .priority)
        recipientId = try values.decodeIfPresent(Int.self, forKey: .recipientId)
        recipientName = try values.decodeIfPresent(String.self, forKey: .recipientName)
        recipientPhoneNumber = try values.decodeIfPresent(String.self, forKey: .recipientPhoneNumber)
        sender = try values.decodeIfPresent(Sender.self, forKey: .sender)
        senderDidNumber = try values.decodeIfPresent(String.self, forKey: .senderDidNumber)
        senderId = try values.decodeIfPresent(Int.self, forKey: .senderId)
        senderName = try values.decodeIfPresent(String.self, forKey: .senderName)
        senderPhoneNumber = try values.decodeIfPresent(String.self, forKey: .senderPhoneNumber)
        unreadMessage = try values.decodeIfPresent(Int.self, forKey: .unreadMessage)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    struct Sender : Codable {
        
        let companyId : Int?
        let createdAt : String?
        let deletedAt : String?
        let didId : Int?
        let extensionId : String?
        let id : Int?
        let personId : Int?
        let status : Int?
        let timer : Int?
        let updatedAt : String?
        
        enum CodingKeys: String, CodingKey {
            case companyId = "company_id"
            case createdAt = "created_at"
            case deletedAt = "deleted_at"
            case didId = "did_id"
            case extensionId = "extension_id"
            case id = "id"
            case personId = "person_id"
            case status = "status"
            case timer = "timer"
            case updatedAt = "updated_at"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            companyId = try values.decodeIfPresent(Int.self, forKey: .companyId)
            createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
            deletedAt = try values.decodeIfPresent(String.self, forKey: .deletedAt)
            didId = try values.decodeIfPresent(Int.self, forKey: .didId)
            extensionId = try values.decodeIfPresent(String.self, forKey: .extensionId)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            personId = try values.decodeIfPresent(Int.self, forKey: .personId)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            timer = try values.decodeIfPresent(Int.self, forKey: .timer)
            updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        }
        
    }
    struct NoArchiveDate : Codable {
        
        let date : String?
        let timezone : String?
        let timezoneType : Int?
        
        enum CodingKeys: String, CodingKey {
            case date = "date"
            case timezone = "timezone"
            case timezoneType = "timezone_type"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            date = try values.decodeIfPresent(String.self, forKey: .date)
            timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
            timezoneType = try values.decodeIfPresent(Int.self, forKey: .timezoneType)
        }
        
    }
    
}
class UserInfo:NSManagedObject, Codable {

    @NSManaged var user : User?
//    @NSManaged var permissions : [Permission]?
//    @NSManaged var roles : [Role]?
    enum CodingKeys: String, CodingKey {
        case permissions = "permissions"
        case roles = "roles"
        case user = "user"
    }

    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
//        permissions = try values.decodeIfPresent([Permission].self, forKey: .permissions)
//        roles = try values.decodeIfPresent([Role].self, forKey: .roles)
        user = try values.decodeIfPresent(User.self, forKey: .user)
    }
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
//        try container.encode(username, forKey: .username)
//        try container.encode(role, forKey: .role)
    }

    





}


public class User : NSManagedObject, Codable {
    
    @NSManaged var email : String?
    @NSManaged var id : Int16
    @NSManaged var lastName : String?
    @NSManaged var name : String?
    @NSManaged var phone : String?
    @NSManaged var profileImage : String?
    @NSManaged var profileImageUrl : String?
    @NSManaged var username : String?
    @NSManaged var workerId : Int16
    @NSManaged var `extension` : String?
    @NSManaged var company : Int16
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case id = "id"
        case lastName = "last_name"
        case name = "name"
        case phone = "phone"
        case profileImage = "profile_image"
        case profileImageUrl = "profile_image_url"
        case username = "username"
        case workerId = "worker_id"
        case company = "company"
        case `extension` = "extension"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
        id = try values.decodeIfPresent(Int16.self, forKey: .id) ?? 0
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        
        username = try values.decodeIfPresent(String.self, forKey: .username)
        workerId = try values.decodeIfPresent(Int16.self, forKey: .workerId) ?? 0
        `extension` = try values.decodeIfPresent(String.self, forKey: .`extension`)
        company = try values.decodeIfPresent(Int16.self, forKey: .company) ?? 0
    }
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(username, forKey: .username)
        try container.encode(phone, forKey: .phone)
        try container.encode(`extension`, forKey: .`extension`)
        try container.encode(profileImage, forKey: .profileImage)
        try container.encode(profileImageUrl, forKey: .profileImageUrl)
        try container.encode(company, forKey: .company)
        try container.encode(workerId, forKey: .workerId)
    }
    
}
public class Permission : NSManagedObject, Codable {
    
    @NSManaged var create : Int16
    @NSManaged var delete : Int16
    @NSManaged var id : Int16
    @NSManaged var name : String?
    @NSManaged var update : Int16
    @NSManaged var view : Int16
    
    enum CodingKeys: String, CodingKey {
        case create = "create"
        case delete = "delete"
        case id = "id"
        case name = "name"
        case update = "update"
        case view = "view"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Permission", in: managedObjectContext) else {
                fatalError("Failed to decode Permissions")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int16.self, forKey: .id) ?? 0
        create = try values.decodeIfPresent(Int16.self, forKey: .create) ?? 0
        delete = try values.decodeIfPresent(Int16.self, forKey: .delete) ?? 0
        
        name = try values.decodeIfPresent(String.self, forKey: .name)
        update = try values.decodeIfPresent(Int16.self, forKey: .update) ?? 0
        view = try values.decodeIfPresent(Int16.self, forKey: .view) ?? 0
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(view, forKey: .view)
        try container.encode(create, forKey: .create)
        try container.encode(update, forKey: .update)
        try container.encode(delete, forKey: .delete)
    }
}





struct UserInfoCodable : Codable {
    
    let permissions : [Permission]?
    let roles : [Role]?
    let user : User?
    
    enum CodingKeys: String, CodingKey {
        case permissions = "permissions"
        case roles = "roles"
        case user = "user"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        permissions = try values.decodeIfPresent([Permission].self, forKey: .permissions)
        roles = try values.decodeIfPresent([Role].self, forKey: .roles)
        user = try values.decodeIfPresent(User.self, forKey: .user)
    }
    struct User : Codable {
        
        let email : String?
        let id : Int?
        let lastName : String?
        let name : String?
        let phone : String?
        let profileImage : String?
        let profileImageUrl : String?
        let username : String?
        let workerId : Int?
        let `extension` : String?
        let company : Int?
        
        enum CodingKeys: String, CodingKey {
            case email = "email"
            case id = "id"
            case lastName = "last_name"
            case name = "name"
            case phone = "phone"
            case profileImage = "profile_image"
            case profileImageUrl = "profile_image_url"
            case username = "username"
            case workerId = "worker_id"
            case company = "company"
            case `extension` = "extension"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            email = try values.decodeIfPresent(String.self, forKey: .email)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            phone = try values.decodeIfPresent(String.self, forKey: .phone)
            profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
            profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
            username = try values.decodeIfPresent(String.self, forKey: .username)
            workerId = try values.decodeIfPresent(Int.self, forKey: .workerId)
            `extension` = try values.decodeIfPresent(String.self, forKey: .`extension`)
            company = try values.decodeIfPresent(Int.self, forKey: .company)
        }
        
    }
    struct Role : Codable {
        
        let id : Int?
        let name : String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
        }
        
    }
    struct Permission : Codable {
        
        let create : Int?
        let delete : Int?
        let id : Int?
        let name : String?
        let update : Int?
        let view : Int?
        
        enum CodingKeys: String, CodingKey {
            case create = "create"
            case delete = "delete"
            case id = "id"
            case name = "name"
            case update = "update"
            case view = "view"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            create = try values.decodeIfPresent(Int.self, forKey: .create)
            delete = try values.decodeIfPresent(Int.self, forKey: .delete)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            update = try values.decodeIfPresent(Int.self, forKey: .update)
            view = try values.decodeIfPresent(Int.self, forKey: .view)
        }
        
    }

}
struct InternalConversationsCodable : Codable {
    
    let didNumber : String?
    let externalPendingMessages : Int?
    let internalConversationId : Int?
    let internalLastMessageDate : String?
    let internalLastMessageSeen : String?
    let internalNode : String?
    let personName : String?
    let phoneNumber : String?
    let priority1 : String?
    let priority2 : String?
    let priority3 : String?
    let profileImage : String?
    let profileImageUrl : String?
    let roleId : Int?
    let userId : Int?
    let username : String?
    let workerId : Int?
    
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        didNumber = try values.decodeIfPresent(String.self, forKey: .didNumber)
        externalPendingMessages = try values.decodeIfPresent(Int.self, forKey: .externalPendingMessages)
        internalConversationId = try values.decodeIfPresent(Int.self, forKey: .internalConversationId)
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
        roleId = try values.decodeIfPresent(Int.self, forKey: .roleId)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        workerId = try values.decodeIfPresent(Int.self, forKey: .workerId)
    }
    
}
struct ExternalConversationsCodable : Codable {
    
    let allLastMessageSeen : String?
    let allLastMessageText : String?
    let colour : Int?
    let customerId : Int?
    let customerPerson : String?
    let customerPhoneNumber : String?
    let externalConversationBlackList : Int?
    let externalConversationId : Int?
    let internalAddressBookId : Int?
    let internalAddressBookNameActive : Int?
    let internalAddressBookNames : String?
    let lastMessageDatetime : Int?
    let node : String?
    let priority : Int?
    let unreadMessages : Int?
    let workerPerson : String?
    let workerPhoneNumber : String?
    
    enum CodingKeys: String, CodingKey {
        case allLastMessageSeen = "all_last_message_seen"
        case allLastMessageText = "all_last_message_text"
        case colour = "colour"
        case customerId = "customer_id"
        case customerPerson = "customer_person"
        case customerPhoneNumber = "customer_phone_number"
        case externalConversationBlackList = "external_conversation_black_list"
        case externalConversationId = "external_conversation_id"
        case internalAddressBookId = "internal_address_book_id"
        case internalAddressBookNameActive = "internal_address_book_name_active"
        case internalAddressBookNames = "internal_address_book_names"
        case lastMessageDatetime = "last_message_datetime"
        case node = "node"
        case priority = "priority"
        case unreadMessages = "unread_messages"
        case workerPerson = "worker_person"
        case workerPhoneNumber = "worker_phone_number"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        allLastMessageSeen = try values.decodeIfPresent(String.self, forKey: .allLastMessageSeen)
        allLastMessageText = try values.decodeIfPresent(String.self, forKey: .allLastMessageText)
        colour = try values.decodeIfPresent(Int.self, forKey: .colour)
        customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
        customerPerson = try values.decodeIfPresent(String.self, forKey: .customerPerson)
        customerPhoneNumber = try values.decodeIfPresent(String.self, forKey: .customerPhoneNumber)
        externalConversationBlackList = try values.decodeIfPresent(Int.self, forKey: .externalConversationBlackList)
        externalConversationId = try values.decodeIfPresent(Int.self, forKey: .externalConversationId)
        internalAddressBookId = try values.decodeIfPresent(Int.self, forKey: .internalAddressBookId)
        internalAddressBookNameActive = try values.decodeIfPresent(Int.self, forKey: .internalAddressBookNameActive)
        internalAddressBookNames = try values.decodeIfPresent(String.self, forKey: .internalAddressBookNames)
        lastMessageDatetime = try values.decodeIfPresent(Int.self, forKey: .lastMessageDatetime)
        node = try values.decodeIfPresent(String.self, forKey: .node)
        priority = try values.decodeIfPresent(Int.self, forKey: .priority)
        unreadMessages = try values.decodeIfPresent(Int.self, forKey: .unreadMessages)
        workerPerson = try values.decodeIfPresent(String.self, forKey: .workerPerson)
        workerPhoneNumber = try values.decodeIfPresent(String.self, forKey: .workerPhoneNumber)
    }
    
}
