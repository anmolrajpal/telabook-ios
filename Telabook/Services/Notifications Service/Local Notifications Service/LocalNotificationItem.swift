//
//  LocalNotificationItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import UserNotifications

struct LocalNotificationItem {
    let key:LocalNotificationService.NotificationKey
    let title:String?
    let body:String?
    let sound:UNNotificationSound?
    let badgeCount:Int?
    let delay:TimeInterval
    let tapHandler:(() -> Void)?
    
    init(key:LocalNotificationService.NotificationKey, title:String? = nil, body:String? = nil, sound:UNNotificationSound? = nil, badgeCount:Int? = nil, delay:TimeInterval = 0, tapHandler:(() -> Void)? = nil) {
        self.key = key
        self.title = title
        self.body = body
        self.sound = sound
        self.badgeCount = badgeCount
        self.delay = delay
        self.tapHandler = tapHandler
    }
}
