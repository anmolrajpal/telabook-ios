//
//  ChangePasswordAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 15/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol ChangePasswordAPIProtocol: APIProtocol {
    func changePassword(token:String, currentPassword:String, newPassword:String, confirmationPassword:String, completion: @escaping APICompletion)
}
