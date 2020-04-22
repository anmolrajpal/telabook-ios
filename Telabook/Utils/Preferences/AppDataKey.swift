//
//  AppDataKey.swift
//  Matchbook
//
//  Created by Anmol Rajpal on 06/02/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
public enum AppDataKey:String, CaseIterable {
    case isLoggedIn,
    userId,
    userInfo,
    email,
    password,
    appFirstLaunchDate,
    isOnboardingComplete,
    appLaunchCount,
    selectedTab,
    isHapticsEnabled
}
