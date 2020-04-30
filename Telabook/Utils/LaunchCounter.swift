//
//  LaunchCounter.swift
//  Telabook
//
//  Created by Anmol Rajpal on 30/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
struct LaunchCounter {
    static func launch() {
        AppData.appFirstLaunchDate == nil ? AppData.appFirstLaunchDate = Date() : ()
        AppData.appLaunchCount += 1
    }
}
