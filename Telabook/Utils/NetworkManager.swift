//
//  NetworkManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import Reachability
import os
final class NetworkManager: NSObject {
    let reachability = try! Reachability()
    static let shared:NetworkManager = { return NetworkManager() }()
    override required init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try self.reachability.startNotifier()
        } catch {
            print(error.localizedDescription)
            os_log("Reachability Error: %@", log: .network, type: .error, error.localizedDescription)
            return
        }
    }
    @objc func reachabilityChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        #if DEBUG
        switch reachability.connection {
        case .wifi:
            print("Network Reachable via WiFi")
            os_log("Network Reachable via Wifi", log: .network, type: .info)
        case .cellular:
            print("Network Reachable via Cellular")
            os_log("Network Reachable via Cellular", log: .network, type: .info)
        case .unavailable:
            print("Network Unreachable")
            os_log("Network Unreachable", log: .network, type: .info)
        default: break
        }
        #endif
    }
//    deinit {
//        removeObservers()
//    }
    func removeObservers() -> Void {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        reachability.stopNotifier()
    }
    // Network is reachable
    static func isReachable() -> Bool {
        return (NetworkManager.shared.reachability).connection != .unavailable
    }
    
    // Network is unreachable
    static func isUnreachable() -> Bool {
        return (NetworkManager.shared.reachability).connection == .unavailable
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaCellular(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.shared.reachability).connection == .cellular {
            completed(NetworkManager.shared)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.shared.reachability).connection == .wifi {
            completed(NetworkManager.shared)
        }
    }
}
