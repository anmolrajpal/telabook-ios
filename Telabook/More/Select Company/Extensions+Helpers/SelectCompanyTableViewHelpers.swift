//
//  SelectCompanyTableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension SelectCompanyViewController {
    internal func resetChecks(tableView:UITableView) {
        for i in 0 ..< tableView.numberOfSections {
            for j in 0 ..< tableView.numberOfRows(inSection: i) {
                if let cell = tableView.cellForRow(at: IndexPath(row: j, section: i)) {
                    cell.accessoryType = .none
                }
            }
        }
    }
    internal func setupTableView() {
        subview.companiesTableView.delegate = self
        subview.companiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        self.diffableDataSource = UITableViewDiffableDataSource<Section, UserCompaniesCodable>(tableView: self.subview.companiesTableView, cellProvider: { (tableView, indexPath, company) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.telaGray4
            cell.textLabel?.textColor = UIColor.telaWhite
            cell.textLabel?.text = company.name
            if self.selectedCompany != nil,
                company == self.selectedCompany {
                print("diffable selected checkmark at company- \(company.name!)")
                cell.accessoryType = .checkmark
            }
            return cell
        })
    }
    internal func populateDataSource(companies:[UserCompaniesCodable], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserCompaniesCodable>()
        snapshot.appendSections([.main])
        snapshot.appendItems(companies, toSection: .main)
        self.diffableDataSource.apply(snapshot, animatingDifferences: animated, completion: {
            DispatchQueue.main.async {
                self.subview.spinner.stopAnimating()
                self.subview.companiesTableView.isHidden = false
            }
        })
        
        
    }
}


extension SelectCompanyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resetChecks(tableView: tableView)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            self.selectedCompany = userCompanies[indexPath.row]
        }
//        if let selectedCompany = self.diffableDataSource.itemIdentifier(for: indexPath) {
//            var currentSnapShot = self.diffableDataSource.snapshot()
//            currentSnapShot.deleteItems([selectedCompany])
//            self.diffableDataSource.apply(currentSnapShot, animatingDifferences: true)
//        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
