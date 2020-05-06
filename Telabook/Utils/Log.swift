//
//  Log.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let ui = OSLog (subsystem: subsystem, category: OSLog.Category.LogCategory.UI.rawValue)
    static let firebase = OSLog (subsystem: subsystem, category: OSLog.Category.LogCategory.Firebase.rawValue)
    static let network = OSLog (subsystem: subsystem, category: OSLog.Category.LogCategory.Network.rawValue)
    static let coredata = OSLog(subsystem: subsystem, category: OSLog.Category.LogCategory.CoreData.rawValue)
}
extension OSLog.Category {
    fileprivate enum LogCategory:String { case UI, Firebase, Network, CoreData }
}
