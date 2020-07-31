//
//  SceneDelegate.swift
//  Wealth Land
//
//  Created by Anmol Rajpal on 26/10/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        LaunchCounter.launch()
        clearNotificationsOnEnteringForeground()
        configureNotificationsOnEnteringForeground()
    }
    private func clearNotificationsOnEnteringForeground() {
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

        // Save changes in the application's managed object context when the application transitions to the background.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        PersistenceService.shared.saveContext()
    }


}

