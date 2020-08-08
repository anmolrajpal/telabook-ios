//
//  LocalNotificationService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import UserNotifications

public extension UNNotificationRequest {
    convenience init(key: LocalNotificationService.NotificationKey, content: UNNotificationContent, trigger: UNNotificationTrigger?) {
        self.init(identifier: key.rawValue, content: content, trigger: trigger)
    }
}

extension LocalNotificationItem {
    static let imageSavedToPhotosNotificationItem = LocalNotificationItem(key: .imageSavedToLibrary, body: "Image saved to your Photo Library", sound: .default, tapHandler: {
        AppDelegate.shared.launchPhotosApp()
    })
}
extension UNNotificationRequest {
    static let imageSavedToLibrary = LocalNotificationService.shared.notificationRequest(for: .imageSavedToPhotosNotificationItem)
}
public class LocalNotificationService {
    public enum NotificationKey:String {
        case imageSavedToLibrary,
        click2CallError,
        click2CallSuccess
    }
    static let shared = LocalNotificationService()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func postNotification(for item:LocalNotificationItem, _ completionHandler: (() -> Void)? = nil) {
        let request = notificationRequest(for: item)
        addNotificationRequest(request: request, completion: completionHandler)
    }
    func postNotification(forRequest request: UNNotificationRequest, _ completionHandler: (() -> Void)? = nil) {
        addNotificationRequest(request: request, completion: completionHandler)
    }
    func notificationRequest(for item:LocalNotificationItem) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        if let title = item.title {
            content.title = title
        }
        if let body = item.body {
            content.body = body
        }
        if let sound = item.sound {
            content.sound = sound
        }
        if let badgeCount = item.badgeCount {
            content.badge = NSNumber(value: badgeCount)
        }
        if let userInfo = item.userInfo {
            content.userInfo = userInfo
        }
        let trigger:UNTimeIntervalNotificationTrigger? = item.delay > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: item.delay, repeats: false) : nil
        
        let request = UNNotificationRequest(key: item.key, content: content, trigger: trigger)
        return request
    }
//    func handleNotificationTapAction(for key:NotificationKey) {
//        switch key {
//            case .imageSavedToLibrary:
//        }
//    }
    private func addNotificationRequest(request: UNNotificationRequest, completion: (() -> Void)? = nil) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.notificationCenter.add(request) { error in
                        if let error = error {
                            printAndLog(message: error.localizedDescription, log: .notifications, logType: .error)
                        } else {
                            completion?()
                        }
                    }
                default: break
            }
        }
    }
}
