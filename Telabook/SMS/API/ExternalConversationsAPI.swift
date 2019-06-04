//
//  ExternalConversationsAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol ExternalConversationsAPIProtocol {
    typealias APITaskCompletion = (Data?, ServiceError?, Error?) -> ()
    var apiURL:String { get }
    func getAPIUrlParamString(_ token:String, _ companyId:String, _ workerId:String) -> String
    func fetch(token:String, companyId:String, workerId:String, completion: @escaping APITaskCompletion)
}

final class ExternalConversationsAPI: NSObject, ExternalConversationsAPIProtocol {
    static let shared = ExternalConversationsAPI()
    
    //MARK: PROTOCOL OBJECTS
    internal var apiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.ExternalConversations)
    }
    internal func getAPIUrlParamString(_ token: String, _ companyId: String, _ workerId:String) -> String {
        return "token=\(token)&worker_id=\(workerId)&Company_id=\(companyId)"
    }
    
    
    
    
    func fetch(token:String, companyId:String, workerId:String, completion: @escaping APITaskCompletion) {
        
        let serviceHost:String = apiURL
        let paramString = getAPIUrlParamString(token, companyId, workerId)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.validateResponseData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    fileprivate func validateResponseData(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APITaskCompletion) {
        if let error = error {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil, .FailedRequest, error)
            }
        } else if let data = data,
            let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(data, nil, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, .InvalidResponse, error)
                }
            }
        } else {
            completion(nil, .Unknown, error)
        }
    }
}
