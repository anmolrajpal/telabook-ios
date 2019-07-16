//
//  UserProfileAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol UserProfileAPIProtocol : APIProtocol {
    func fetchUserProfile(token:String, userId:String, completion: @escaping APICompletion)
    func updateUserProfile(token:String, userId:String, email:String, firstName:String, lastName:String, phoneNumber:String, backupEmail:String, address:String, profileImage:String, profileImageURL:String, completion: @escaping APICompletion)
}
