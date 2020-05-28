//
//  CustomerCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {
    let cellView = CustomerCellView()
    static let cellHeight:CGFloat = 70.0
    var customerDetails:Customer? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        guard let details = customerDetails else { return }
//        let priority = CustomerPriority.priority(from: Int(details.priority))
        let phoneNumber = details.phoneNumber ?? ""
        let number:String
        if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
            number = formattedPhoneNumber
        } else {
            number = phoneNumber
        }
        let name = details.addressBookName
        let messageType = MessageCategory(stringValue: details.messageType ?? "")
        let lastMessage = details.lastMessageText
        let lastMessageDate = details.lastMessageDateTime
        let conversationColor = CustomerConversationColor.colorCase(from: Int(details.colorCode)).color
        let unreadMessagesCount = Int(details.unreadMessagesCount)
        let isPinned = details.isPinned
        cellView.parameters = CustomerCellView.Parameters(phoneNumber: number,
                                                          name: name,
                                                          lastMessageType: messageType,
                                                          lastMessage: lastMessage,
                                                          lastMessageDate: lastMessageDate,
                                                          conversationColor: conversationColor,
                                                          unreadMessagesCount: unreadMessagesCount,
                                                          isPinned: isPinned)
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
