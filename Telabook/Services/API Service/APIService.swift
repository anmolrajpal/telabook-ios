//
//  APIService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation


public struct APIService: APIServiceProtocol {
    typealias APICompletion<T> = (Result<T, APIError>) -> Void
    static let shared = APIService()
    var isLoggingEnabled = false
    let decoder = JSONDecoder()
    
    enum APIVersion { case v1, v2, mock; var stringValue:String { String(describing: self) }}
    
    /// Configuration options for API Endpoints URL constructor.
    struct Configuration {
        let timeOutInterval:TimeInterval
        let apiURLScheme:String
        let baseURL:String
        let apiHost:String
        let port:Int?
        let apiCommonPath:String
//        static let apiVersion: APIVersion = Config.APIConfig.apiVersion
        
        init(timeOutInterval: TimeInterval = 15.0, apiURLScheme: String = Config.APIConfig.urlScheme, baseURL: String = Config.APIConfig.baseURL, apiHost: String = Config.APIConfig.apiHost, port: Int? = Config.APIConfig.port, apiCommonPath: String = Config.APIConfig.urlPrefix) {
            self.timeOutInterval = timeOutInterval
            self.apiURLScheme = apiURLScheme
            self.baseURL = baseURL
            self.apiHost = apiHost
            self.port = port
            self.apiCommonPath = apiCommonPath
        }
        static let defaultConfiguration:Configuration = .init()
    }
    
    struct EmptyData:Codable {
        let result:String
        let message:String
    }
    struct RecurrentResult:Codable {
        let result:String?
        let message:String?
    }
    /// All API Endpoints options used in the app.
    /// - Note: `path()` function is required to return the Path of the specified Endpoint as a `String`
    enum Endpoint {
        
        /// Endpoint for User Login
        case SignIn
     
        /// Endpoint for fetching all companies belonging to the Owner
        case FetchUserCompanies
        
        /// Endpoint for updating user password
        case UpdatePassword
        
        /// Endpoint for updating user profile
        case UpdateUserProfile(userId:Int)
        
        /// Endpoint to fetch user profile
        case ViewUserProfile
        
        /// Enpoint to fetch all agents list
        case FetchAgents
        
        /// Endpoing to fetch Agent's quick responses
        case FetchQuickResponses
        
        /// Endpoint to create new quick response for the Agent
        case CreateQuickResponse
        
        /// Endpoint to update an existing quick response
        case UpdateQuickResponse(responseID:Int)
        
        /// Endpoint to delete an existing quick response
        case DeleteQuickResponse(responseID:Int)
        
        /// Endpoint to fetch Agent's First Time SMS
        case AutoResponse
        
        /// Endpoint to search Agent's customers / external conversations
        case SearchCustomer
        
        /// Endpoint to archive Agent's conversation with customer
        case ArchiveConversation
        
        /// Endpoint to unarchive Agent's conversation with customer
        case UnarchiveConversation
        
        /// Endpoint to start a new conversation with entered customer's phone number
        case StartNewConversation
        
        /// Endpoint to fetch all blocked users
        case FetchBlacklist
        
        /// Endpoint to block selected customer
        case BlockConversation
        
        /// Endpoint to unblock customer from blacklist
        case UnblockConversation
        
        /// Endpoint to delete conversation
        case DeleteConversation(conversationID:Int)
        
        /// Endpoint to request forgot password
        case ForgotPassword
        
        /// Endpoint to send new  message
        case SendMessage
        
        /// Endpoint to fetch scheduled messages
        case FetchScheduledMessages
        
        /// Endpoint to schedule new text message
        case ScheduleNewMessage
        
        /// Endpoint for click 2 call
        case Click2Call
        
        
        /**
        Returns the path of a specified Endpoint.
        ## Example Usage ##
        ```
        let endpoint:APIService.Endpoint = .ExampleEndpoint
        let endpointPath:String = endpoint.path()
        print("Endpoint: \(endpoint) and its Endpoint Path: \(endpointPath)")
        ```
         - Returns: The Endpoint Path as a String
        */
        func path() -> String {
            switch self {
                case .SignIn: return "/android/signin"
                case .FetchUserCompanies: return "/android/user/companies"
                case .UpdatePassword: return "/android/profile/password"
                case let .UpdateUserProfile(userId): return "/users/\(String(userId))"
                case .ViewUserProfile: return "/android/signin"
                case .FetchAgents: return "/agents"
                case .FetchQuickResponses: return "/android/quick_replies"
                case .CreateQuickResponse: return "/android/quick_replies"
                case let .UpdateQuickResponse(responseID): return "/android/quick_replies/\(responseID)"
                case let .DeleteQuickResponse(responseID): return "/android/quick_replies/\(responseID)"
                case .AutoResponse: return "/android/sms_auto_reply"
                case .SearchCustomer: return "/external_conversations/search_firebase"
                case .ArchiveConversation: return "/archive_external_conversation"
                case .UnarchiveConversation: return "/remove_archive_external_conversation"
                case .StartNewConversation: return "/external_conversations"
                case .FetchBlacklist: return "/blacklists/list"
                case .BlockConversation: return "/blacklists"
                case .UnblockConversation: return "/remove_number_blacklist"
                case let .DeleteConversation(conversationID): return "/external_conversations/\(conversationID)"
                case .ForgotPassword: return "/password/email"
                case .SendMessage: return "/send"
                case .FetchScheduledMessages, .ScheduleNewMessage: return "/schedule_message"
                case .Click2Call: return "/call/twilioclicktocall"
            }
        }
    }
}
