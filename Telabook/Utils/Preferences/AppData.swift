//
//  AppData.swift
//  Telabook
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
    
    @UserDefaultsWrapper(key: .isRememberMeChecked, defaultValue: false)
    static var isRememberMeChecked:Bool
    
    @UserDefaultsWrapper(key: .userId, defaultValue: 0)
    static var userId: Int
    
    @UserDefaultsWrapper(key: .userInfo, defaultValue: nil)
    static var userInfo: UserInfoCodable?
    
    @UserDefaultsWrapper(key: .encryptionKey, defaultValue: "")
    static var encryptionKey: String
    
    @UserDefaultsWrapper(key: .email, defaultValue: "")
    static var email: String
    
    @UserDefaultsEncryptionWrapper(key: .password)
    static var password: String
    
    @UserDefaultsWrapper(key: .firebaseToken, defaultValue: "")
    static var firebaseToken: String

    @UserDefaultsWrapper(key: .companyId, defaultValue: 0)
    static var companyId:Int
    
    @UserDefaultsWrapper(key: .roleId, defaultValue: 0)
    static var roleId:Int
    
    @UserDefaultsWrapper(key: .workerId, defaultValue: 0)
    static var workerId:Int
    
    @UserDefaultsWrapper(key: .selectedTab, defaultValue: .tab1)
    static var selectedTab:TabBarController.Tabs
    
    @UserDefaultsWrapper(key: .appFirstLaunchDate, defaultValue: nil)
    static var appFirstLaunchDate:Date?
    
    @UserDefaultsWrapper(key: .isOnboardingComplete, defaultValue: false)
    static var isOnboardingComplete:Bool
    
    @UserDefaultsWrapper(key: .appLaunchCount, defaultValue: 0)
    static var appLaunchCount:Int
    
    @UserDefaultsWrapper(key: .autoDownloadImageMessagesState, defaultValue: 2)
    private static var autoDownloadImageMessagesStateValue:Int
    
    
    @UserDefaultsWrapper(key: .autoDownloadVideoMessagesState, defaultValue: 0)
    private static var autoDownloadVideoMessagesStateValue:Int
    
    
    static var autoDownloadImageMessagesState:MediaAutoDownloadState {
        get {
            .init(rawValue: autoDownloadImageMessagesStateValue)
        }
        set {
            autoDownloadImageMessagesStateValue = newValue.rawValue
        }
    }
    
    
    
    static var autoDownloadVideoMessagesState:MediaAutoDownloadState {
        get {
            .init(rawValue: autoDownloadVideoMessagesStateValue)
        }
        set {
            autoDownloadVideoMessagesStateValue = newValue.rawValue
        }
    }
    
    
    
    static func restoreAutoDownloadMediaMessagesSettingsDefaults() {
        autoDownloadImageMessagesState = .wifiPlusCellular
        autoDownloadVideoMessagesState = .never
    }
    static var isMediaAutoDownloadSettingsStateAtDefault:Bool {
        autoDownloadImageMessagesState == .wifiPlusCellular &&
            autoDownloadVideoMessagesState == .never
    }
    
    
    
    /// Returns the App User Role from the saved `roleID` in App UserDefaults
    /// - Returns: App User Role as `AppUserRole`
    static func getUserRole() -> AppUserRole {
        AppUserRole.getUserRole(byRoleCode: roleId)
    }
    
    
    static func clearData() {
        for `case` in AppDataKey.allCases {
            if (`case` != .appFirstLaunchDate) &&
                (`case` != .appLaunchCount) &&
                (`case` != .email) &&
                (`case` != .password) &&
                (`case` != .isLoggedIn) &&
                (`case` != .encryptionKey) &&
                (`case` != .isRememberMeChecked) {
                removeObject(forKey: `case`)
            }
        }
    }
    
    static func clearAll() {
        for `case` in AppDataKey.allCases {
            if (`case` != .appFirstLaunchDate) &&
                (`case` != .appLaunchCount) {
                removeObject(forKey: `case`)
            }
        }
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
