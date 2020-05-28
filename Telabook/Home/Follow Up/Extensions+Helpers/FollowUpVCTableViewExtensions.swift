//
//  FollowUpVCTableViewExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
extension FollowUpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followUpsIndex?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FollowUpCell.self), for: indexPath) as! FollowUpCell
        cell.followUpsIndex = self.followUpsIndex?[indexPath.row]
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
}

extension FollowUpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FollowUpCell.cellHeight
    }
}
