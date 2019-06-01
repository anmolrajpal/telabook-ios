//
//  AuthenticationService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation

final class AuthenticationService: NSObject {
    static let shared = AuthenticationService()
    typealias UserInfoFetchCompletion = (UserInfoCodable?, ServiceError?, Error?) -> ()
    
    func authenticateViaToken(token:String, completion: @escaping UserInfoFetchCompletion) {
        let serviceHost:String = Config.ServiceConfig.getServiceHostUri(.AuthenticationViaToken)
        let paramString = Config.ServiceConfig.getAuthViaTokenParamString(token: token)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.validateResponseData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    private func validateResponseData(data: Data?, response: URLResponse?, error: Error?, completion: @escaping UserInfoFetchCompletion) {
        if let error = error {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil, .FailedRequest, error)
            }
        } else if let data = data,
            let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                processResponseData(data: data, completion: completion)
            } else {
                DispatchQueue.main.async {
                    completion(nil, .InvalidResponse, error)
                }
            }
        } else {
            completion(nil, .Unknown, error)
        }
    }
    private func processResponseData(data: Data, completion: @escaping UserInfoFetchCompletion) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(UserInfoCodable.self, from: data)
            DispatchQueue.main.async {
                completion(response, nil, nil)
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                completion(nil, .Internal, error)
            }
        }
    }
}
