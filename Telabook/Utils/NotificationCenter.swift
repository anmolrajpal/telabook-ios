//
//  NotificationCenter.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let linphoneConfiguringStateUpdate = Notification.Name("LinphoneConfiguringStateUpdate")
    static let linphoneGlobalStateUpdate = Notification.Name("LinphoneGlobalStateUpdate")
    static let linphoneNotifyReceived = Notification.Name("LinphoneNotifyReceived")
    static let linphoneCallEncryptionChanged = Notification.Name("LinphoneCallEncryptionChanged")
    static let linphoneCoreUpdate = Notification.Name("LinphoneCoreUpdate")
    static let linphoneBluetoothAvailabilityUpdate = Notification.Name("LinphoneBluetoothAvailabilityUpdate")
    static let linphoneRegistrationUpdate = Notification.Name("LinphoneRegistrationUpdate")
    static let linphoneNotifyPresenceReceivedForUriOrTel = Notification.Name("LinphoneNotifyPresenceReceivedForUriOrTel")
    static let linphoneCallUpdate = Notification.Name("LinphoneCallUpdate")
    static let linphoneLogsUpdate = Notification.Name("LinphoneLogsUpdate")
    
    
}
