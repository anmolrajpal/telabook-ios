//
//  ScheduleMessageAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
final class ScheduleMessageAPI: NSObject, ScheduleMessageAPIProtocol {
    static let shared = ScheduleMessageAPI()
    
    func fetchScheduledMessages(token: String, userId: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId
        ]
        guard let url = URLSession.shared.constructURL(path: .ScheduleMessage, parameters: parameters) else {
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
    
    func scheduleMessage(token: String, customerId: String, workerId: String, text: String, date: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "customer_id":customerId,
            "date":date,
            "text":text,
            "worker_id":workerId
        ]
        guard let url = URLSession.shared.constructURL(path: .ScheduleMessage, parameters: parameters) else {
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
