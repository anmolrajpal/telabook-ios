//
//  UserDefaults.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case emailId
        case password
        case appLaunchCount
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
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func setEmailId(emailId: String) {
        set(emailId, forKey: UserDefaultsKeys.emailId.rawValue)
    }
    func getEmailId() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.emailId.rawValue) ?? ""
    }
    func setPassword(password: String) {
        set(password, forKey: UserDefaultsKeys.password.rawValue)
    }
    func getPassword() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.password.rawValue)
    }
    static func clearUserData() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.emailId.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.password.rawValue)
    }
}
