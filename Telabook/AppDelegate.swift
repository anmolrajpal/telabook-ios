//
//  AppDelegate.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import CoreData
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let shared = AppDelegate()
    
    let gcmMessageIDKey = "gcm.message_id"
    var window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        FirebaseAuthService.shared.addObservers()
        Messaging.messaging().delegate = self
        
        if Messaging.messaging().fcmToken != nil {
            let topic = "operator_\(AppData.workerId)"
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    print(error)
                } else {
                    print("Subscribed to topic: \(topic)")
                }
            }
        }
        
        
     
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
//        FirebaseAuthService.shared.monitorAndSaveToken()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        MessageMediaManager.shared.backgroundCompletionHandler = completionHandler
    }
    
    
    
    func launchAppSettings() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    func launchPhotosApp() {
        let url = URL(string: "photos-redirect://")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    
    
    
    
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

    
    static var conversationMediaFolder: URL = {
        let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let appName:String = try! Configuration.value(for: .bundleDisplayName)
        let url = cacheFolder.appendingPathComponent("\(appName)/conversation-media/companies/\(AppData.companyId)", isDirectory: true)
        
        // Create it if it doesn’t exist.
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            } catch {
                let errorMessage = "### \(#function): Failed to create conversation media folder URL: \(error)"
                printAndLog(message: errorMessage, log: .ui, logType: .error)
            }
        }
        return url
    }()
    
    static var agentGalleryMediaFolder: URL = {
        let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let appName:String = try! Configuration.value(for: .bundleDisplayName)
        let url = cacheFolder.appendingPathComponent("\(appName)/agent-gallery/companies/\(AppData.companyId)", isDirectory: true)
        
        // Create it if it doesn’t exist.
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            } catch {
                let errorMessage = "### \(#function): Failed to create agent gallery media folder URL: \(error)"
                printAndLog(message: errorMessage, log: .ui, logType: .error)
            }
        }
        return url
    }()
    
    
    /*
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("Did Recieve Remote Notfication")
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("Did Recieve Remote Notfication Background")
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    */
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
//         Messaging.messaging().apnsToken = deviceToken
    }
 
}



extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification)
        let userInfo = notification.request.content.userInfo
        print("UserNotificationCenter will present notification - userInfo: \(userInfo)")
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("UserNotificationCenter didRecieve Response: \(response) - userInfo: \(userInfo)")
        let requestIdentifier = response.notification.request.identifier
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        if let key = LocalNotificationService.NotificationKey(rawValue: requestIdentifier) {
            switch key {
                case .imageSavedToLibrary:
                    LocalNotificationItem.imageSavedToPhotosNotificationItem.tapHandler?()
            }
        }
        completionHandler()
    }
}



extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let topic = "operator_\(AppData.workerId)"
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print(error)
            } else {
                print("Subscribed to topic: \(topic)")
            }
        }
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
