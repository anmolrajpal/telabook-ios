//
//  Click2CallManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

class Click2CallManager: NSObject {
    static let shared = Click2CallManager()
    
    private var activeOperations = [Int]()
    
    func isOperationActive(for conversationID: Int) -> Bool {
        return activeOperations.contains(conversationID)
    }
    func addOperation(for conversationID: Int, completion: (() -> Void)? = nil) {
        activeOperations.append(conversationID)
        completion?()
    }
    func removeOperation(for conversationID: Int, completion: (() -> Void)? = nil) {
        activeOperations.removeAll(where: { $0 == conversationID })
        completion?()
    }
}
