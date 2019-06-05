//
//  Config.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
struct Config {
    struct ServiceConfig {
        static let timeoutInterval:TimeInterval = 16.0
        static let serviceBaseURL = "https://fornax.aimservices.tech/"
        static let serviceBasePublicAPI = "https://fornax.aimservices.tech/testtelabook/the-firm-api/public/api/"
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
        }
        
        static func getAuthenticationParamString(emailId:String, password:String) -> String {
            
            return "email=\(emailId)&pass=\(password)"
        }
        static func getAuthViaTokenParamString(token:String) -> String {
            return "token=\(token)"
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
            }
        }
    }
}
