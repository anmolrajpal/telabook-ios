//
//  ExternalConversationsAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation

final class ExternalConversationsAPI: NSObject, ExternalConversationsAPIProtocol {
    static let shared = ExternalConversationsAPI()
    
    //MARK: PROTOCOL EXTERNAL CONVERSATIONS FETCH START
    internal var apiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.ExternalConversations)
    }
    internal func getAPIUrlParamString(_ token: String, _ companyId: String, _ workerId:String, _ isArchived:Bool) -> String {
        if !isArchived {
            return "token=\(token)&worker_id=\(workerId)&company_id=\(companyId)"
        } else {
            return "token=\(token)&worker_id=\(workerId)&company_id=\(companyId)&category=archived"
        }
    }
    func fetch(token:String, companyId:String, workerId:String, isArchived:Bool, completion: @escaping APITaskCompletion) {
        
        let serviceHost:String = apiURL
        let paramString = getAPIUrlParamString(token, companyId, workerId, isArchived)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponseData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL EXTERNAL CONVERSATIONS FETCH END
    
    
    //MARK: PROTOCOL ARCHIVING/UNARCHIVING EXTERNAL CONVERSATION START
    internal var archiveECApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.ArchiveExternalConversation)
    }
    internal var unarchiveECApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.RemoveArchivedExternalConversation)
    }
    internal func handleArchivingParamString(_ token: String, _ companyId: String, _ conversationId:String) -> String {
        return "token=\(token)&company_id=\(companyId)&external_conversation_id=\(conversationId)"
    }
    func handleArchiving(token:String, companyId:String, conversationId:String, markArchive:Bool, completion: @escaping APITaskCompletion) {
        let serviceHost:String
        if markArchive {
            serviceHost = archiveECApiURL
        } else {
            serviceHost = unarchiveECApiURL
        }
        let paramString = handleArchivingParamString(token, companyId, conversationId)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponseData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL ARCHIVING/UNARCHIVING EXTERNAL CONVERSATION END
    
    
    //MARK: PROTOCOL FETCH BLACKLIST START
    internal var fetchBlacklistApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.GetBlacklist)
    }
    internal func fetchBlacklistParamString(_ token: String, _ companyId: String) -> String {
        return "token=\(token)&company_id=\(companyId)&response=array"
    }
    func fetchBlacklist(token:String, companyId:String, completion: @escaping APITaskCompletion) {
        let serviceHost = fetchBlacklistApiURL
        let paramString = fetchBlacklistParamString(token, companyId)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponseData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL FETCH BLACKLIST END
    
    
    //MARK: PROTOCOL HANDLE BLOCKING START
    internal var blockNumberApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.GetBlacklist)
    }
    internal var unblockNumberApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.UnblockNumber)
    }
    internal func handleBlockingParamString(_ token: String, _ companyId: String, _ conversationId:String, _ number:String, _ markBlock:Bool) -> String {
        if markBlock {
            return "token=\(token)&company_id=\(companyId)&external_conversation_id=\(conversationId)&number=\(number)"
        } else {
            return "token=\(token)&company_id=\(companyId)&id=\(conversationId)&number=\(number)"
        }
    }
    func handleBlocking(token:String, companyId:String, conversationId:String, number:String, markBlock:Bool, completion: @escaping APITaskCompletion) {
        let serviceHost:String
        if markBlock {
            serviceHost = blockNumberApiURL
        } else {
            serviceHost = unblockNumberApiURL
        }
        let paramString = handleBlockingParamString(token, companyId, conversationId, number, markBlock)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponseData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL HANDLE BLOCKING END
    
    
    
    //MARK: PROTOCOL CHANGE CONVERSATION COLOR START
    internal var setColorApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.ChangeColor)
    }
    internal func setColorParamString(_ token: String, _ companyId: String, _ conversationId:String, _ colorCode:String) -> String {
        return "token=\(token)&company_id=\(companyId)&external_conversation_id=\(conversationId)&colour=\(colorCode)"
    }
    func setColor(token:String, companyId:String, conversationId:String, colorCode:String, completion: @escaping APICompletion) {
        let serviceHost = setColorApiURL
        let paramString = setColorParamString(token, companyId, conversationId, colorCode)
        let uri = serviceHost + paramString
        print(uri)
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL CHANGE CONVERSATION COLOR END
    typealias APICompletion = (ResponseStatus?, Data?, ServiceError?, Error?) -> ()
    //MARK: HANDLE RESPONSE DATA
    internal func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APICompletion) {
        if let error = error {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil, nil, .FailedRequest, error)
            }
        } else if let data = data,
            let response = response as? HTTPURLResponse {
            let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: response.statusCode)
            completion(responseStatus, data, nil, nil)
        } else {
            DispatchQueue.main.async {
                completion(nil, nil, .Unknown, nil)
            }
        }
    }
    
    
    
    //MARK: HANDLE RESPONSE DATA
    internal func handleResponseData(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APITaskCompletion) {
        if let error = error {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil, .FailedRequest, error)
            }
        } else if let data = data,
            let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 200..<299:
                DispatchQueue.main.async {
                    completion(data, nil, nil)
                }
            default:
                DispatchQueue.main.async {
                    completion(nil, .InvalidResponse, nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(nil, .Unknown, nil)
            }
        }
    }
}
