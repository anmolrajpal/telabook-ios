//
//  APIServer.swift
//  Telabook
//
//  Created by Anmol Rajpal on 11/12/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

protocol Server: AnyObject {
   init(apiVersion:APIService.APIVersion)
   var apiVersion:APIService.APIVersion { get }
   var configuration: APIService.Configuration { get }
   
   func hitEndpoint<T:Decodable>(endpoint:APIService.Endpoint,
                                 requiresBearerToken:Bool,
                                 httpMethod:HTTPMethod,
                                 params: [String: String]?,
                                 httpBody: Data?,
                                 headers: [HTTPHeader]?,
                                 guardResponse: ResponseStatus?,
                                 expectData:Bool,
                                 endpointConfiguration: APIService.Configuration?,
                                 decoder: JSONDecoder,
                                 completion: @escaping APIService.APICompletion<T>)
}

class APIServer<T:Decodable> : Server {
   let apiVersion:APIService.APIVersion
   required init(apiVersion: APIService.APIVersion) {
      self.apiVersion = apiVersion
   }
   var configuration: APIService.Configuration {
      switch apiVersion {
      case .v1: return .defaultConfiguration
      case .v2: return .init(apiCommonPath: "\(Config.APIConfig.urlPrefix)/\(apiVersion.stringValue)")
      case .mock: fatalError()
      }
   }
   func hitEndpoint<T>(endpoint:APIService.Endpoint,
                       requiresBearerToken:Bool = true,
                       httpMethod:HTTPMethod,
                       params: [String: String]? = nil,
                       httpBody: Data? = nil,
                       headers: [HTTPHeader]? = nil,
                       guardResponse: ResponseStatus? = nil,
                       expectData:Bool = true,
                       endpointConfiguration: APIService.Configuration? = nil,
                       decoder: JSONDecoder = defaultDecoder,
                       completion: @escaping APIService.APICompletion<T>) where T : Decodable {
      switch apiVersion {
      case .v1:
         APIOperations.triggerAPIEndpointOperations(endpoint: endpoint,
                                                    httpMethod: httpMethod,
                                                    params: params,
                                                    httpBody: httpBody,
                                                    headers: headers,
                                                    guardResponse: guardResponse,
                                                    expectData: expectData,
                                                    decoder: decoder,
                                                    completion: completion)
      case .v2:
         APIOperations.triggerAPIEndpointOperations(endpoint: endpoint,
                                                    requiresBearerToken: requiresBearerToken,
                                                    httpMethod: httpMethod,
                                                    params: params,
                                                    httpBody: httpBody,
                                                    headers: headers,
                                                    guardResponse: guardResponse,
                                                    expectData: expectData,
                                                    configuration: endpointConfiguration ?? configuration,
                                                    decoder: decoder,
                                                    completion: completion)
      case .mock: print("Mock")
      }
   }
}
