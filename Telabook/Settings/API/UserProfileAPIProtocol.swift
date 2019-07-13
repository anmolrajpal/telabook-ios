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
    func updateUserProfile(token:String, companyId:String, userId:String, username:String, email:String, roleId:String, firstName:String, lastName:String, phoneNumber:String, backupEmail:String, didId:String, profileImage:String, profileImageURL:String, completion: @escaping APICompletion)
}
