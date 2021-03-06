//
//  UserDefaultsWrapper.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CryptoKit

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    private let userDefaults = UserDefaults(suiteName: Config.appGroupID)! // App Group ID
    private let key: AppDataKey
    private let defaultValue: T
    
    init(key: AppDataKey, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            // Read value from UserDefaults
            guard let data = userDefaults.object(forKey: key.rawValue) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }

            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            // Convert newValue to data
            let data = try? JSONEncoder().encode(newValue)
            
            // Set value to UserDefaults
            userDefaults.set(data, forKey: key.rawValue)
        }
    }
}



@propertyWrapper
struct UserDefaultsEncryptionWrapper {
    private let userDefaults = UserDefaults(suiteName: Config.appGroupID)! // App Group ID
    private let key: AppDataKey
    init(key: AppDataKey) {
        self.key = key
    }

    var wrappedValue: String {
        get {
            // Get encrypted string from UserDefaults
            let encryptedData = userDefaults.object(forKey: key.rawValue) as! Data
            let decryptedString = decrypt(cipher: encryptedData)
            return decryptedString
        }
        set {
            // Encrypt newValue before set to UserDefaults
            let encryptedData = encrypt(value: newValue)
            userDefaults.set(encryptedData, forKey: key.rawValue)
        }
    }

    private func encrypt(value: String) -> Data {
        let encryptedData = value.data(using: .utf8)!
        let encryptionKey = SymmetricKey(size: .bits256)
        let encryptionKeyData = encryptionKey.withUnsafeBytes {Data(Array($0)).base64EncodedString()}
        AppData.encryptionKey = encryptionKeyData
        let sealedBox = try! ChaChaPoly.seal(encryptedData, using: encryptionKey)
        let encryptedContent = sealedBox.combined
        return encryptedContent
    }
    private func decrypt(cipher: Data) -> String {
        let sealedBox = try! ChaChaPoly.SealedBox(combined: cipher)
        let encryptionKeyData = Data(base64Encoded: AppData.encryptionKey)!
        let encryptionKey = SymmetricKey(data: encryptionKeyData)
        let decryptedData = try! ChaChaPoly.open(sealedBox, using: encryptionKey)
        let deccryptedString = String(data: decryptedData, encoding: .utf8)!
        return deccryptedString
    }
}
