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
        }
        
        static func getAuthenticationParamString(emailId:String, password:String) -> String {
            return "email=\(emailId)&pass=\(password)"
        }
        static func getAuthViaTokenParamString(token:String) -> String {
            return "token=\(token)"
        }
        
//        static func getServiceParamString(_ serviceType:ServiceType, params:String...) -> String {
//            switch serviceType {
//                case .Authentication: return "email=\(params[0])&pass=\(params[1])"
//                case .AuthenticationViaToken: return "token=\(params[0])"
//                case .CheckUserExists: return "email=\(params[0])&password=\(params[1])"
//                case .InternalConversations: return "token=\(params[0])&company_id=\(params[1])"
//                case .ExternalConversations: return "token=\(params[0])&worker_id=\(params[1])&Company_id=\(params[2])"
//            }
//        }
        static func getServiceHostUri(_ serviceType:ServiceType) -> String {
            switch serviceType {
                case .Authentication: return "\(serviceBaseURL)\(ServiceType.Authentication.rawValue)"
                case .AuthenticationViaToken: return "\(serviceBasePublicAPI)\(ServiceType.AuthenticationViaToken.rawValue)"
                case .CheckUserExists: return "\(serviceBasePublicAPI)\(ServiceType.CheckUserExists.rawValue)"
                case .InternalConversations: return "\(serviceBasePublicAPI)\(ServiceType.InternalConversations.rawValue)"
                case .ExternalConversations: return "\(serviceBasePublicAPI)\(ServiceType.ExternalConversations.rawValue)"
            }
        }
    }
}
