//
//  Configuration.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    enum Constants:String {
        case baseURL = "BASE_URL"
        case apiHost = "API_HOST"
        case urlScheme = "URL_SCHEME"
        case subdomain = "SUBDOMAIN"
        case timoutInterval = "TIMEOUT_INTERVAL"
        case appName = "APP_NAME"
        case bundleID = "CFBundleIdentifier"
        case bundleDisplayName = "CFBundleDisplayName"
    }
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
    
    
    static func value<T>(for key: Constants) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key.rawValue) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}
