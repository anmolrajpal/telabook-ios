//
//  APIOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 02/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation




struct APIOperations {

    /// Returns an array of operations for creating and hitting API Endpoint
    static func triggerAPIEndpointOperations<T:Codable>(endpoint:APIService.Endpoint, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true, completion: @escaping APIService.APICompletion<T>) {
        print("Triggering API Endpoint Operations")
        let queue = OperationQueue()
        queue.name = "Endpoint Queue"
        queue.maxConcurrentOperationCount = 1
        let fetchFirebaseTokenOperation = FetchTokenOperation()
        
        let hitEndpointOperation = HitEndpointOperation<T>(endpoint: endpoint, httpMethod: httpMethod, params: params, httpBody: httpBody, headers: headers, guardResponse: guardResponse, expectData: expectData)
        
        let passFirebaseTokenToAPIEndpointOperation = BlockOperation { [unowned fetchFirebaseTokenOperation, unowned hitEndpointOperation] in
            guard case let .success(bearerToken)? = fetchFirebaseTokenOperation.result else {
                hitEndpointOperation.cancel()
                return
            }
            hitEndpointOperation.bearerToken = bearerToken
        }
        passFirebaseTokenToAPIEndpointOperation.addDependency(fetchFirebaseTokenOperation)
        hitEndpointOperation.addDependency(passFirebaseTokenToAPIEndpointOperation)
        
        hitEndpointOperation.completionBlock = {
            guard let result = hitEndpointOperation.result else {
                print("Darn it. There's no Result in last operation")
                return
            }
            completion(result)
        }
        
        queue.addOperations([fetchFirebaseTokenOperation, passFirebaseTokenToAPIEndpointOperation, hitEndpointOperation], waitUntilFinished: false)
        
//        return [fetchFirebaseTokenOperation, passFirebaseTokenToAPIEndpointOperation, hitEndpointOperation]
    }
}




/// Downloads Agents entries from the server.
class HitEndpointOperation<T:Codable>: Operation {
    var result: (Result<T, APIService.APIError>)?
    private let decoder = JSONDecoder()
    private var downloading = false
    private var session = URLSession.shared
    private var dataTask: URLSessionDataTask!
    
    private let endpoint:APIService.Endpoint
    private let httpMethod:HTTPMethod
    private let params:[String:String]?
    private let httpBody:Data?
    private let headers:[HTTPHeader]?
    private let guardResponse:ResponseStatus?
    private let expectData:Bool
    var bearerToken:String?
    
    init(endpoint:APIService.Endpoint, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true) {
        print("Hit Endpoint Operation init")
        self.endpoint = endpoint
        self.httpMethod = httpMethod
        self.params = params
        self.httpBody = httpBody
        self.headers = headers
        self.guardResponse = guardResponse
        self.expectData = expectData
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
        print("API Operation finish")
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        print("API Operation Start")
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        guard let url = APIService.shared.constructURL(forEndpoint: endpoint, parameters: params) else {
            print("Error Log: Unable to Construct URL")
            finish(result: .failure(.invalidURL))
            return
        }
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        #if DEBUG
        print("Endpoint URL= \(url)")
        #endif
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: APIService.Configuration.timeOutInterval)
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        request.httpMethod = httpMethod.rawValue
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        guard let token = bearerToken else {
            finish(result: .failure(.noFirebaseToken(error: nil)))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        if let httpBody = httpBody { request.httpBody = httpBody }
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
            #if DEBUG
            print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
            #endif
            if let expectedResponse = self.guardResponse {
                guard responseStatus == expectedResponse else {
                    self.finish(result: .failure(.unexptectedResponse(response: responseStatus)))
                    return
                }
            } else {
                guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                    self.finish(result: .failure(.unexptectedResponse(response: responseStatus)))
                    return
                }
            }
            
            if self.expectData {
                guard let data = data else {
                    self.finish(result: .failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    self.finish(result: .success(object))
                } catch let error {
                    #if DEBUG
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    #endif
                    self.finish(result: .failure(.jsonDecodingError(error: error)))
                }
            } else {
                let customObjectString = "{\"result\":\"success\",\"message\":\"Success. Empty Data or Data not required.\",\"data\":{}}"
                let customObject = try! self.decoder.decode(T.self, from: customObjectString.data(using: .utf8)!)
                self.finish(result: .success(customObject))
            }
        }
        dataTask.resume()
    }
}
