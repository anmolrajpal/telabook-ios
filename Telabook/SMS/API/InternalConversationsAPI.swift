//
//  InternalConversationsAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol InternalConversationsAPIProtocol {
    typealias APITaskCompletion = (Data?, ServiceError?, Error?) -> ()
    var apiURL:String { get }
//    var apiURLParams: ((String, String) -> String) { get }
    func getAPIUrlParamString(token:String, companyId:String) -> String
    func fetch(token:String, companyId:String, completion: @escaping APITaskCompletion)
}

final class InternalConversationsAPI: NSObject, InternalConversationsAPIProtocol {
    internal var apiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.InternalConversations)
    }
    internal func getAPIUrlParamString(token: String, companyId: String) -> String {
        return "token=\(token)&company_id=\(companyId)"
    }
    
    static let shared = InternalConversationsAPI()
    
    
    func fetch(token:String, companyId:String, completion: @escaping APITaskCompletion) {
        
        let serviceHost:String = apiURL
        let paramString = getAPIUrlParamString(token: token, companyId: companyId)
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
//                processResponseData(data: data, completion: completion)
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
    /*******
    fileprivate func processResponseData(data: Data, completion: @escaping APITaskCompletion) {
        do {
            guard let context = CodingUserInfoKey.context else {
                fatalError("Failed to retrieve managed object context")
            }
            let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[context] = managedObjectContext
            let response = try decoder.decode([InternalConversation].self, from: data)
            try managedObjectContext.save()
            DispatchQueue.main.async {
                completion(response, nil, nil)
            }
        } catch let error {
            print("Error Processing Response Data: \(error)")
            DispatchQueue.main.async {
                completion(nil, .Internal, error)
            }
        }
    }
    *******/
 }
