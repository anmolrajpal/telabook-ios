//
//  CustomUtils.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
final class CustomUtils {
    static let shared = CustomUtils()
    
    func getSlashEncodedURL(from urlString:String) -> String? {
        let firebaseUri = "https://firebasestorage.googleapis.com/v0/b/telebookchat.appspot.com/o/"
        if let startRange:Range<String.Index> = urlString.range(of: firebaseUri) {
            let range = urlString.range(of: urlString[startRange.upperBound...])
            let url = urlString.replacingOccurrences(of: "/", with: "%2F", options: String.CompareOptions.regularExpression, range: range)
            return url
        }
        return nil
    }
    func getUserRole() -> UserRole {
        let roleId = UserDefaults.standard.getRoleId()
        switch roleId {
        case 1: return .SuperUser
        case 2: return .Admin
        case 3: return .Receptionist
        case 4: return .Agent
        default: fatalError("Invalid Role ID: \(roleId)")
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
class InsetLabel:UILabel {
    var topInset:CGFloat!
    var bottomInset:CGFloat!
    var leftInset:CGFloat!
    var rightInset:CGFloat!
    init(_ topInset:CGFloat, _ bottomInset:CGFloat, _ leftInset:CGFloat, _ rightInset:CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.leftInset = leftInset
        self.rightInset = rightInset
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)))
    }
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
