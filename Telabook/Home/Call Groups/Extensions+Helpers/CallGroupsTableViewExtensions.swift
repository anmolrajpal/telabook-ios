//
//  CallGroupsTableViewExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension CallGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.callGroups?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CallGroupsCell.self), for: indexPath) as! CallGroupsCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.callGroup = self.callGroups?[indexPath.row]
        return cell
    }
    
    
}
extension CallGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

