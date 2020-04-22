//
//  AuthenticationService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
final class AuthenticationService: NSObject {
    static let shared = AuthenticationService()
    
    typealias UserInfoFetchCompletion = (UserInfoCodable?, ServiceError?, Error?) -> ()
    
    func authenticateViaToken(token:String, completion: @escaping UserInfoFetchCompletion) {
        let serviceHost:String = Config.ServiceConfig.getServiceHostUri(.AuthenticationViaToken)
//        let paramString = Config.ServiceConfig.getAuthViaTokenParamString(token: token)
        let authorizationHeader = "Bearer \(token)"
        let url = URL(string: serviceHost)!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Config.ServiceConfig.timeoutInterval)
        request.httpMethod = httpMethod.POST.rawValue
        request.setValue(authorizationHeader, forHTTPHeaderField: Header.headerName.Authorization.rawValue)
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
                print(response.statusCode)
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
    
    
    //MARK: FORGOT PASSWORD
    func forgotPassword(for email:String, completion: @escaping APICompletion) {
        let parameters:[String:String] = [
            "email":email
        ]
        guard let url = URLSession.shared.constructURL(path: .ForgotPassword, parameters: parameters) else {
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
            print("Status Code => \(response.statusCode)")
            let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: response.statusCode)
            completion(responseStatus, data, nil, nil)
        } else {
            DispatchQueue.main.async {
                completion(nil, nil, .Unknown, nil)
            }
        }
    }
    
    
    
    
    func callSignOutSequence() {
        print("Signing out")
        FirebaseAuthService.shared.signOut { (error) in
            guard error == nil else {
                self.callSignOutSequence()
                return
            }
            self.dumpCoreDataStorage()
            self.signOut()
        }
    }
    fileprivate func signOut() {
        let loginViewController = LoginViewController()
        loginViewController.isModalInPresentation = true
        AppData.clear()
        AppData.isLoggedIn = false
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard (rootVC?.presentedViewController as? LoginViewController) == nil else {
            print("RootVC presentedviewcontroller is a Login View Controller")
            return
        }
        print("Root VC isn't Login VC")
        if let rootVC = rootVC {
            rootVC.presentedViewController?.dismiss(animated: true, completion: nil)
            if let tbc = rootVC.tabBarController as? TabBarController {
                print("Hurray.... I'm loving this one")
                tbc.isLoaded = false
                tbc.present(loginViewController, animated: true, completion: {
                    tbc.selectedViewController?.view.isHidden = true
                    tbc.viewControllers = nil
                })
            } else {
                print("Holy noooooo!!!! I hate this one")
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = TabBarController()
            }
        } else {
            print("OMG I super hate this one")
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = TabBarController()
        }
    }
    fileprivate func dumpCoreDataStorage() {
        do {
            
            let context = PersistenceService.shared.persistentContainer.viewContext
            let entityNames = [String(describing: ExternalConversation.self), String(describing: InternalConversation.self), String(describing: Permission.self), String(describing: UserObject.self)]
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                do {
                    let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                    _ = objects.map{$0.map{context.delete($0)}}
                    PersistenceService.shared.saveContext()
                } catch let error {
                    print("ERROR DELETING : \(error)")
                }
            }
        }
    }
    
}
