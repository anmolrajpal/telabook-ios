//
//  CallDetails+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension CallDetailsViewController {
    
   
    func configureTableView() {
        let headerView = CallDetailsTableHeaderView()
        let parameters:CallDetailsTableHeaderView.Parameters = .init(profileImageURL: nil, name: callDetails.customerName, phoneNumber: callDetails.customerCid!)
        headerView.configureData(with: parameters)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        tableView.register(CallDetailsMetaDetailsCell.self)
        tableView.register(KeyValueCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        default: fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(CallDetailsMetaDetailsCell.self, for: indexPath)
            cell.configureCell(with: callDetails)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(KeyValueCell.self, for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Agent Name"
                cell.detailTextLabel?.text = callDetails.workerName
            } else {
                cell.textLabel?.text = "Agent Number"
                cell.detailTextLabel?.text = callDetails.workerCid?.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? callDetails.workerCid
            }
            return cell
        }
    }
}
