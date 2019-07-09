//
//  BlacklistAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
final class BlacklistAPI: NSObject, BlacklistAPIProtocol {
    static let shared = BlacklistAPI()
    //MARK: PROTOCOL FETCH BLACKLIST START
    func fetchBlacklist(token:String, companyId:String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "company_id":companyId,
            "response":"array"
        ]
        guard let url = URLSession.shared.constructURL(path: .GetBlacklist, parameters: parameters) else {
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
    //MARK: PROTOCOL FETCH BLACKLIST END
    
    
    
    //MARK: PROTOCOL UNBLOCK NUMBER START
    func unblockNumber(token:String, companyId:String, id:String, number:String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "company_id":companyId,
            "id":id,
            "number":number
        ]
        guard let url = URLSession.shared.constructURL(path: .UnblockNumber, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL UNBLOCK NUMBER END
}
