//
//  APIOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 02/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

protocol API {
   static func triggerAPIEndpointOperations<T:Decodable>(endpoint:APIService.Endpoint,
                                                         requiresBearerToken:Bool,
                                                         httpMethod:HTTPMethod,
                                                         params: [String: String]?,
                                                         httpBody: Data?,
                                                         headers: [HTTPHeader]?,
                                                         guardResponse: ResponseStatus?,
                                                         expectData:Bool,
                                                         configuration: APIService.Configuration,
                                                         decoder:JSONDecoder,
                                                         completion: @escaping APIService.APICompletion<T>)
}
struct APIOperations: API {
   
   /// A function to trigger API endpoint operation.
   static func triggerAPIEndpointOperations<T:Decodable>(endpoint:APIService.Endpoint,
                                                         requiresBearerToken:Bool = true,
                                                         httpMethod:HTTPMethod,
                                                         params: [String: String]? = nil,
                                                         httpBody: Data? = nil,
                                                         headers: [HTTPHeader]? = nil,
                                                         guardResponse: ResponseStatus? = nil,
                                                         expectData:Bool = true,
                                                         configuration: APIService.Configuration = .defaultConfiguration,
                                                         decoder:JSONDecoder,
                                                         completion: @escaping APIService.APICompletion<T>) {
      
      let isLoggingEnabled = APIService.shared.isLoggingEnabled
      
      var operations = [Operation]()
      let queue = OperationQueue()
      queue.name = "Endpoint Queue"
      queue.maxConcurrentOperationCount = 1
      
      
      let hitEndpointOperation = HitEndpointOperation<T>(endpoint: endpoint,
                                                         requiresBearerToken: requiresBearerToken,
                                                         httpMethod: httpMethod,
                                                         params: params,
                                                         httpBody: httpBody,
                                                         headers: headers,
                                                         guardResponse: guardResponse,
                                                         expectData: expectData,
                                                         configuration: configuration,
                                                         decoder: decoder)
      
      if requiresBearerToken {
         let fetchFirebaseTokenOperation = FetchTokenOperation()
         let passFirebaseTokenToAPIEndpointOperation = BlockOperation { [unowned fetchFirebaseTokenOperation, unowned hitEndpointOperation] in
            guard case let .success(bearerToken)? = fetchFirebaseTokenOperation.result else {
               if case let .failure(error) = fetchFirebaseTokenOperation.result {
                  completion(.failure(.noFirebaseToken(error: error)))
               }
               hitEndpointOperation.cancel()
               return
            }
            hitEndpointOperation.bearerToken = bearerToken
            
            if isLoggingEnabled {
               let message = "\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n"
               printAndLog(message: message, log: .firebase, logType: .info, isPrivate: true)
            }
         }
         passFirebaseTokenToAPIEndpointOperation.addDependency(fetchFirebaseTokenOperation)
         hitEndpointOperation.addDependency(passFirebaseTokenToAPIEndpointOperation)
         
         operations.append(fetchFirebaseTokenOperation)
         operations.append(passFirebaseTokenToAPIEndpointOperation)
      }
      hitEndpointOperation.completionBlock = {
         guard let result = hitEndpointOperation.result else {
            printAndLog(message: "### \(#function) | Operation Error: must return a result.", log: .network, logType: .error)
            fatalError("Operation Error: HitEndpointOperation must return a result.")
         }
         completion(result)
      }
      operations.append(hitEndpointOperation)
      queue.addOperations(operations, waitUntilFinished: false)
   }
}
