//
//  AppDataKey.swift
//  Telabook
//
//  Created by Anmol Rajpal on 06/02/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
public enum AppDataKey:String, CaseIterable {
    case isLoggedIn,
    isRememberMeChecked,
    userId,
    userInfo,
    email,
    password,
    firebaseToken,
    companyId,
    workerId,
    roleId,
    appFirstLaunchDate,
    isOnboardingComplete,
    appLaunchCount,
    selectedTab,
    isHapticsEnabled,
    encryptionKey
}
