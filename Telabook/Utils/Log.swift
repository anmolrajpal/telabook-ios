//
//  Log.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import os

extension OSLog {
   private static var subsystem = Bundle.main.bundleIdentifier!
   
   static let ui = OSLog (subsystem: subsystem, category: OSLog.Category.LogCategory.UI.rawValue)
   static let firebase = OSLog (subsystem: subsystem, category: OSLog.Category.LogCategory.Firebase.rawValue)
   static let network = OSLog (subsystem: subsystem, category: OSLog.Category.LogCategory.Network.rawValue)
   static let coredata = OSLog(subsystem: subsystem, category: OSLog.Category.LogCategory.CoreData.rawValue)
   static let notifications = OSLog(subsystem: subsystem, category: OSLog.Category.LogCategory.notifications.rawValue)
}
extension OSLog.Category {
   fileprivate enum LogCategory:String { case UI, Firebase, Network, CoreData, notifications }
}

/// A method that logs the provided message in debug console and in mentioned os log. This method will log message in debug console only when it's under NON-RELEASE environement. Check the !RELEASE macro flag.
/// - Parameters:
///   - message: The String message to log
///   - log: The log file. `eg: CoreData, Firebase, UI, etc`
///   - logType: The category of log. `eg: debug, info, error, etc`
public func printAndLog(message:String, log:OSLog, logType:OSLogType, isPrivate:Bool = false) {
   AnalyticsManager.shared.trackEvent(.printLog, properties: ["message": message])
   print(message)
   if !isPrivate {
      os_log("%@", log: log, type: logType, message)
   } else {
      os_log("%{PRIVATE}@", log: log, type: logType, message)
   }
}
