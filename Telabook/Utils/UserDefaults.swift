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
