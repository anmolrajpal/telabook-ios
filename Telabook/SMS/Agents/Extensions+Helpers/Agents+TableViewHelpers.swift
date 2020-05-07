//
//  Agents+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import os

extension AgentsViewController {
    internal func setupTableView() {
//        subview.tableView.refreshControl = subview.refreshControl
        subview.tableView.register(AgentCell.self, forCellReuseIdentifier: NSStringFromClass(AgentCell.self))
        subview.tableView.delegate = self
        
        self.diffableDataSource = UITableViewDiffableDataSource<Section, Agent>(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, agent) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AgentCell.self), for: indexPath) as! AgentCell
            cell.agentDetails = agent
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
        snapshot = NSDiffableDataSourceSnapshot<Section, Agent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: false, completion: {
            self.handleState()
        })
    }
}

extension AgentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgentCell.cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedAgent = self.diffableDataSource?.itemIdentifier(for: indexPath) {
            let vc = AgentDetailsViewController(agent: selectedAgent)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
