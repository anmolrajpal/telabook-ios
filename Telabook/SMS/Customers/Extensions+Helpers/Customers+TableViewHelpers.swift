//
//  Customers+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension CustomersViewController {
    internal func setupTableView() {
//        subview.tableView.refreshControl = subview.refreshControl
        subview.tableView.register(CustomerCell.self, forCellReuseIdentifier: NSStringFromClass(CustomerCell.self))
        subview.tableView.delegate = self
        
        self.diffableDataSource = UITableViewDiffableDataSource<Section, Customer>(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, customer) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CustomerCell.self), for: indexPath) as! CustomerCell
            cell.customerDetails = customer
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
            cell.selectedBackgroundView  = backgroundView
            return cell
        })
        updateSnapshot()
    }
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    internal func updateSnapshot(animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, Customer>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: animated, completion: {
            self.handleState()
        })
    }
}

extension CustomersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomerCell.cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCustomer = self.diffableDataSource?.itemIdentifier(for: indexPath) {
            let id = selectedCustomer.customerID
            guard id != 0,
                let node = selectedCustomer.node else { return }
            print("Conversation Node: \(node)")
//                let vc = ChatViewController(conversationId: String(id), node: node, conversation: selectedCustomer)
//                vc.workerId = self.workerId
//                vc.title = conversation.internalAddressBookName?.isEmpty ?? true ? conversation.customerPhoneNumber : conversation.internalAddressBookName
//            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
