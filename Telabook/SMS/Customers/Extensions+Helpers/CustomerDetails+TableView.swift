//
//  CustomerDetails+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension CustomerDetailsController {
    
}




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
