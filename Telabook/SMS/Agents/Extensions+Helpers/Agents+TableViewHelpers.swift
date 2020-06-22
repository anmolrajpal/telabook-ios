//
//  Agents+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import os

extension AgentsViewController {
    internal func setupTableView() {
        subview.tableView.refreshControl = subview.refreshControl
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
        diffableDataSource?.apply(snapshot, animatingDifferences: animated, completion: {
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
            let vc = CustomersViewController(fetchRequest: Customer.fetchRequest(), viewContext: context, agent: selectedAgent)
            vc.view.backgroundColor = .telaGray1
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let agent = agents[index]
        let identifier = String(index) as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            var menuItems = [UIMenuElement]()
            
            let firstTimeSMSAction = UIAction(title: "First Time SMS", image: #imageLiteral(resourceName: "automsg_icon")) { _ in
                self.showFirstTimeSMS(for: agent)
            }
            let quickResponsesAction = UIAction(title: "Quick Responses", image: #imageLiteral(resourceName: "autoresponse_icon")) { _ in
                self.showQuickResponses(for: agent)
            }
            let galleryAction = UIAction(title: "Gallery", image: #imageLiteral(resourceName: "camera_icon")) { _ in
                self.showGallery(for: agent)
            }
            
            menuItems.append(firstTimeSMSAction)
            menuItems.append(quickResponsesAction)
            menuItems.append(galleryAction)
            return UIMenu(title: "", children: menuItems)
        }
    }
    private func showFirstTimeSMS(for agent:Agent) {
        if let userID = agent.userID != 0 ? Int(agent.userID) : nil {
            let vc = AutoResponseViewController(userID: userID, agent: agent)
            present(vc, animated: true, completion: nil)
        } else {
            fatalError("User ID not found")
        }
    }
    
    private func showQuickResponses(for agent:Agent) {
        if let userID = agent.userID != 0 ? Int(agent.userID) : nil {
            let vc = QuickResponsesViewController(userID: userID, agent: agent)
            present(vc, animated: true, completion: nil)
        } else {
            fatalError("User ID not found")
        }
    }
    private func showGallery(for agent:Agent) {
        let vc = AgentGalleryController(agent: agent)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
}
