//
//  CallGroupsAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
final class CallGroupsAPI: NSObject, CallGroupsAPIProtocol {
    static let shared = CallGroupsAPI()
    
    weak var fetchCallGroupsDataTask:URLSessionDataTask?
    weak var toggleCallGroupDataTask:URLSessionDataTask?
    
    func fetchCallGroups(token: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token
        ]
        guard let url = URLSession.shared.constructURL(path: .CallGroups, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        
        fetchCallGroupsDataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }
        fetchCallGroupsDataTask?.resume()
    }
    
    func toggleCallGroupStatus(token: String, groupId: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token
        ]
        guard let url = URLSession.shared.constructURL(path: .CallGroups, withConcatenatingPath: groupId, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.PUT.rawValue
        request.addValue(Header.HeaderValue.XMLHttpRequest.rawValue, forHTTPHeaderField: Header.headerName.xRequestedWith.rawValue)
        
        toggleCallGroupDataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        toggleCallGroupDataTask?.resume()
    }
    
    
}
