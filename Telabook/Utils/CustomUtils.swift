//
//  CustomUtils.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
final class CustomUtils {
    static let shared = CustomUtils()
    func getUserRole() -> UserRole {
        let roleId = UserDefaults.standard.getRoleId()
        switch roleId {
        case 1: return .SuperUser
        case 2: return .Admin
        case 3: return .Receptionist
        case 4: return .Agent
        default: fatalError("Invalid Role ID")
        }
    }
    func getInitials(from fullName:String) -> String {
        let groups = fullName.split(separator: " ")
        let firstName = groups.first
        let lastName = groups.last
        let initials:String = String(firstName?.first ?? "*") + String(lastName?.first ?? "*")
        return initials
    }
}
