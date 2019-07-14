//
//  CustomerAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
final class CustomerAPI: NSObject, CustomerAPIProtocol {
    static let shared = CustomerAPI()
    
    func fetchCustomers(token: String, companyId: String, workerId: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "Company_id":companyId,
            "worker_id":workerId
        ]
        guard let url = URLSession.shared.constructURL(path: .ExternalConversations, parameters: parameters) else {
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
