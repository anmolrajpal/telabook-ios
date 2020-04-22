//
//  AppData.swift
//  matchbook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import Combine


struct AppData {
    static let userDefaults = UserDefaults.standard
    
    @UserDefaultsWrapper(key: .isLoggedIn, defaultValue: false)
    static var isLoggedIn:Bool
    
    @UserDefaultsWrapper(key: .userId, defaultValue: nil)
    static var userId: String?
    
    @UserDefaultsWrapper(key: .userInfo, defaultValue: nil)
    static var userInfo: UserInfoCodable?
    
    @UserDefaultsWrapper(key: .email, defaultValue: nil)
    static var email: String?
    
    @UserDefaultsWrapper(key: .password, defaultValue: nil)
    static var password: String?
    //    @UserDefaultsWrapper(key: .selectedTab, defaultValue: TabBarView.Tab.tab1)
    //    static var selectedTab:TabBarView.Tab
    
    @UserDefaultsWrapper(key: .appFirstLaunchDate, defaultValue: nil)
    static var appFirstLaunchDate:Date?
    
    @UserDefaultsWrapper(key: .isOnboardingComplete, defaultValue: false)
    static var isOnboardingComplete:Bool
    
    @UserDefaultsWrapper(key: .appLaunchCount, defaultValue: 0)
    static var appLaunchCount:Int
    
    
    
    static func clear() {
        AppDataKey.allCases.forEach({ removeObject(forKey: $0) })
    }
    static func removeObject(forKey key: AppDataKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
}

/*
final class AppData: ObservableObject {
    static let userDefaults = UserDefaults.standard
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    private var settingsStoreCancellable:AnyCancellable!
    private var cancellable:AnyCancellable?
    
    @UserDefaultsWrapper(key: .isLoggedIn, defaultValue: false)
    var isLoggedIn:Bool
    
    @UserDefaultsWrapper(key: .userId, defaultValue: nil)
    var userId: String?
    
//    @UserDefaultsWrapper(key: .selectedTab, defaultValue: TabBarView.Tab.tab1)
//    var selectedTab:TabBarView.Tab
    
    @UserDefaultsWrapper(key: .appFirstLaunchDate, defaultValue: nil)
    var appFirstLaunchDate:Date?
    
    @UserDefaultsWrapper(key: .isOnboardingComplete, defaultValue: false)
    var isOnboardingComplete:Bool
    
    @UserDefaultsWrapper(key: .appLaunchCount, defaultValue: 0)
    var appLaunchCount:Int
    
    
//    @UserDefaultsWrapper(key: .settingsStore, defaultValue: SettingsStore())
//    var settingsStore:SettingsStore { willSet { objectWillChange.send(); print("Setting store will set") } }
    
    init() {
//        settingsStoreCancellable = settingsStore.objectWillChange.sink { (_) in
//            self.objectWillChange.send()
//        }
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .subscribe(objectWillChange)
    }
//    deinit {
//        settingsStoreCancellable.cancel()
//    }
    static func clear() {
        AppDataKey.allCases.forEach({ removeObject(forKey: $0) })
    }
    static func removeObject(forKey key: AppDataKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
}
*/
