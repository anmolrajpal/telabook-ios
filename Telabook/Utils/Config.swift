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
    internal enum Environment { case Development, Staging, Production }
    
    static let environment:Environment = .Development
    
    struct APIConfig {
        static var baseURL:String {
            switch Config.environment {
                case .Development: return "https://fornax.aimservices.tech"
                case .Staging: return "https://fornax.aimservices.tech"
                case .Production: return "https://fornax.aimservices.tech"
            }
        }
        static var urlScheme:String {
            switch Config.environment {
                case .Development: return URLScheme.https.rawValue
                case .Staging: return URLScheme.https.rawValue
                case .Production: return URLScheme.https.rawValue
            }
        }
        static var apiHost:String {
            switch Config.environment {
                case .Development: return "fornax.aimservices.tech"
                case .Staging: return "fornax.aimservices.tech"
                case .Production: return "fornax.aimservices.tech"
            }
        }
        static var port:Int? {
            switch Config.environment {
                case .Development: return nil
                case .Staging: return nil
                case .Production: return nil
            }
        }
        static var urlPrefix:String {
            switch Config.environment {
                case .Development: return "/api"
                case .Staging: return "/api"
                case .Production: return "/api"
            }
        }
        static var apiVersion:APIService.APIVersion {
            switch Config.environment {
                case .Development: return .v1
                case .Staging: return .v1
                case .Production: return .v1
            }
        }
    }
    
    struct FirebaseConfig {
        enum Node {
            
            /// Node to fetch the Agent's Customer list / conversations
            case conversations(companyID:Int, workerID:Int)
            
            /// Node to get chats of the specified customer + agent of node
            case messages(companyID:Int, node:String)
            
            
            var reference:DatabaseReference {
                switch self {
                    case let .conversations(companyID, workerID): return databaseRoot.child("companies/\(companyID)/inbox/\(workerID)")
                    case let .messages(companyID, node): return databaseRoot.child("companies/\(companyID)/conversations/\(node)")
                }
            }
        }
        static let databaseRoot = Database.database().reference()
        
        static func getChats(companyId:String, node:String) -> DatabaseReference {
            let path = "companies/\(companyId)/conversations/\(node)"
            return databaseRoot.child(path)
        }
        static func onlineUsersReference() -> DatabaseReference {
            let companyId = AppData.companyId
            let reference = databaseRoot.child("companies").child(String(companyId)).child("online")
            return reference
        }
    }
    
    struct DatabaseConfig {
        static let databaseRoot = Database.database().reference()
        static func getChats(companyId:String, node:String) -> DatabaseReference {
            let path = "companies/\(companyId)/conversations/\(node)"
            return databaseRoot.child(path)
        }
        static func onlineUsersReference() -> DatabaseReference {
            let companyId = AppData.companyId
            let reference = databaseRoot.child("companies").child(String(companyId)).child("online")
            return reference
        }
    }
    struct StorageConfig {
        static let storageRoot = Storage.storage().reference()
        static func profileImageRef() -> StorageReference {
            let companyId = AppData.companyId
            let workerId = AppData.workerId
            let reference = StorageConfig.storageRoot.child("companies").child(String(companyId)).child("profile-images").child(String(workerId))
            return reference
        }
        
        static let messageImageRef = StorageConfig.storageRoot.child("img")
    }
    struct ServiceConfig {
        static let timeoutInterval:TimeInterval = 16.0
        static let serviceBaseURL = "https://fornax.aimservices.tech/"
        static let serviceBasePublicAPI = "https://fornax.aimservices.tech/api/"
        static let serviceURLScheme = UrlScheme.https.rawValue
        static let serviceHost = "fornax.aimservices.tech"
        static let serviceCommonPath = "/api"
        enum ServiceType:String {
            case Authentication = "loginfirebase.php?"
            case AuthenticationViaToken = "android/signin"
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
            case CallGroups = "/profile/groups"
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
            case .CallGroups: return "\(serviceCommonPath)\(ServiceTypePath.CallGroups.rawValue)"
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
