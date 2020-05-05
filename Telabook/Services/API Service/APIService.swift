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
    let decoder = JSONDecoder()
    
    enum APIVersion { case v1, v2, mock; var stringValue:String { String(describing: self) }}
    
    /// Configuration options for API Endpoints URL constructor.
    struct Configuration {
        static let timeOutInterval:TimeInterval = 15.0
        static let apiURLScheme = Config.APIConfig.urlScheme
        static let baseURL = Config.APIConfig.baseURL
        static let apiHost = Config.APIConfig.apiHost
        static let port:Int? = Config.APIConfig.port
        static let apiCommonPath:String = Config.APIConfig.urlPrefix
    }
    
    struct EmptyData:Codable {
        let result:String
        let message:String
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
                case let .UpdateUserProfile(userId): return "/android/users/\(String(userId))"
                case .ViewUserProfile: return "/android/signin"
                case .FetchAgents: return "/agents"
                case .FetchQuickResponses: return "/android/quick_replies"
                case .CreateQuickResponse: return "/android/quick_replies"
                case let .UpdateQuickResponse(responseID): return "/android/quick_replies/\(responseID)"
                case let .DeleteQuickResponse(responseID): return "/android/quick_replies/\(responseID)"
                case .AutoResponse: return "/android/sms_auto_reply"
            }
        }
    }
}
