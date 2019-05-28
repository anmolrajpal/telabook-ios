//
//  NetworkManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
//import Reachability
//final class NetworkManager: NSObject {
//    let reachability = Reachability()!
//    static let shared:NetworkManager = { return NetworkManager() }()
//    override init() {
//        super.init()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(NetworkManager.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
//        do {
//            try self.reachability.startNotifier()
//        } catch {
//            print(error.localizedDescription)
//            return
//        }
//    }
//    @objc func reachabilityChanged(_ notification: Notification) {
//        let reachability = notification.object as! Reachability
//        switch reachability.connection {
//        case .wifi: break
//        case .cellular: break
//        case .none: break
//        }
//    }
//    static func stopNotifier() -> Void {
//        (NetworkManager.shared.reachability).stopNotifier()
//        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: NetworkManager.shared.reachability)
//    }
//    // Network is reachable
//    static func isReachable() -> Bool {
//        return (NetworkManager.shared.reachability).connection != .none
//    }
//    
//    // Network is unreachable
//    static func isUnreachable() -> Bool {
//        return (NetworkManager.shared.reachability).connection == .none
//    }
//    
//    // Network is reachable via WWAN/Cellular
//    static func isReachableViaCellular(completed: @escaping (NetworkManager) -> Void) {
//        if (NetworkManager.shared.reachability).connection == .cellular {
//            completed(NetworkManager.shared)
//        }
//    }
//    
//    // Network is reachable via WiFi
//    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
//        if (NetworkManager.shared.reachability).connection == .wifi {
//            completed(NetworkManager.shared)
//        }
//    }
//}
