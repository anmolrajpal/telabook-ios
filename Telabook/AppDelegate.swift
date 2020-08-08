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
    var window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        FirebaseAuthService.shared.addObservers()
        Messaging.messaging().delegate = self
        
//        if Messaging.messaging().fcmToken != nil {
//            let topic = "operator_ios_\(AppData.workerId)"
//            Messaging.messaging().subscribe(toTopic: topic) { error in
//                if let error = error {
//                    print(error)
//                } else {
//                    print("Subscribed to topic: \(topic)")
//                }
//            }
//        }
//
        
     
        UNUserNotificationCenter.current().delegate = self
        
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
//
//        application.registerForRemoteNotifications()
//
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
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("### \(#function)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("### \(#function) - User Info:\n\n \(userInfo)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Unable to convert Data to JSON String")
                return
            }
            print("\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\n\(jsonString)\n\n••• ---------------------------------------------- •••\n\n")
            let notificationCentre = UNUserNotificationCenter.current()
            let externalConversationId = userInfo["external_conversation_id"] as? String
            if let action = userInfo["action"] as? String,
                action == "DELETE_CONVERSATION" {
                var identifiers = [String]()
                notificationCentre.getDeliveredNotifications { notifications in
                    notifications.forEach { notification in
                        let dictionary = notification.request.content.userInfo
                        if let conversationId = dictionary["external_conversation_id"] as? String,
                            conversationId == externalConversationId {
                            identifiers.append(notification.request.identifier)
                        }
                    }
                    notificationCentre.removeDeliveredNotifications(withIdentifiers: identifiers)
                }
            }
            completionHandler(UIBackgroundFetchResult.newData)
        } catch {
            print(error)
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // With swizzling disabled you must set the APNs token here.
         Messaging.messaging().apnsToken = deviceToken
    }
 
}



extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                printAndLog(message: "\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\nUnable to convert Notification Data to JSON String where userInfo: \(userInfo)\n\n••• ---------------------------------------------- •••\n\n", log: .notifications, logType: .error)
                return
            }
            printAndLog(message: "\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\n\(jsonString)\n\n••• ---------------------------------------------- •••\n\n", log: .notifications, logType: .debug)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let payload = try decoder.decode(MessagePayloadJSON.self, from: data)
            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                return
            }
            if let node = payload.node, !node.isBlank {
                if let tabBarController = rootViewController as? TabBarController,
                    let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController,
                    let currentViewController = selectedNavigationController.viewControllers.last as? MessagesController {
                    let currentConversationNode = currentViewController.customer.node
                    if node == currentConversationNode {
                        return
                    }
                }
            }
            completionHandler([.alert, .sound, .badge])
        } catch {
            printAndLog(message: "\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\nuserInfo: \(userInfo)\n\n and Error: \n\n\(error)\n\n••• ---------------------------------------------- •••\n\n", log: .notifications, logType: .error)
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // MARK: - Handle Local Notification Tap
        
        let requestIdentifier = response.notification.request.identifier
        if let key = LocalNotificationService.NotificationKey(rawValue: requestIdentifier) {
            switch key {
                case .imageSavedToLibrary:
                    LocalNotificationItem.imageSavedToPhotosNotificationItem.tapHandler?()
                    completionHandler()
                    return
                default: return
            }
        }
        
        
        // MARK: - Handle Remote Notification Tap
        
        let userInfo = response.notification.request.content.userInfo
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                printAndLog(message: "\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\nUnable to convert Notification Data to JSON String where userInfo: \(userInfo)\n\n••• ---------------------------------------------- •••\n\n", log: .notifications, logType: .error)
                return
            }
            printAndLog(message: "\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\n\(jsonString)\n\n••• ---------------------------------------------- •••\n\n", log: .notifications, logType: .debug)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let payload = try decoder.decode(MessagePayloadJSON.self, from: data)
            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                return
            }
            if let tabBarController = rootViewController as? TabBarController {
                tabBarController.selectedIndex = 0
                if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                    selectedNavigationController.popToRootViewController(animated: false)
                    let agentsController = selectedNavigationController.viewControllers.last! as! AgentsViewController
                    agentsController.messageNotificationPayload = payload
                    completionHandler()
                }
            } else {
                fatalError("Root View Controller must be Tab Bar Controller: \(TabBarController.self)")
            }
        } catch {
            printAndLog(message: "\n\n••• ---------------------------------------------- •••\n\n###\(#function)\n\nuserInfo: \(userInfo)\n\n and Error: \n\n\(error)\n\n••• ---------------------------------------------- •••\n\n", log: .notifications, logType: .error)
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        
        
    }
}



extension AppDelegate : MessagingDelegate {
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        printAndLog(message: "FCM Token: \(fcmToken)", log: .notifications, logType: .info, isPrivate: true)
        /*
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        */
    }
}





// MARK: - •••••••••••••••••• FCM curl request [BEGIN] ••••••••••••••••••••
/// - tag: This is how you test firebase push notifications directly
/*
curl -X "POST" "https://fcm.googleapis.com/fcm/send" \
    -H "Authorization: key=AAAAc9CnvIg:APA91bGbCZpLa90RaU9Le1SXK5doTiig6pPM_Ww17C3jsrW_yrXFSylnTb-kARfnjp7YWyR7fWjqYhCygtJipG-ALB8gTXGgeiIEBV7NfJuZ1oebvZZa1VKXrMWgAv50b2_5ENv6BBnO" \
    -H "Content-Type: application/json" \
    -d $'{
        "notification": {
        "body": "Testing with direct FCM API",
        "title": "Test Message",
        "badge": "0",
        "sound": "default"
    },
    "registration_ids": [
    "db8qjxl3CUVzoqKrT2gf6n:APA91bHYUW6zsfwpBW2L4FUfZQNFRM-7CDF_QkYFIVXHwY-hg8r7AuXAfiFCdYpun217Tia4JAT2gtl9uyDz1HO0P-w_nbMrBCvpb3uOnrwPWhJ3_GumwvqYozHqNeAhMRo4_XDMX6Wk"
    ]
}'
*/
// MARK: - •••••••••••••••••• FCM curl request [End] ••••••••••••••••••••



/*
{
    "id":"994",
    "title":"Message for Esther Luna",
    "body":"Esther 2!!!...",
    "sound":"default",
    "color":"#90CAF9",
    "node":"144-631-Customer",
    "group":"144-631-Customer",
    "groupSummary":"Message for Esther Luna",
    "notify":"1",
    "external_conversation_id":"994",
    "lines":"[{\"date\":1596037530636,\"message\":\"Esther 2!!!\"}]",
    "sender_name":"Hilary Spencer",
    "sender_number":"+18324101983",
    "recipient_did":"+17162411222",
    "recipient_id":"144",
    "worker_name":"Esther Luna",
    "worker_id":"144"
}
*/
/*
{
  "lines" : "[{\"date\":1596040064206,\"message\":\"Bo\"}]",
  "google.c.sender.id" : "497421892744",
  "notify" : "1",
  "node" : "282-626-Customer",
  "external_conversation_id" : "1116",
  "sender_name" : "Esther GLOBAL!!",
  "sender_number" : "+17162411222",
  "body" : "Bo...",
  "group" : "282-626-Customer",
  "aps" : {
    "content-available" : 1
  },
  "groupSummary" : "Message for Christen Eaton",
  "worker_name" : "Christen Eaton",
  "title" : "Message for Christen Eaton",
  "worker_id" : "282",
  "recipient_did" : "+12536520616",
  "gcm.message_id" : "1596040065610880",
  "sound" : "default",
  "color" : "#90CAF9",
  "id" : "1116",
  "recipient_id" : "282"
}
*/



/*
 {
   "key 1" : "value 1",
   "key 5" : "value 5",
   "google.c.a.ts" : "1596045265",
   "key 4" : "value 4",
   "google.c.a.udt" : "0",
   "gcm.notification.sound2" : "default",
   "google.c.sender.id" : "497421892744",
   "gcm.n.e" : "1",
   "google.c.a.e" : "1",
   "aps" : {
     "alert" : {
       "title" : "Test O 143 #3",
       "body" : "Test O 143 #3 iOS"
     },
     "sound" : "default"
   },
   "google.c.a.c_l" : "Test O 143 #3",
   "key 2" : "value 2",
   "key 3" : "value 3",
   "google.c.a.c_id" : "5748676660012981423",
   "gcm.message_id" : "1596045266032678"
 }
 */
