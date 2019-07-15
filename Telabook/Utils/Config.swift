//
//  Config.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
struct Config {
    struct DatabaseConfig {
        static let databaseRoot = Database.database().reference()
        static func getChats(companyId:String, node:String) -> DatabaseReference {
            let path = "companies/\(companyId)/conversations/\(node)"
            return databaseRoot.child(path)
        }
    }
    struct StorageConfig {
        static let storageRoot = Storage.storage().reference()
        static func profileImageRef() -> StorageReference {
            let companyId = UserDefaults.standard.getCompanyId()
            let workerId = UserDefaults.standard.getWorkerId()
            let path:String = "companies/\(companyId)/profile-images/\(workerId)"
            return StorageConfig.storageRoot.child(path)
        }
        static let messageImageRef = StorageConfig.storageRoot.child("img")
    }
    struct ServiceConfig {
        static let timeoutInterval:TimeInterval = 16.0
        static let serviceBaseURL = "https://fornax.aimservices.tech/"
        static let serviceBasePublicAPI = "https://fornax.aimservices.tech/testtelabook/the-firm-api/public/api/"
        static let serviceURLScheme = UrlScheme.https.rawValue
        static let serviceHost = "fornax.aimservices.tech"
        static let serviceCommonPath = "/testtelabook/the-firm-api/public/api"
        enum ServiceType:String {
            case Authentication = "loginfirebase.php?"
            case AuthenticationViaToken = "signin?"
            case CheckUserExists = "check_fbuser?"
            case InternalConversations = "internal_conversations?"
            case ExternalConversations = "external_conversations?"
            case ArchiveExternalConversation = "archive_external_conversation?"
            case RemoveArchivedExternalConversation = "remove_archive_external_conversation?"
            case GetBlacklist = "blacklists?"
            case UnblockNumber = "remove_number_blacklist?"
            case ChangeColor = "set_colour?"
            case SendMessage = "send?"
            case DirectMessage = "chat?"
            case GetCustomerDetails = "internal_address_book/index?"
            case UpdateCustomerDetails = "internal_address_book/edit?"
        }
        enum ServiceTypePath:String {
            case Authentication = "/loginfirebase.php"
            case AuthenticationViaToken = "/signin"
            case ForgotPassword = "/password/email"
            case CheckUserExists = "/check_fbuser"
            case InternalConversations = "/internal_conversations"
            case ExternalConversations = "/external_conversations"
            case ArchiveExternalConversation = "/archive_external_conversation"
            case RemoveArchivedExternalConversation = "/remove_archive_external_conversation"
            case GetBlacklist = "/blacklists"
            case UnblockNumber = "/remove_number_blacklist"
            case ChangeColor = "/set_colour"
            case SendMessage = "/send"
            case DirectMessage = "/chat"
            case GetCustomerDetails = "/internal_address_book/index"
            case UpdateCustomerDetails = "/internal_address_book/edit"
            case FollowUps = "/follow_ups"
            case QuickResponses = "/quick_answers"
            case ManageAgents = "/manage_agents"
            case UserProfile = "/users"
            case ScheduleMessage = "/schedule_message"
            case ChangePassword = "/profile/password"
        }
        static func getAuthenticationParamString(emailId:String, password:String) -> String {
            
            return "email=\(emailId)&pass=\(password)"
        }
        static func getAuthViaTokenParamString(token:String) -> String {
            return "token=\(token)"
        }
        
        static func getServiceURLPath(for type:ServiceTypePath) -> String {
            switch type {
            case .Authentication: return "\(serviceCommonPath)\(ServiceTypePath.Authentication.rawValue)"
            case .AuthenticationViaToken: return "\(serviceCommonPath)\(ServiceTypePath.AuthenticationViaToken.rawValue)"
            case .ForgotPassword: return "\(serviceCommonPath)\(ServiceTypePath.ForgotPassword.rawValue)"
            case .CheckUserExists: return "\(serviceCommonPath)\(ServiceTypePath.CheckUserExists.rawValue)"
            case .InternalConversations: return "\(serviceCommonPath)\(ServiceTypePath.InternalConversations.rawValue)"
            case .ExternalConversations: return "\(serviceCommonPath)\(ServiceTypePath.ExternalConversations.rawValue)"
            case .ArchiveExternalConversation: return "\(serviceCommonPath)\(ServiceTypePath.ArchiveExternalConversation.rawValue)"
            case .RemoveArchivedExternalConversation: return "\(serviceCommonPath)\(ServiceTypePath.RemoveArchivedExternalConversation.rawValue)"
            case .GetBlacklist: return "\(serviceCommonPath)\(ServiceTypePath.GetBlacklist.rawValue)"
            case .UnblockNumber: return "\(serviceCommonPath)\(ServiceTypePath.UnblockNumber.rawValue)"
            case .ChangeColor: return "\(serviceCommonPath)\(ServiceTypePath.ChangeColor.rawValue)"
            case .SendMessage: return "\(serviceCommonPath)\(ServiceTypePath.SendMessage.rawValue)"
            case .DirectMessage: return "\(serviceCommonPath)\(ServiceTypePath.DirectMessage.rawValue)"
            case .GetCustomerDetails: return "\(serviceCommonPath)\(ServiceTypePath.GetCustomerDetails.rawValue)"
            case .UpdateCustomerDetails: return "\(serviceCommonPath)\(ServiceTypePath.UpdateCustomerDetails.rawValue)"
            case .FollowUps: return "\(serviceCommonPath)\(ServiceTypePath.FollowUps.rawValue)"
            case .QuickResponses: return "\(serviceCommonPath)\(ServiceTypePath.QuickResponses.rawValue)"
            case .ManageAgents: return "\(serviceCommonPath)\(ServiceTypePath.ManageAgents.rawValue)"
            case .UserProfile: return "\(serviceCommonPath)\(ServiceTypePath.UserProfile.rawValue)"
            case .ScheduleMessage: return "\(serviceCommonPath)\(ServiceTypePath.ScheduleMessage.rawValue)"
            case .ChangePassword: return "\(serviceCommonPath)\(ServiceTypePath.ChangePassword.rawValue)"
            }
        }
        static func getServiceHostUri(_ serviceType:ServiceType) -> String {
            switch serviceType {
                case .Authentication: return "\(serviceBaseURL)\(ServiceType.Authentication.rawValue)"
                case .AuthenticationViaToken: return "\(serviceBasePublicAPI)\(ServiceType.AuthenticationViaToken.rawValue)"
                case .CheckUserExists: return "\(serviceBasePublicAPI)\(ServiceType.CheckUserExists.rawValue)"
                case .InternalConversations: return "\(serviceBasePublicAPI)\(ServiceType.InternalConversations.rawValue)"
                case .ExternalConversations: return "\(serviceBasePublicAPI)\(ServiceType.ExternalConversations.rawValue)"
                case .ArchiveExternalConversation: return "\(serviceBasePublicAPI)\(ServiceType.ArchiveExternalConversation.rawValue)"
                case .RemoveArchivedExternalConversation: return "\(serviceBasePublicAPI)\(ServiceType.RemoveArchivedExternalConversation.rawValue)"
                case .GetBlacklist: return "\(serviceBasePublicAPI)\(ServiceType.GetBlacklist.rawValue)"
                case .UnblockNumber: return "\(serviceBasePublicAPI)\(ServiceType.UnblockNumber.rawValue)"
                case .ChangeColor: return "\(serviceBasePublicAPI)\(ServiceType.ChangeColor.rawValue)"
                case .SendMessage: return "\(serviceBasePublicAPI)\(ServiceType.SendMessage.rawValue)"
                case .DirectMessage: return "\(serviceBasePublicAPI)\(ServiceType.DirectMessage.rawValue)"
                case .GetCustomerDetails: return "\(serviceBasePublicAPI)\(ServiceType.GetCustomerDetails.rawValue)"
                case .UpdateCustomerDetails: return "\(serviceBasePublicAPI)\(ServiceType.UpdateCustomerDetails.rawValue)"
            }
        }
    }
}
