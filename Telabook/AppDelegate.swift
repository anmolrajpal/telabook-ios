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
import PushKit
import linphonesw
import CallKit



var linphoneCore: Core {
    return LinphoneManager.getLc()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    static let shared = AppDelegate()
    
    let gcmMessageIDKey = "gcm.message_id"
    var window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
    
    
    var callProviderDelegate: CallProviderDelegate!
    var voipRegistry: PKPushRegistry!
    let isVOIPEnabled = false
    
    
    var scheduler: Timer!
    public var proxy_cfg: ProxyConfig!
    private var linphoneLogManager: LinphoneLoggingServiceManager! = nil
    var startedInBackground = false
    //liblinphone call delegate
    var callDelegate: CallDelegate!
    
    var remoteNotificationToken:Data?
    var pushKitToken:Data?
    
    var bgStartId:UIBackgroundTaskIdentifier?
    
    
    func registerForVoIPNotifications() {
        self.voipRegistry = PKPushRegistry(queue: nil)
        self.voipRegistry.delegate = self
        self.voipRegistry.desiredPushTypes = [.voIP]
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
//        initializeLinphoneCore()
        
        UNUserNotificationCenter.current().delegate = self
        registerForVoIPNotifications() // Register for notifications must be done ASAP to give a chance for first SIP register to be done with right token. Specially true in case of remote provisionning or re-install with new type of signing certificate, like debug to release.
        
        let linphoneManager = LinphoneManager.instance()
        let configManager = ConfigManager.instance()
        configManager.setDb(db: linphoneManager.config.getCobject!)
        
        // Set 0 to disable logs. 1 for debug enabled.
        configManager.lpConfigSetInt(value: 0, key: "debugenable_preference")
        
        // Instatntiating Logs
        lpLog = LoggingService.Instance
        linphoneLogManager = try! LinphoneLoggingServiceManager(config: linphoneManager.config, log: lpLog, domain: "Telabook")
        
        
        configManager.lpConfigSetBool(value: true, key: "start_at_boot_preference")
        
        let background_mode = configManager.lpConfigBoolForKey(key: "backgroundmode_preference")
        let start_at_boot = configManager.lpConfigBoolForKey(key: "start_at_boot_preference")
        
        if UIApplication.shared.applicationState == .background {
            // we've been woken up directly to background;
            if (!start_at_boot || !background_mode) {
                // autoboot disabled or no background, and no push: do nothing and wait for a real launch
                //output a log with NSLog, because the ortp logging system isn't activated yet at this time
                print("Linphone launch doing nothing because start_at_boot or background_mode are not activated.")
                return true
            }
            startedInBackground = true
        }
        bgStartId = UIApplication.shared.beginBackgroundTask {
          print("Background task for application launching expired.")
            UIApplication.shared.endBackgroundTask(self.bgStartId!)
        }
        
        LinphoneManager.instance().launchLinphoneCore()
        
        if bgStartId != .invalid {
            UIApplication.shared.endBackgroundTask(bgStartId!)
        }
        
        //output what state the app is in. This will be used to see when the app is started in the background
        lpLog.debug(msg: "app launched with state : \(application.applicationState)")
        lpLog.debug(msg: "FINISH LAUNCHING WITH OPTION : \(String(describing: launchOptions?.description))")
        
        
        if isVOIPEnabled {
            if AppData.isLoggedIn {
                setupVoipAccount()
            }
        } else {
            linphoneCore.clearAllAuthInfo()
            linphoneCore.clearProxyConfig()
        }
        return true
    }
    
    

    /*
    private func initializeLinphoneCore() {
        do {
            
//            LoggingService.Instance.addDelegate(delegate: logManager)
//            LoggingService.Instance.logLevel = LogLevel.Debug
//            Factory.Instance.enableLogCollection(state: LogCollectionState.Enabled)
            /*
            Instanciate a LinphoneCore object
            */
            linphoneCore = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            linphoneCore.callkitEnabled = true
            
            CallManager.instance().setCore(core: linphoneCore.getCobject!)
            CoreManager.instance().setCore(core: linphoneCore.getCobject!)
            try linphoneCore.start()
            
            linphoneCore.confi
            
            let transports = linphoneCore.transports!
            transports.dtlsPort = 0
            transports.tcpPort = 0
            transports.tlsPort = 0
            transports.udpPort = Int(LC_SIP_TRANSPORT_RANDOM)
            
            try linphoneCore.setTransports(newValue: transports)
            
            scheduler = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                /* main loop for receiving notifications and doing background linphonecore work: */
                linphoneCore.iterate()
            }
        } catch {
            print("### \(#function) - \(error)")
        }
    }
    
    private func setPushTokenToLinphone(remoteNotificationToken token: Data?) {
        if remoteNotificationToken == token {
            return
        }
        remoteNotificationToken = token
        configurePushTokenForLinphoneProxyConfigs()
    }
    private func setPushTokenToLinphone(pushKitToken token: Data?) {
        if pushKitToken == token {
            return
        }
        pushKitToken = token
        configurePushTokenForLinphoneProxyConfigs()
    }
    private func configurePushTokenForLinphoneProxyConfigs() {
        let proxies = linphoneCore.proxyConfigList
        proxies.forEach {
            configurePushToken(forLinphoneProxyConfig: $0)
        }
    }
    func configurePushToken(forLinphoneProxyConfig proxyConfig: ProxyConfig) {
        proxyConfig.edit()
        
        let remoteTokenData = remoteNotificationToken
        let pushKitTokenData = pushKitToken
        
        if (remoteTokenData != nil || pushKitTokenData != nil) {
            var remoteTokenString:String?
            var pushKitTokenString:String?
            if let data = remoteTokenData {
               remoteTokenString = data.map { String(format: "%02x", $0) }.joined()
            }
            if let data = pushKitTokenData {
                pushKitTokenString = data.map { String(format: "%02x", $0) }.joined()
            }
            
            let token:String
            let service:String
            
            
            if let remoteToken = remoteTokenString, let pkToken = pushKitTokenString {
                token = String(format: "%@:voip&%@:remote", pkToken, remoteToken)
                service = "voip&remote"
            } else if let remoteToken = remoteTokenString {
                token = String(format: "%@:remote", remoteToken)
                service = "remote"
            } else {
                token = String(format: "%@:voip", pushKitTokenString!)
                service = "voip"
            }
            
            let bundleId = Bundle.main.bundleIdentifier!
            let teamId = Config.teamID
            
            let params = String(format: "pn-provider=apns.dev;pn-prid=%@;pn-param=%@.%@.%@", token, teamId, bundleId, service)
            
            print("Proxy Config: \(String(describing: proxyConfig.identityAddress)) configured for push notifications with contact params: \(params)")
            
            proxyConfig.contactUriParameters = params
//            proxyConfig.contactParameters = ""
            
        } else {
            print("Proxy Config: \(String(describing: proxyConfig.identityAddress)) not configured for push notifications because of no token")
            // no token
            proxyConfig.contactUriParameters = ""
            proxyConfig.contactParameters = ""
        }
        do {
            try proxyConfig.done()
        } catch {
            print("### \(#function): Error configuring proxy: \(proxyConfig) \nError=>\(error)")
        }
    }
    */
    
    
    
    func setupVoipAccount() {
        guard let credentials = AppData.userInfo?.extension,
              let userName = credentials.number,
              let password = credentials.password,
              let domain = credentials.domain else {
//            fatalError("### \(#function) - Extension credentials are unavailable in UserDefaults.")
            printAndLog(message: "### \(#function) - Unable to setup Linphone VOIP account because Extension credentials are unavailable in UserDefaults.", log: .default, logType: .debug)
            UIAlertController.showTelaAlert(title: "Error", message: "Can't set up your VOIP account because required credentials are missing.")
            return
        }
        print("VOIP Credentials: \nUsername => \(userName)\nPassword => \(password)\nDomain => \(domain)")
        
        let sipAddress = "sip:" + userName + "@" + domain
        let instance = Factory.Instance
        
        do {
        
            let address:Address = try instance.createAddress(addr: sipAddress)
            
            
            let natPolicy = try linphoneCore.createNatPolicy()
            natPolicy.stunEnabled = false
            natPolicy.iceEnabled = false
            natPolicy.turnEnabled = false
            natPolicy.upnpEnabled = false
            
            
            proxy_cfg = try linphoneCore.createProxyConfig()
            try proxy_cfg.setIdentityaddress(newValue: address)
            
            proxy_cfg.natPolicy = natPolicy
            
            let serverAddress = address.domain + ";transport=udp"
            
            try proxy_cfg.setRoute(newValue: serverAddress)
            try proxy_cfg.setServeraddr(newValue: serverAddress)
            
            proxy_cfg.pushNotificationAllowed = true
            proxy_cfg.publishEnabled = false
            proxy_cfg.registerEnabled = true
            
            
            let authInfo: AuthInfo = try instance.createAuthInfo(username: address.username, userid: "", passwd: password, ha1: "", realm: "", domain: "")
            linphoneCore.addAuthInfo(info: authInfo)
            
            guard proxy_cfg != nil else {
                printAndLog(message: "### \(#function) - Unable to setup Linphone VOIP account because proxy config is nil", log: .ui, logType: .debug)
                UIAlertController.showTelaAlert(title: "Error", message: "Can't set up your VOIP account right now. Please try again later.")
                return
            }
            try linphoneCore.addProxyConfig(config: proxy_cfg)
            linphoneCore.defaultProxyConfig = proxy_cfg
            
        } catch {
            printAndLog(message: "### \(#function) - Error setting up Linphone VOIP account: => \n\(error)", log: .default, logType: .error)
            UIAlertController.showTelaAlert(title: "Error", message: "Failed to set up your VOIP account. Please try again later.")
        }
    }
    
    
    /*
    private func configureLinphoneProxy(withPushkitRegistrationToken token: String) {
        guard let credentials = AppData.userInfo?.extension,
              let userName = credentials.number,
              let password = credentials.password,
              let domain = credentials.domain else {
            fatalError("### \(#function) - Extension credentials are unavailable in UserDefaults.")
        }
//        let userName = "161242"
//        let password = "$2y$10$/Hh4hul1GZKxWyISyyzsdOIOtUW4/aw7dfGP6cWY25ZL31bm6bpbC"
        let bundleId = Bundle.main.bundleIdentifier!
        let teamId = Config.teamID
        let params = String(format: "pn-provider=apns.dev;pn-prid=%@:voip;pn-param=%@.%@.voip", token, teamId, bundleId)
        do {
            linphoneCore.clearProxyConfig()
            linphoneCore.clearAllAuthInfo()
            
            let sipAddress = "sip:" + userName + "@" + domain
            let instance = Factory.Instance
            let address:Address = try instance.createAddress(addr: sipAddress)
            let authInfo: AuthInfo = try instance.createAuthInfo(username: address.username, userid: "", passwd: password, ha1: "", realm: "", domain: "")
            linphoneCore.addAuthInfo(info: authInfo)
            
            
            let transports = linphoneCore.transports!
            transports.dtlsPort = 0
            transports.tcpPort = 0
            transports.tlsPort = 0
            transports.udpPort = Int(LC_SIP_TRANSPORT_RANDOM)
            
            try linphoneCore.setTransports(newValue: transports)
            
            
            
            
            /*
             
            let natPolicy = try linphoneCore.createNatPolicy()
            natPolicy.stunEnabled = false
            natPolicy.iceEnabled = false
            natPolicy.turnEnabled = false
            natPolicy.upnpEnabled = false
             
            */
            
            proxy_cfg = try linphoneCore.createProxyConfig()
            try proxy_cfg.setIdentityaddress(newValue: address)
            
//            proxy_cfg.natPolicy = natPolicy
            let server_addr = address.domain
            
//            let server_addr = "sip:" + address.domain + ";transport=udp" /*sip.linphone.org*/ /*extract domain address from identity*/
//            try proxy_cfg.setRoute(newValue: address.domain)
            
            try proxy_cfg.setServeraddr(newValue: server_addr) /* we assume domain = proxy server address*/
            
            proxy_cfg.expires = 60
            
            /*
            proxy_cfg.registerEnabled = true /*activate registration for this proxy config*/
            proxy_cfg.publishEnabled = false
            proxy_cfg.pushNotificationAllowed = true
            proxy_cfg.contactUriParameters = params
            */
//            proxy_cfg.publishEnabled = false
            proxy_cfg.pushNotificationAllowed = true
            proxy_cfg.contactUriParameters = params
            
            try linphoneCore.addProxyConfig(config: proxy_cfg) /*add proxy config to linphone core*/
            linphoneCore.defaultProxyConfig = proxy_cfg /*set to default proxy*/
                
            

            
        } catch {
            print("### \(#function) - \(error)")
        }
    }
    */
    
    
    
    
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
//        LinphoneManager.instance().setPushTokenToLinphone(remoteNotificationToken: nil)
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("UserNotifications -> deviceToken :\(token)")
//        LinphoneManager.instance().setPushTokenToLinphone(remoteNotificationToken: deviceToken)
        // With swizzling disabled you must set the APNs token here.
//        Messaging.messaging().apnsToken = deviceToken
    }
    
}




extension AppDelegate: PKPushRegistryDelegate {
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
        guard AppData.isLoggedIn, AppData.userInfo?.extension != nil else {
            printAndLog(message: "Either user not logged in or Extension unavailable in User Defaults", log: .notifications, logType: .error)
            return
        }
//        configureLinphoneProxy(withPushkitRegistrationToken: deviceToken)
//        LinphoneManager.instance().setPushTokenToLinphone(pushKitToken: credentials.token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("### \(#function)")
//        LinphoneManager.instance().setPushTokenToLinphone(pushKitToken: nil)
    }
    
    
    
    
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("\n\n++++++++++++ ---------- •••••••••••••••••••••••••••••••••••••••••••••• ---------- ++++++++++++")
        print("\n\(#function) =>\n\n")
        print(payload.dictionaryPayload)
        print("\n\n++++++++++++ ---------- •••••••••••••••••••••••••••••••••••••••••••••• ---------- ++++++++++++\n\n")
        
        if type == .voIP {
            
             // Extract the call information from the push notification payload
            if let aps = payload.dictionaryPayload["aps"] as? [AnyHashable: Any],
                let handle = aps["caller_id"] as? String {
//                 let uuidString = payload.dictionaryPayload["callUUID"] as? String,
//                 let callUUID = UUID()
                 
                 // Report the call to CallKit, and let it display the call UI.
                 
                
                CallManager.instance().displayIncomingCall(callId: handle)
                
                DispatchQueue.main.async {
                    completion()
                }
                
                /*
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    AppDelegate.shared.displayIncomingCall(uuid: callUUID, handle: handle) { _ in
//                        completion()
//                        //                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//                    }
                    CallManager.instance().displayIncomingCall(callId: handle)
                    
                }
                 */
                linphoneCore.ensureRegistered()
                 // Asynchronously register with the telephony server and
                 // process the call. Report updates to CallKit as needed.
//                 establishConnection(for: callUUID)
                // Linphone goes here
                
            } else {
                fatalError("Unhandled voip notification payload handle key where payload: \(payload.dictionaryPayload)")
            }
        } else {
            fatalError("Unhandled PKPush Type Notification")
        }
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
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        printAndLog(message: "FCM Token: \(fcmToken)", log: .notifications, logType: .debug, isPrivate: true)
        
        guard AppData.isLoggedIn else { return }
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        registerFcmTokenOnServer(token: fcmToken)
    }
    
    /* ------------------------------------------------------------------------------------------------------------ */
    func registerFcmTokenOnServer(token: String) {
        let headers:[HTTPHeader] = [
            HTTPHeader(key: .contentType, value: Header.contentType.json.rawValue)
        ]
        
        struct Body: Encodable {
            let user_id: Int
            let platform: String
            let device_id: String
            let device_name: String
            let fcm_token: String
        }
        let body = Body(user_id: AppData.userId,
                        platform: "iOS",
                        device_id: UIDevice.current.identifierForVendor?.uuidString ?? "",
                        device_name: "\(UIDevice.modelName)•\(UIDevice.current.name)",
                        fcm_token: token)
        let httpBody = try! JSONEncoder().encode(body)
        
        APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .RegisterFCMToken,
                                                                           httpMethod: .POST,
                                                                           httpBody: httpBody,
                                                                           headers: headers,
                                                                           completion: fcmTokenRegistrationCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func fcmTokenRegistrationCompletion(result: Result<APIService.RecurrentResult, APIService.APIError>) {
        switch result {
        case .failure(let error):
            print("Failed to register FCM TOken on server. Should retry at some point. Error: \(error.localizedDescription)")
        case .success(let resultData):
            let serverResult = resultData.result ?? ""
            let message = resultData.message ?? ""
            print("Successfully registered FCM Token on server with server result: \(serverResult) | and message: \(message)")
        }
    }
}


/*
//class LinphoneLoggingServiceManager: LoggingServiceDelegate {
//    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
//        print("Linphone Log: \(message)\n")
//    }
//}
class LinphoneCoreManager: CoreDelegate {
    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String?) {
        print("New registration state \(cstate) for user id \( String(describing: cfg.identityAddress?.asString()))\n")
        if (cstate == RegistrationState.Ok) {
            //running = false
        }
    }
}
class LinphoneCoreManager2: CoreDelegate {
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
        switch cstate {
        case .OutgoingRinging:
            print("It is now ringing remotely !\n")
        case .OutgoingEarlyMedia:
            print("Receiving some early media\n")
        case .Connected:
            print("We are connected !\n")
        case .StreamsRunning:
            print("Media streams established !\n")
        case .End:
            print("Call is terminated.\n")
        case .Error:
            print("Call failure !")
        default:
            print("Unhandled notification \(cstate)\n")
        }
    }
}
 */



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
