//
//  OnlineUsersTableViewExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension OnlineUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onlineUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OnlineUserCell.self), for: indexPath) as! OnlineUserCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.onlineUser = self.onlineUsers?[indexPath.row]
        return cell
    }
    
    
}
extension OnlineUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
