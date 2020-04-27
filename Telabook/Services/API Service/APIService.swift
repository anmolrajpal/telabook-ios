//
//  APIService.swift
//  matchbook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation


public struct APIService: APIServiceProtocol {
    typealias APICompletion<T> = (Result<T, APIError>) -> Void
    static let shared = APIService()
    let decoder = JSONDecoder()
    
    /// Configuration options for API Endpoints URL constructor.
    struct Configuration {
        static let timeOutInterval:TimeInterval = 15.0
        static let apiURLScheme = Config.APIConfig.urlScheme
        static let baseURL = Config.APIConfig.baseURL
        static let apiHost = Config.APIConfig.apiHost
        static let port:Int? = Config.APIConfig.port
        static let apiCommonPath:String = Config.APIConfig.urlPrefix
    }
    
    
    
    /// All API Endpoints options used in the app.
    /// - Note: `path()` function is required to return the Path of the specified Endpoint as a `String`
    enum Endpoint {
        
        /// Endpoint for User Login
        case SignIn
     
        
        
        
        
        
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
            }
        }
    }
}
