//
//  QuickResponsesAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
final class QuickResponsesAPI: NSObject, QuickResponsesAPIProtocol {
    static let shared = QuickResponsesAPI()
    
    
    func fetchQuickResponses(token: String, userId: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId
        ]
        guard let url = URLSession.shared.constructURL(path: .QuickResponses, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    
    func addQuickResponse(token: String, userId: String, answer: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId,
            "answer":answer
        ]
        guard let url = URLSession.shared.constructURL(path: .QuickResponses, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    
    func updateQuickResponse(token: String, userId: String, answer: String, responseId:String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId,
            "answer":answer
        ]
        guard let url = URLSession.shared.constructURL(path: .QuickResponses, withConcatenatingPath: responseId, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.PUT.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    func deleteQuickResponse(token: String, userId: String, responseId:String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId
        ]
        guard let url = URLSession.shared.constructURL(path: .QuickResponses, withConcatenatingPath: responseId, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.DELETE.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
}
