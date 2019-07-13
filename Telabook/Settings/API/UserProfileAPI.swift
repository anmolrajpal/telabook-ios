//
//  UserProfileAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
final class UserProfileAPI: NSObject, UserProfileAPIProtocol {
    static let shared = UserProfileAPI()
    
    func fetchUserProfile(token: String, userId: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "response":"array"
        ]
        guard let url = URLSession.shared.constructURL(path: .UserProfile, withConcatenatingPath: "\(userId)/edit", parameters: parameters) else {
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
    
    func updateUserProfile(token: String, companyId: String, userId: String, username: String, email: String, roleId: String, firstName: String, lastName: String, phoneNumber: String, backupEmail: String, didId: String, profileImage: String, profileImageURL: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "company_id":companyId,
            "user_id":userId
        ]
        guard let url = URLSession.shared.constructURL(path: .UserProfile, withConcatenatingPath: "\(userId)/edit", parameters: parameters) else {
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
    
    
}
