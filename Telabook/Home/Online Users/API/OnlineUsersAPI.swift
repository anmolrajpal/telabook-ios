//
//  OnlineUsersAPI.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import Firebase

final class OnlineUsersAPI: NSObject {
    static let shared = OnlineUsersAPI()
    
    func fetchOnlineUsers(completion: @escaping([OnlineUser]?, Error?) -> ()) {
        var onlineUsers:[OnlineUser]? = []
        let query = Config.DatabaseConfig.onlineUsersReference()
        query.observe(.childAdded, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                let dateValue = data["date"] as? Int64
                let lastEvent = data["last_event"] as? String
                let personName = data["personname"] as? String
                let profileImage = data["profile_image"] as? String
                let profileImageURL = data["profile_image_url"] as? String
                let userId = data["user_id"] as? Int
                let userName = data["username"] as? String
                let date = Date(timeIntervalSince1970: TimeInterval(integerLiteral: ((dateValue ?? 0) / 1000)))
                let onlineUser = OnlineUser(date: date, lastEvent: lastEvent, personName: personName, profileImage: profileImage, profileImageURL: profileImageURL, userId: userId, userName: userName)
                onlineUsers?.append(onlineUser)
            }
            completion(onlineUsers, nil)
        }) { (error) in
            print("Error fetching online users")
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func observeOnlineUsers() {
//        var onlineUsers:[OnlineUser]? = []
        let query = Config.DatabaseConfig.onlineUsersReference()
        query.observe(.childChanged, with: { (snapshot) in
            print("Observation Snapshot => ")
            print(snapshot)
            if let data = snapshot.value as? [String:Any] {
                let dateValue = data["date"] as? Int64
                let lastEvent = data["last_event"] as? String
                let personName = data["personname"] as? String
                let profileImage = data["profile_image"] as? String
                let profileImageURL = data["profile_image_url"] as? String
                let userId = data["user_id"] as? Int
                let userName = data["username"] as? String
                let date = Date(timeIntervalSince1970: TimeInterval(integerLiteral: ((dateValue ?? 0) / 1000)))
                let _ = OnlineUser(date: date, lastEvent: lastEvent, personName: personName, profileImage: profileImage, profileImageURL: profileImageURL, userId: userId, userName: userName)
//                onlineUsers?.append(onlineUser)
            }
//            completion(onlineUsers, nil)
        }) { (error) in
            print("Error fetching online users")
            print(error.localizedDescription)
//            completion(nil, error)
        }
    }
}
