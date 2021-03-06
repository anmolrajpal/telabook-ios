//
//  BlacklistCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

enum PhoneNumberMask {
    
}
class BlacklistCell: UITableViewCell {
    let cellView = BlacklistCellView()
    static let cellHeight:CGFloat = 70.0
    var blockedUser:BlockedUser? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        guard let details = blockedUser else { return }
        let phoneNumber = details.phoneNumber ?? ""
        
        let number:String = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
        /*
        if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
            number = formattedPhoneNumber
        } else {
            number = phoneNumber
        }
        */
        let date = details.updatedAt != nil ? Date.getStringFromDate(date: details.updatedAt!, dateFormat: "MMMM d, yyyy | h:mm a") : ""
        cellView.parameters = BlacklistCellView.Parameters(phoneNumber: number,
                                                           date: date)
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cellView)
        cellView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
