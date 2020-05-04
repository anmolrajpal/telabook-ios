//
//  AgentDetailsHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension AgentDetailsViewController {
    internal func setupAgentDetails(details:Agent) {
        let roleID = Int(details.roleID)
        let name = details.personName ?? "No Name"
        let initialsText = CustomUtils.shared.getInitials(from: name)
        let role = AppUserRole.getUserRole(byRoleCode: roleID)
        let urlString = details.profileImageURL?.absoluteString
        let profileImageURLString = CustomUtils.shared.getSlashEncodedURL(from: urlString)
        subview.parameters = AgentDetailsView.Parameters(name: name,
                                                         initials: initialsText,
                                                         profileImageURLString: profileImageURLString,
                                                         designation: role)
    }
    
    
    internal func setupTargetActions() {
        subview.firstTimeSMSButton.addTarget(self, action: #selector(smsButtonTapped), for: .touchUpInside)
        subview.quickResponsesButton.addTarget(self, action: #selector(quickResponsesButtonTapped), for: .touchUpInside)
    }
    @objc private func smsButtonTapped() {
        if let userId = self.agentDetails.userID != 0 ? Int(agentDetails.userID) : nil {
            let vc = AutoResponseViewController(userId: String(userId))
            //            vc.modalPresentationStyle = .overFullScreen
            vc.view.backgroundColor = .telaGray1
            present(vc, animated: true, completion: nil)
        } else {
            fatalError("User ID not found")
        }
    }
    
    @objc private func quickResponsesButtonTapped() {
        if let userId = self.agentDetails.userID != 0 ? Int(agentDetails.userID) : nil {
            let vc = QuickResponsesViewController(userId: String(userId))
            //            vc.modalPresentationStyle = .overFullScreen
            vc.view.backgroundColor = .telaGray1
            present(vc, animated: true, completion: nil)
        } else {
            fatalError("User ID not found")
        }
    }
}

