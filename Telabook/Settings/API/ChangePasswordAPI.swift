//
//  ChangePasswordAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 15/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
final class ChangePasswordAPI: NSObject, ChangePasswordAPIProtocol {
    static let shared = ChangePasswordAPI()
    
    func changePassword(token: String, currentPassword: String, newPassword: String, confirmationPassword: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "current_password":currentPassword,
            "password":newPassword,
            "password_confirmation":confirmationPassword
        ]
        guard let url = URLSession.shared.constructURL(path: .ChangePassword, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.HeaderValue.XMLHttpRequest.rawValue, forHTTPHeaderField: Header.headerName.xRequestedWith.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
}
