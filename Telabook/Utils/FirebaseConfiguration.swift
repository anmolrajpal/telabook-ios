//
//  FirebaseConfiguration.swift
//  Telabook
//
//  Created by Anmol Rajpal on 17/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

enum FirebaseConfiguration {
    enum Error: Swift.Error {
        case missingKey, invalidValue, fileNotExists, invalidContentInFile, invalidPropertyList
    }
    enum Constants:String {
        case storageBucket = "STORAGE_BUCKET"
        case apiKey = "API_KEY"
        case gcmSenderID = "GCM_SENDER_ID"
        case databaseURL = "DATABASE_URL"
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") else {
            throw Error.fileNotExists
        }
        guard let data = try? Data(contentsOf: url) else {
            throw Error.invalidContentInFile
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any] else {
            throw Error.invalidPropertyList
        }
        guard let object = plist[key] else {
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
        guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") else {
            throw Error.fileNotExists
        }
        guard let data = try? Data(contentsOf: url) else {
            throw Error.invalidContentInFile
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any] else {
            throw Error.invalidPropertyList
        }
        guard let object = plist[key.rawValue] else {
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
    
    
    static var storageURLString:String {
        let prefix = "https://firebasestorage.googleapis.com/v0/b/"
        let bucket:String = try! value(for: .storageBucket)
        let suffix = "/o/"
        return prefix + bucket + suffix
    }
}
