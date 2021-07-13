//
//  APIEndpointOperation.swift
//  Telabook
//
//  Created by Anmol Rajpal on 11/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import Foundation

/// API Endpoint final Opeartion Protocol to hit endpoint and start data task.
protocol EndpointOperation {
   associatedtype T: Decodable
   var result: (Result<T, APIService.APIError>)? { get set }
   var decoder: JSONDecoder { get }
   var downloading: Bool { get }
   var session: URLSession { get }
   var dataTask: URLSessionDataTask! { get }
   var configuration:APIService.Configuration { get }
   var endpoint:APIService.Endpoint { get }
   var requiresBearerToken:Bool { get }
   var httpMethod:HTTPMethod { get }
   var params:[String:String]? { get }
   var httpBody:Data? { get }
   var headers:[HTTPHeader]? { get }
   var guardResponse:ResponseStatus? { get }
   var expectData:Bool { get }
   var bearerToken:String? { get }
   func startOperation()
   func finishOperation(result: (Result<T, APIService.APIError>)?)
}
/// Final operation to hit endpoint and start data task.
class HitEndpointOperation<T:Decodable>: Operation, EndpointOperation {
   let isLoggingEnabled = APIService.shared.isLoggingEnabled
   
   var result: (Result<T, APIService.APIError>)?
   var decoder:JSONDecoder
   var downloading = false
   var session = URLSession.shared
   var dataTask: URLSessionDataTask!
   var configuration:APIService.Configuration
   var endpoint:APIService.Endpoint
   var requiresBearerToken:Bool
   var httpMethod:HTTPMethod
   var params:[String:String]?
   var httpBody:Data?
   var headers:[HTTPHeader]?
   var guardResponse:ResponseStatus?
   var expectData:Bool
   var bearerToken:String?
   
   init(endpoint:APIService.Endpoint,
        requiresBearerToken:Bool = true,
        httpMethod:HTTPMethod,
        params: [String: String]? = nil,
        httpBody: Data? = nil,
        headers: [HTTPHeader]? = nil,
        guardResponse: ResponseStatus? = nil,
        expectData:Bool = true,
        configuration:APIService.Configuration = .defaultConfiguration,
        decoder:JSONDecoder) {
      self.endpoint = endpoint
      self.requiresBearerToken = requiresBearerToken
      self.httpMethod = httpMethod
      self.params = params
      self.httpBody = httpBody
      self.headers = headers
      self.guardResponse = guardResponse
      self.expectData = expectData
      self.configuration = configuration
      self.decoder = decoder
   }
   
   override var isAsynchronous: Bool {
      return true
   }
   
   override var isExecuting: Bool {
      return downloading
   }
   
   override var isFinished: Bool {
      return result != nil
   }
   
   override func cancel() {
      super.cancel()
      if let dataTask = dataTask {
         dataTask.cancel()
      }
   }
   override func start() {
      startOperation()
   }

   func startOperation() {
      willChangeValue(forKey: #keyPath(isExecuting))
      downloading = true
      didChangeValue(forKey: #keyPath(isExecuting))
      
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      guard let url = APIService.shared.constructURL(forEndpoint: endpoint, parameters: params, with: configuration) else {
         finishOperation(result: .failure(.invalidURL))
         return
      }
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      if isLoggingEnabled {
         printAndLog(message: "Endpoint URL => \(url)", log: .network, logType: .info, isPrivate: true)
      }
      var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: configuration.timeOutInterval)
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      request.httpMethod = httpMethod.rawValue
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      if requiresBearerToken {
         guard let token = bearerToken else {
            finishOperation(result: .failure(.noFirebaseToken(error: nil)))
            return
         }
         request.setValue("Bearer \(token)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
      }
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      if let httpBody = httpBody {
         request.httpBody = httpBody
         if isLoggingEnabled {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                  let json = String(data: jsonData, encoding: .utf8) else {
               print("Unable to convert Data to JSON String")
               return
            }
            printAndLog(message: "\n\n------------------------------------------------ Request HTTP Body JSON: BEGIN ------------------------------------------------\n\n"+json+"\n\n--------------------------------------------------- Request HTTP Body JSON: END ------------------------------------------------\n\n", log: .network, logType: .debug)
         }
      }
      guard !isCancelled else {
         finishOperation(result: .failure(.cancelled))
         return
      }
      dataTask = session.dataTask(with: request) { (data, response, error) in
         guard error == nil else {
            self.finishOperation(result: .failure(.networkError(error: error!)))
            return
         }
         guard let response = response else {
            self.finishOperation(result: .failure(.noResponse))
            return
         }
         let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
         let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
         
         if self.isLoggingEnabled {
            let responseMessage = "\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\nFor URL: \(url)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n"
            printAndLog(message: responseMessage, log: .network, logType: .info, isPrivate: true)
         }
         
         if let expectedResponse = self.guardResponse {
            guard responseStatus == expectedResponse else {
               self.finishOperation(result: .failure(.unexpectedResponse(response: responseStatus)))
               return
            }
         } else {
            guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
               if let data = data {
                  if self.isLoggingEnabled {
                     if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                        let json = String(data: jsonData, encoding: .utf8) {
                        let jsonMessage = "\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+json+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n"
                        printAndLog(message: jsonMessage, log: .network, logType: .info, isPrivate: true)
                     }
                  }
               }
               self.finishOperation(result: .failure(.unexpectedResponse(response: responseStatus, data: data)))
               return
            }
         }
         
         if self.expectData {
            guard let data = data else {
               self.finishOperation(result: .failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
               return
            }
            
            if self.isLoggingEnabled {
               if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                  let json = String(data: jsonData, encoding: .utf8) {
                  let jsonMessage = "\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+json+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n"
                  printAndLog(message: jsonMessage, log: .network, logType: .info, isPrivate: true)
               } else if let json = String(data: data, encoding: .utf8) {
                  let jsonMessage = "\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+json+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n"
                  printAndLog(message: jsonMessage, log: .network, logType: .info, isPrivate: true)
               }
            }
            do {
               let object = try self.decoder.decode(T.self, from: data)
               self.finishOperation(result: .success(object))
            } catch let error {
               if self.isLoggingEnabled {
                  let message = "JSON Decoding Error: \(error)"
                  printAndLog(message: message, log: .network, logType: .error)
               }
               self.finishOperation(result: .failure(.jsonDecodingError(error: error, data: data)))
            }
         } else {
            let customObjectString = "{\"result\":\"success\",\"message\":\"Success. Empty Data or Data not required.\",\"data\":{}}"
            let customObject = try! self.decoder.decode(T.self, from: customObjectString.data(using: .utf8)!) // Explicit unwrapping because jsonString is static so the result is known and should
            self.finishOperation(result: .success(customObject)) // be decoded to (EmptyData) - Codable result type
         }
      }
      dataTask.resume()
   }
   func finishOperation(result: (Result<T, APIService.APIError>)?) {
      guard downloading else { return }
      
      willChangeValue(forKey: #keyPath(isExecuting))
      willChangeValue(forKey: #keyPath(isFinished))
      
      downloading = false
      self.result = result
      dataTask = nil
      
      didChangeValue(forKey: #keyPath(isFinished))
      didChangeValue(forKey: #keyPath(isExecuting))
   }
}
