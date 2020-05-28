//
//  ToggleCallGroupHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
extension CallGroupsViewController: CallGroupsCellDelegate {
    func didToggleSwitch(forGroupWithID groupId: String) {
        initiateToggleCallGroupSequence(forGroupWithID: groupId)
    }
}
