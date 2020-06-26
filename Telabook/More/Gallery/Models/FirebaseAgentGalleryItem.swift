//
//  FirebaseAgentGalleryItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import Firebase


struct FirebaseAgentGalleryItem {
    let ref: DatabaseReference?
    let key: String
    let date:Date?
    let url: String?
    
    
    
    init?(snapshot: DataSnapshot) {
        func mapToDate(value:AnyObject?) -> Date? {
            switch value {
                case let value as Int: return .getDate(fromSecondsOrMilliseconds: value)
                case let value as NSNumber: return .getDate(fromSecondsOrMilliseconds: value.intValue)
                case let value as String: return value.dateFromFormattedString
                default: return nil
            }
        }
        let key = snapshot.key
        guard !key.isBlank,
            let value = snapshot.value as? [String: AnyObject] else {
//            print("Error: Failed to unwrap snapshot value")
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = key
        self.date = mapToDate(value: value["date"])
        self.url = value["url"] as? String
    }
}
