//
//  ExternalConversationsAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
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
    func fetch(token:String, companyId:String, workerId:String, isArchived:Bool, completion: @escaping APICompletion) {
        
        let serviceHost:String = apiURL
        let paramString = getAPIUrlParamString(token, companyId, workerId, isArchived)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
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
    func handleArchiving(token:String, companyId:String, conversationId:String, markArchive:Bool, completion: @escaping APICompletion) {
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
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL ARCHIVING/UNARCHIVING EXTERNAL CONVERSATION END
    
    
    
    
    
    
    
    
    
    //MARK: PROTOCOL BLOCK NUMBER START
    func blockNumber(token:String, companyId:String, conversationId:String, number:String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "token":token,
            "company_id":companyId,
            "external_conversation_id":conversationId,
            "number":number
        ]
        guard let url = URLSession.shared.constructURL(path: .GetBlacklist, parameters: parameters) else {
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
    //MARK: PROTOCOL BLOCK NUMBER END
    
    
    
    
    
    
    
    
    
    
    
    
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
    
    
    
    //MARK: PROTOCOL SEND MESSAGE START
    internal var sendMessageApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.SendMessage)
    }
    internal var directMessageApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.DirectMessage)
    }
    internal func sendMessageParamString(_ token: String, _ conversationId:String, message:String, type:ChatMessageType) -> [String:String] {
        let mmsParameters:[String:String] = [
            "token":token,
            "id":conversationId,
            "imageURL":message
        ]
        let smsParameters:[String:String] = [
            "token":token,
            "id":conversationId,
            "message":message
        ]
        switch type {
        case .SMS: return smsParameters
        case .MMS: return mmsParameters
        }
    }
    func sendMessage(token:String, conversationId:String, message:String, type: ChatMessageType, isDirectMessage:Bool, completion: @escaping APICompletion) {
        
        let parameters = sendMessageParamString(token, conversationId, message: message, type: type)
        guard let directMessageURL = URLSession.shared.constructURL(path: .DirectMessage, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        guard let sendMessageURL = URLSession.shared.constructURL(path: .SendMessage, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }
        let url:URL = isDirectMessage ? directMessageURL : sendMessageURL
     
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL SEND MESSAGE END
    
    
    
    //MARK: PROTOCOL START NEW CONVERSATOIN :BEGIN
    internal var newConversationApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.ExternalConversations)
    }
    internal func newConversationParamString(_ token: String, _ companyId:String, _ phoneNumber:String, _ senderId:String) -> String {
        return "token=\(token)&company_id=\(companyId)&phone_number=\(phoneNumber)&sender_id=\(senderId)"
    }
    func startNewConversation(token:String, companyId:String, phoneNumber:String, senderId: String, completion: @escaping APICompletion) {
        let serviceHost = newConversationApiURL
        let paramString = newConversationParamString(token, companyId, phoneNumber, senderId)
        let params = paramString.data(using: String.Encoding.ascii, allowLossyConversion: false)
        let uri = serviceHost
        //        print(uri)
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.addValue(Header.contentType.urlEncoded.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        request.httpBody = params
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL START NEW CONVERSATION: END
    
    
    
    //MARK: PROTOCOL GET CUSTOMER DETAILS :BEGIN
    internal var getCustomerDetailsApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.GetCustomerDetails)
    }
    internal func getCustomerDetailsParamString(_ token: String, _ companyId:String, _ customerId:String) -> String {
        return "token=\(token)&company_id=\(companyId)&customer_id=\(customerId)"
    }
    func getCustomerDetails(token:String, companyId:String, customerId:String, completion: @escaping APICompletion) {
        let serviceHost = getCustomerDetailsApiURL
        let paramString = getCustomerDetailsParamString(token, companyId, customerId)
        let uri = serviceHost + paramString
        let url = URL(string: uri)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.GET.rawValue
        request.addValue(Header.contentType.json.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL GET CUSTOMER DETAILS: END
    
    
    
    //MARK: PROTOCOL EDIT CUSTOMER DETAILS :BEGIN
    internal var updateCustomerDetailsApiURL:String {
        return Config.ServiceConfig.getServiceHostUri(.UpdateCustomerDetails)
    }
    internal func getUpdateCustomerDetailsParameters(_ token: String, _ companyId:String, _ customerId:String, _ workerId:String, _ name:String, _ surname:String, _ addressOne:String, _ addressTwo:String, _ description:String, _ star:ConversationPriority, _ isCustomer:Bool, _ isNameActive:Bool) -> [String:String] {
        let parameters:[String:String] = [
            "token":token,
            "company_id":companyId,
            "customer_id":customerId,
            "worker_id":workerId,
            "internal_address_book_names":name,
            "internal_address_book_surnames":surname,
            "internal_address_book_address_one":addressOne,
            "internal_address_book_address_two":addressTwo,
            "internal_address_book_description":description,
            "internal_address_book_star":String(ConversationPriority.getPriorityCode(by: star)),
            "internal_address_book_is_custumer":String(isCustomer ? 1 : 0),
            "internal_address_book_active_name":String(isNameActive ? 1 : 0)
        ]
        return parameters
//        return "token=\(token)&company_id=\(companyId)&customer_id=\(customerId)&worker_id=\(workerId)&internal_address_book_names=\(name)&internal_address_book_surnames=\(surname)&internal_address_book_address_one=\(addressOne)&internal_address_book_address_two=\(addressTwo)&internal_address_book_description=\(description)&internal_address_book_star=\(ConversationPriority.getPriorityCode(by: star))&internal_address_book_is_custumer=\(isCustomer ? 1 : 0)&internal_address_book_active_name=\(isNameActive ? 1 : 0)"
    }
    func updateCustomerDetails(token:String, companyId:String, customerId:String, workerId:String, name:String, surname:String, addressOne:String, addressTwo:String, description:String, star:ConversationPriority, isCustomer:Bool, isNameActive:Bool, completion: @escaping APICompletion) {
        let parameters = getUpdateCustomerDetailsParameters(token, companyId, customerId, workerId, name, surname, addressOne, addressTwo, description, star, isCustomer, isNameActive)
        guard let url = URLSession.shared.constructURL(path: .UpdateCustomerDetails, parameters: parameters) else {
            print("Error: Unable to construct URL")
            DispatchQueue.main.async {
                completion(nil, nil, .Internal, NSError(domain: "", code: ResponseStatus.getStatusCode(by: .BadRequest), userInfo: nil))
            }
            return
        }

        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
//        request.addValue(Header.contentType.urlEncoded.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    //MARK: PROTOCOL EDIT CUSTOMER DETAILS: END
    
    
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
