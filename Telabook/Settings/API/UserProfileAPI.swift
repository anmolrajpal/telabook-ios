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
    
    func updateUserProfile(token: String, userId: String, email: String, firstName: String, lastName: String, phoneNumber: String, backupEmail: String, address: String, profileImage: String, profileImageURL: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "email":email,
            "name":firstName,
            "last_name":lastName,
            "phone_number":phoneNumber.replacingOccurrences(of: "+", with: "%2b"),
            "backup_email":backupEmail,
            "address":address,
            "profile_image":profileImage,
            "profile_image_url":profileImageURL
        ]
        guard let url = URLSession.shared.constructURL(path: .UserProfile, withConcatenatingPath: userId, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        print(url)
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.PUT.rawValue
        request.addValue(Header.headerName.xRequestedWith.rawValue, forHTTPHeaderField: Header.headerName.xRequestedWith.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
}
