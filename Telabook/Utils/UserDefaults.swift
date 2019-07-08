//
//  UserDefaults.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import MessageKit
extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case emailId
        case password
        case appLaunchCount
        case token
        case companyId
        case workerId
        case roleId
        case userId
        case userName
        case userObject
        case currentSender
        case savedCredentials
    }
    
    var appLaunchCount:Int? {
        get {
            return integer(forKey: UserDefaultsKeys.appLaunchCount.rawValue)
        }
        set (count) {
            set(count!, forKey: UserDefaultsKeys.appLaunchCount.rawValue)
            synchronize()
        }
    }
    var isRememberMeChecked:Bool? {
        get {
            return bool(forKey: UserDefaultsKeys.savedCredentials.rawValue)
        }
        set (mark) {
            set(mark, forKey: UserDefaultsKeys.savedCredentials.rawValue)
        }
    }
//    var userObject:UserInfoCodable.User? {
//        get {
//            return object(forKey: UserDefaultsKeys.userObject.rawValue) as? UserInfoCodable.User
//        }
//        set (user) {
//            set(user, forKey: UserDefaultsKeys.userObject.rawValue)
//        }
//    }
    var currentSender:Sender! {
        get {
            return Sender(id: string(forKey: UserDefaultsKeys.userId.rawValue)!, displayName: string(forKey: UserDefaultsKeys.userName.rawValue)!)
        }
        set (sender) {
            set(sender.id, forKey: UserDefaultsKeys.userId.rawValue)
            set(sender.displayName, forKey: UserDefaultsKeys.userName.rawValue)
        }
    }
//    func getCurrentSender() -> Sender {
//        return Sender(id: "123", displayName: "Anmol Rajpal")
////        return Sender(id: String(userObject?.id ?? 0), displayName:
////            (!(userObject?.lastName?.isEmpty ?? true)) ? "\(userObject?.name ?? "nil") \(userObject?.lastName ?? "nil")" : userObject?.name ?? "nil")
//    }
    
    //MARK: LOGGED IN BOOL
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    
    //MARK: GET-SET TOKEN
    func setToken(token: String) {
        set(token, forKey: UserDefaultsKeys.token.rawValue)
    }
    func getToken() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.token.rawValue)!
    }
    func updateToken(token:String) {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token.rawValue)
        self.setToken(token: token)
    }
    
    
    //MARK: GET-SET EMAIL ID
    func setEmailId(emailId: String) {
        set(emailId, forKey: UserDefaultsKeys.emailId.rawValue)
    }
    func getEmailId() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.emailId.rawValue)!
    }
    
    
    //MARK: GET-SET PASSWORD
    func setPassword(password: String) {
        set(password, forKey: UserDefaultsKeys.password.rawValue)
    }
    func getPassword() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.password.rawValue)!
    }
    
    
    //MARK: GET-SET COMPANY ID
    func setCompanyId(companyId: Int) {
        set(companyId, forKey: UserDefaultsKeys.companyId.rawValue)
    }
    func getCompanyId() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsKeys.companyId.rawValue)
    }
    
    
    
    //MARK: GET-SET WORKER ID
    func setWorkerId(workerId: Int) {
        set(workerId, forKey: UserDefaultsKeys.workerId.rawValue)
    }
    func getWorkerId() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsKeys.workerId.rawValue)
    }
    
    
    //MARK: GET-SET ROLE
    func setRoleId(roleId:Int) {
        set(roleId, forKey: UserDefaultsKeys.roleId.rawValue)
    }
    func getRoleId() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsKeys.roleId.rawValue)
    }
    
    static func clearUserData() {
//        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.emailId.rawValue)
//        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.password.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.companyId.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.workerId.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.roleId.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentSender.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userName.rawValue)
        
    }
}
