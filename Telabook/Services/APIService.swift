//
//  APIService.swift
//  matchbook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol APIServiceProtocol {
    func GET<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, completion: @escaping APIService.APICompletion<T>)
    func POST<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, completion: @escaping APIService.APICompletion<T>)
    func constructURL(scheme:String, host:String, port:Int?, forEndpoint endpoint:APIService.Endpoint, withConcatenatingPath pathToJoin:String?, parameters:[String:String]?) -> URL?
}

struct APIService: APIServiceProtocol {
    typealias APICompletion<T> = (Result<T, APIError>) -> Void
    static let shared = APIService()
    struct Configuration {
        static let timeOutInterval:TimeInterval = 15.0
        static let apiURLScheme = URLScheme.http.rawValue
        static let baseURL = Config.APIConfig.baseURL
        static let apiHost = Config.APIConfig.apiHost
        static let port:Int? = Config.APIConfig.port
        static let apiCommonPath:String = Config.APIConfig.urlPrefix
    }
    
    let decoder = JSONDecoder()
    
    enum APIError: Error {
        case invalidURL
        case noResponse
        case noData(response:ResponseStatus)
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
    }
    
    enum Endpoint {
        case SignIn
        
        func path() -> String {
            switch self {
                case .SignIn: return ""
            }
        }
    }
    
    
    func GET<T: Codable>(endpoint: Endpoint,
                         params: [String: String]?,
                         completion: @escaping APICompletion<T>) {
        
        guard let url = constructURL(forEndpoint: .SignIn, parameters: params) else {
            print("Error Log: Unable to Construct URL")
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
        request.httpMethod = HTTPMethod.GET.rawValue
        
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
    
    
    
    func POST<T: Codable>(endpoint: Endpoint,
                         params: [String: String]?,
                         completion: @escaping APICompletion<T>) {
        
        guard let url = constructURL(forEndpoint: .SignIn, parameters: params) else {
            print("Error Log: Unable to Construct URL")
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
        request.httpMethod = HTTPMethod.POST.rawValue
        
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
    
    
    internal func constructURL(scheme:String = Configuration.apiURLScheme, host:String = Configuration.apiHost, port:Int? = Configuration.port, forEndpoint endpoint:Endpoint, withConcatenatingPath pathToJoin:String? = nil, parameters:[String:String]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let port = port {
            components.port = port
        }
        if let concatenatingPath = pathToJoin {
            components.path = endpoint.path() + "/\(concatenatingPath)"
        } else {
            components.path = endpoint.path()
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
            case let .noData(response): return "No Data from Server. Response Status - \(response)"
            case let .networkError(error): return "Network Error: \(error.localizedDescription)"
            case let .jsonDecodingError(error): return "Failed to Decode data. Error: \(error.localizedDescription)"
        }
    }
}
