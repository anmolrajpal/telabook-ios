//
//  AutoResponseAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
final class AutoResponseAPI: NSObject, AutoResponseAPIProtocol {
    static let shared = AutoResponseAPI()
    
    func fetchAutoResponseSettings(token: String, userId: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId
        ]
        guard let url = URLSession.shared.constructURL(path: .ManageAgents, parameters: parameters) else {
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
    
    func saveAutoResponseSettings(token: String, userId: String, callForwardStatus: Bool, voiceMailAutoReplyStatus: Bool, smsAutoReplyStatus: Bool, voiceMailAutoReply: String, smsAutoReply: String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "user_id":userId,
            "call_forward_status":String(callForwardStatus ? 1 : 0),
            "voicemail_auto_reply_status":String(voiceMailAutoReplyStatus ? 1 : 0),
            "sms_auto_reply_status":String(smsAutoReplyStatus ? 1 : 0),
            "voicemail_auto_reply":voiceMailAutoReply,
            "sms_auto_reply":smsAutoReply
        ]
        guard let url = URLSession.shared.constructURL(path: .ManageAgents, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
}
