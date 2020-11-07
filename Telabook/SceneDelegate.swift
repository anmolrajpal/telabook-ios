//
//  SceneDelegate.swift
//  Wealth Land
//
//  Created by Anmol Rajpal on 26/10/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase
import linphonesw

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
//    var startedInBackground = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let tbc = TabBarController()
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        window?.windowScene = windowScene
        window?.rootViewController = tbc
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        if !AppDelegate.shared.startedInBackground {
            AppDelegate.shared.startedInBackground = true
            // initialize UI
//            [PhoneMainView.instance startUp];
            // TODO: -
        }
        let instance = LinphoneManager.instance()
        instance.becomeActive()
        /*
        if (instance.fastAddressBook.needToUpdate) {
            //Update address book for external changes
            if (PhoneMainView.instance.currentView == ContactsListView.compositeViewDescription || PhoneMainView.instance.currentView == ContactDetailsView.compositeViewDescription) {
                [PhoneMainView.instance changeCurrentView:DialerView.compositeViewDescription];
            }
            [instance.fastAddressBook fetchContactsInBackGroundThread];
            instance.fastAddressBook.needToUpdate = FALSE;
        }
        */
        guard let tbc = window?.rootViewController as? TabBarController else {
            fatalError()
        }
        if let currentCall = linphoneCore.currentCall {
            if currentCall.getCobject == instance.currentCallContextBeforeGoingBackground.call?.getCobject {
                if let params = currentCall.currentParams {
                    if params.videoEnabled {
                        currentCall.cameraEnabled = instance.currentCallContextBeforeGoingBackground.isCameraEnabled
                    }
                    instance.currentCallContextBeforeGoingBackground.call = nil
                    
                }
            } else if currentCall.state == .IncomingReceived {
                if ((Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max)) {
                    if ConfigManager.instance().lpConfigBoolForKey(key: "autoanswer_notif_preference") {
                        do {
                            try currentCall.accept()
                        } catch {
                            print("### \(#function) = Error accepting call. Error: \(error)")
                        }
                    let vc = CallViewController()
                        vc.modalPresentationStyle = .overFullScreen
                        
                        DispatchQueue.main.async {
                            tbc.present(vc, animated: false)
                        }
                  } else {
                    tbc.displayIncomingCall(call: currentCall)
                  }
                } else {
                  // Click the call notification when callkit is disabled, show app view.
                    tbc.displayIncomingCall(call: currentCall)
                }

                // in this case, the ringing sound comes from the notification.
                // To stop it we have to do the iOS7 ring fix...
                fixRing()
            }
        }

            
//            [LinphoneManager.instance.iapManager check];
//        if (_shortcutItem) {
//            [self handleShortcut:_shortcutItem];
//            _shortcutItem = nil;
//        }
    }
    func fixRing() {
        if Float(UIDevice.current.systemVersion)! >= 7 {
            // iOS7 fix for notification sound not stopping.
            // see http://stackoverflow.com/questions/19124882/stopping-ios-7-remote-notification-sound
            UIApplication.shared.applicationIconBadgeNumber = 1
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        guard let currentCall = linphoneCore.currentCall else {
            return
        }
        /* save call context */
        let instance = LinphoneManager.instance()
        instance.currentCallContextBeforeGoingBackground.call = currentCall
        instance.currentCallContextBeforeGoingBackground.isCameraEnabled = currentCall.cameraEnabled
        
        if let params = currentCall.currentParams,
           params.videoEnabled {
            currentCall.cameraEnabled = false
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        LinphoneManager.instance().startLinphoneCore()
//        LinphoneManager.instance.fastAddressBook.reloadFriends()
//        NotificationCenter.default.post(name:Notification.Name.init("LinphoneMessageReceived"), object:nil)
        LaunchCounter.launch()
        clearNotifications()
        configureNotificationsOnEnteringForeground()
    }
    private func clearNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    private func configureNotificationsOnEnteringForeground() {
        if let tbc = window?.rootViewController as? TabBarController {
            if let selectedNavigationController = tbc.selectedViewController as? UINavigationController {
                if let currentViewController = selectedNavigationController.viewControllers.last {
                    if AppData.isLoggedIn && AppData.workerId != 0 {
                        currentViewController.requestNotifications {
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                                let topic = "operator_ios_\(AppData.workerId)"
                                Messaging.messaging().subscribe(toTopic: topic) { error in
                                    if let error = error {
                                        printAndLog(message: "### \(#function) Error subscribing to FCM topic: \(topic) | Error: \n\(error)", log: .notifications, logType: .error)
                                    } else {
                                        printAndLog(message: "Successfully subscribed to topic: \(topic)", log: .notifications, logType: .info)
                                    }
                                }
//                                AppDelegate.shared.setupVoipAccount()
                            }
                        }
                    }
                }
            }
        }
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        
        if linphone_core_get_global_state(linphoneCore.getCobject) != LinphoneGlobalOff {
            _ = LinphoneManager.instance().enterBackgroundMode()
//            LinphoneManager.instance().fastAddressBook.clearFriends()
            CoreManager.instance().stopLinphoneCore()
        }
        
        
        clearNotifications()
        
        PersistentContainer.shared.saveContext()
    }


}

