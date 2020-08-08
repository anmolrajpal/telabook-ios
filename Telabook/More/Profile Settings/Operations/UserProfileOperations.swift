//
//  UserProfileOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

struct UserProfileOperations {
    
}



/// Update the user's profile on the server.
class UpdateUserProfileOnServer_Operation: Operation {
    var result: Result<Bool, APIService.APIError>?
    
    struct Body: Encodable {
        let company_id:String
        let address:String
        let backup_email:String
        let email:String
        let name:String
        let last_name:String
        let phone_number:String
        let profile_image:String
        let profile_image_url:String
    }
    
    private let encoder = JSONEncoder()
    private var downloading = false
    
    
    
    private let params:[String:String]
    private let headers:[HTTPHeader] = [
        HTTPHeader(key: .contentType, value: "application/json"),
        HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
    ]
    private let httpBody:Data
    init(address: String, backupEmail: String, email: String, firstName: String, lastName: String, phoneNumber: String, profileImage: String, profileImageUrl: String) {
        let companyID = String(AppData.companyId)
        params = [
            "company_id":companyID
        ]
        let body = Body(company_id: companyID,
                        address: address,
                        backup_email: backupEmail,
                        email: email,
                        name: firstName,
                        last_name: lastName,
                        phone_number: phoneNumber,
                        profile_image: profileImage,
                        profile_image_url: profileImageUrl)
        
        httpBody = try! encoder.encode(body)
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        finish(result: .failure(.cancelled))
    }
    
    func finish(result: Result<APIService.RecurrentResult, APIService.APIError>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        
        let errorMessage = "Error: No results from server"
        
        guard case let .success(resultData) = result else {
            if case let .failure(error) = result {
                self.result = .failure(error)
                didChangeValue(forKey: #keyPath(isFinished))
                didChangeValue(forKey: #keyPath(isExecuting))
            }
            return
        }
        guard let serverResultValue = resultData.result else {
            self.result = .failure(.resultError(message: errorMessage))
            didChangeValue(forKey: #keyPath(isFinished))
            didChangeValue(forKey: #keyPath(isExecuting))
            return
        }
        let serverResult = ServerResult(rawValue: serverResultValue)
        guard serverResult == .success else {
            self.result = .failure(.resultError(message: resultData.message ?? errorMessage))
            didChangeValue(forKey: #keyPath(isFinished))
            didChangeValue(forKey: #keyPath(isExecuting))
            return
        }
        self.result = .success(true)
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(.cancelled))
            return
        }
        let userId = AppData.userId
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .UpdateUserProfile(userId: userId), httpMethod: .PUT, params: params, httpBody: httpBody, headers: headers, completion: finish)
    }
}
