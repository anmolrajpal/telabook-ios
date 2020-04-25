//
//  APIService.swift
//  matchbook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol APIServiceProtocol {
    func loginWithCredentials<T: Codable>(endpoint: APIService.Endpoint, email: String, password: String, params: [String: String]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func GET<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, completion: @escaping APIService.APICompletion<T>)
    func POST<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, completion: @escaping APIService.APICompletion<T>)
    func PUT<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, completion: @escaping APIService.APICompletion<T>)
    func DELETE<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, completion: @escaping APIService.APICompletion<T>)
    func constructURL(scheme:String, host:String, port:Int?, forEndpoint endpoint:APIService.Endpoint, urlPrefix:String, withConcatenatingPath pathToJoin:String?, parameters:[String:String]?) -> URL?
}

struct APIService: APIServiceProtocol {
    typealias APICompletion<T> = (Result<T, APIError>) -> Void
    static let shared = APIService()
    struct Configuration {
        static let timeOutInterval:TimeInterval = 15.0
        static let apiURLScheme = Config.APIConfig.urlScheme
        static let baseURL = Config.APIConfig.baseURL
        static let apiHost = Config.APIConfig.apiHost
        static let port:Int? = Config.APIConfig.port
        static let apiCommonPath:String = Config.APIConfig.urlPrefix
    }
    
    let decoder = JSONDecoder()
    
    enum APIError: Error {
        case invalidURL
        case noFirebaseToken(error: Error)
        case noResponse
        case unexptectedResponse(response:ResponseStatus)
        case noData(response:ResponseStatus)
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
    }
    
    enum Endpoint {
        case SignIn
        
        func path() -> String {
            switch self {
                case .SignIn: return "/android/signin"
            }
        }
    }
    
    
    
    func loginWithCredentials<T: Codable>(endpoint: Endpoint = .SignIn, email: String, password: String, params: [String: String]?, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.authenticateAndFetchToken(email: email, password: password) { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.POST.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func GET<T: Codable>(endpoint: Endpoint, params: [String: String]?, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            guard let url = self.constructURL(forEndpoint: .SignIn, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.GET.rawValue
            request.setValue(bearerToken, forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
    }
    
    func POST<T: Codable>(endpoint: Endpoint, params: [String: String]?, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.POST.rawValue
            request.setValue(bearerToken, forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func PUT<T: Codable>(endpoint: Endpoint, params: [String: String]?, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.PUT.rawValue
            request.setValue(bearerToken, forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func DELETE<T: Codable>(endpoint: Endpoint, params: [String: String]?, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.DELETE.rawValue
            request.setValue(bearerToken, forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    
    internal func constructURL(scheme:String = Configuration.apiURLScheme, host:String = Configuration.apiHost, port:Int? = Configuration.port, forEndpoint endpoint:Endpoint, urlPrefix:String = Configuration.apiCommonPath, withConcatenatingPath pathToJoin:String? = nil, parameters:[String:String]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let port = port {
            components.port = port
        }
        if let concatenatingPath = pathToJoin {
            components.path = urlPrefix + endpoint.path() + "/\(concatenatingPath)"
        } else {
            components.path = urlPrefix + endpoint.path()
        }
        if let parameters = parameters {
            components.setQueryItems(with: parameters)
        }
        return components.url
    }
}
extension APIService.APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidURL: return "Failed to create URL"
            case .noResponse: return "No Response from Server"
            case let .unexptectedResponse(response): return "Unexptected Response. Response Status: \(response) | Code- \(ResponseStatus.getStatusCode(by: response))"
            case let .noData(response): return "No Data from Server. Response Status - \(response)| Code- \(ResponseStatus.getStatusCode(by: response))"
            case let .networkError(error): return "Network Error: \(error.localizedDescription)"
            case let .jsonDecodingError(error): return "Failed to Decode data. Error: \(error.localizedDescription)"
            case let .noFirebaseToken(error): return "Firebase Error: \(error.localizedDescription)"
        }
    }
}
