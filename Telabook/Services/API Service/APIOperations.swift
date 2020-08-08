//
//  APIOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 02/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import os

protocol Server: class {
    init(apiVersion:APIService.APIVersion)
//    var apiVersion:APIService.APIVersion { get }
    func hitEndpoint<T:Decodable>(endpoint:APIService.Endpoint, requiresBearerToken:Bool, httpMethod:HTTPMethod, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, expectData:Bool, endpointConfiguration: APIService.Configuration?, completion: @escaping APIService.APICompletion<T>, decoder:JSONDecoder)
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
    func hitEndpoint<T>(endpoint:APIService.Endpoint, requiresBearerToken:Bool = true, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true, endpointConfiguration: APIService.Configuration? = nil, completion: @escaping APIService.APICompletion<T>, decoder:JSONDecoder = defaultDecoder) where T : Decodable {
        switch apiVersion {
            case .v1:
                APIOperations.triggerAPIEndpointOperations(endpoint: endpoint, httpMethod: httpMethod, params: params, httpBody: httpBody, headers: headers, guardResponse: guardResponse, expectData: expectData, completion: completion, decoder: decoder)
            case .v2:
                APIOperations.triggerAPIEndpointOperations(endpoint: endpoint, requiresBearerToken: requiresBearerToken, httpMethod: httpMethod, params: params, httpBody: httpBody, headers: headers, guardResponse: guardResponse, expectData: expectData, configuration: endpointConfiguration ?? configuration, completion: completion, decoder: decoder)
            case .mock: print("Mock")
        }
    }
}


struct APIOperations {
    
    /// Returns an array of operations for creating and hitting API Endpoint
    static func triggerAPIEndpointOperations<T:Decodable>(endpoint:APIService.Endpoint, requiresBearerToken:Bool = true, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true, configuration: APIService.Configuration = .defaultConfiguration, completion: @escaping APIService.APICompletion<T>, decoder:JSONDecoder) {
        
        let isLoggingEnabled = APIService.shared.isLoggingEnabled
        
        var operations = [Operation]()
        let queue = OperationQueue()
        queue.name = "Endpoint Queue"
        queue.maxConcurrentOperationCount = 1
        
        
        
        let hitEndpointOperation = HitEndpointOperation<T>(endpoint: endpoint, requiresBearerToken: requiresBearerToken, httpMethod: httpMethod, params: params, httpBody: httpBody, headers: headers, guardResponse: guardResponse, expectData: expectData, configuration: configuration, decoder: decoder)
        
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
                os_log("Operation Error: HitEndpointOperation must return a result.", log: .network, type: .error)
                fatalError("Operation Error: HitEndpointOperation must return a result.")
            }
            completion(result)
        }
        operations.append(hitEndpointOperation)
        queue.addOperations(operations, waitUntilFinished: false)
    }
}




/// Downloads Agents entries from the server.
class HitEndpointOperation<T:Decodable>: Operation {
    let isLoggingEnabled = APIService.shared.isLoggingEnabled
    
    var result: (Result<T, APIService.APIError>)?
    private let decoder:JSONDecoder
    private var downloading = false
    private var session = URLSession.shared
    private var dataTask: URLSessionDataTask!
    
    private let configuration:APIService.Configuration
    private let endpoint:APIService.Endpoint
    private let requiresBearerToken:Bool
    private let httpMethod:HTTPMethod
    private let params:[String:String]?
    private let httpBody:Data?
    private let headers:[HTTPHeader]?
    private let guardResponse:ResponseStatus?
    private let expectData:Bool
    var bearerToken:String?
    
    init(endpoint:APIService.Endpoint, requiresBearerToken:Bool = true, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true, configuration:APIService.Configuration = .defaultConfiguration, decoder:JSONDecoder) {
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
    
    func finish(result: (Result<T, APIService.APIError>)?) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        dataTask = nil
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        guard let url = APIService.shared.constructURL(forEndpoint: endpoint, parameters: params, with: configuration) else {
            finish(result: .failure(.invalidURL))
            return
        }
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        if isLoggingEnabled {
            printAndLog(message: "Endpoint URL => \(url)", log: .network, logType: .info, isPrivate: true)
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: configuration.timeOutInterval)
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        request.httpMethod = httpMethod.rawValue
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        if requiresBearerToken {
            guard let token = bearerToken else {
                finish(result: .failure(.noFirebaseToken(error: nil)))
                return
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
        }
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
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
            finish(result: .failure(.cancelled))
            return
        }
        dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                self.finish(result: .failure(.networkError(error: error!)))
                return
            }
            guard let response = response else {
                self.finish(result: .failure(.noResponse))
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
                    self.finish(result: .failure(.unexptectedResponse(response: responseStatus)))
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
                    self.finish(result: .failure(.unexptectedResponse(response: responseStatus)))
                    return
                }
            }
            
            if self.expectData {
                guard let data = data else {
                    self.finish(result: .failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
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
                    self.finish(result: .success(object))
                } catch let error {
                    if self.isLoggingEnabled {
                        let message = "JSON Decoding Error: \(error)"
                        printAndLog(message: message, log: .network, logType: .error)
                    }
                    self.finish(result: .failure(.jsonDecodingError(error: error)))
                }
            } else {
                let customObjectString = "{\"result\":\"success\",\"message\":\"Success. Empty Data or Data not required.\",\"data\":{}}"
                let customObject = try! self.decoder.decode(T.self, from: customObjectString.data(using: .utf8)!) // Explicit unwrapping because jsonString is static so the result is known and should
                self.finish(result: .success(customObject))                                                       // be decoded to (EmptyData) - Codable result type
            }
        }
        dataTask.resume()
    }
}
