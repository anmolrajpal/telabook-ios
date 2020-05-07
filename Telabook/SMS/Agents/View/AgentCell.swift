//
//  AgentCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class AgentCell: UITableViewCell {
    let cellView = AgentCellView()
    static let cellHeight:CGFloat = 80.0
    var agentDetails:Agent? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        guard let details = agentDetails else { return }
        let roleID = Int(details.roleID)
        let name = details.personName ?? "No Name"
        let initialsText = CustomUtils.shared.getInitials(from: name)
        let role = AppUserRole.getUserRole(byRoleCode: roleID)
        let lowPriorityCheck = details.priority1
        let mediumPriorityCheck = details.priority2
        let highPriorityCheck = details.priority3
        let urlString = details.profileImageURL?.absoluteString
        let profileImageURLString = CustomUtils.shared.getSlashEncodedURL(from: urlString)
        let pendingMessagesCount = Int(details.externalPendingMessagesCount)
        cellView.parameters = AgentCellView.Parameters(name: name,
                                                              initials: initialsText,
                                                              role: role,
                                                              profileImageURLString: profileImageURLString,
                                                              lowPriorityCheck: lowPriorityCheck,
                                                              mediumPriorityCheck: mediumPriorityCheck,
                                                              highPriorityCheck: highPriorityCheck,
                                                              pendingMessagesCount: pendingMessagesCount)
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
