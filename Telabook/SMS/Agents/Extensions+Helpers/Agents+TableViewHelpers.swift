//
//  Agents+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
extension AgentsViewController {
    enum Section { case main }
    class DataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> {}
    
    internal func configureTableView() {
        subview.tableView.refreshControl = subview.refreshControl
        subview.tableView.register(AgentCell.self)
        subview.tableView.delegate = self
        
        
        /*
        self.diffableDataSource = UITableViewDiffableDataSource<Section, Agent>(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, agent) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AgentCell.self), for: indexPath) as! AgentCell
            cell.agentDetails = agent
            cell.backgroundColor = .clear
            if self.pickerDelegate == nil {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.cellView.badgeCountLabel.isHidden = true
                cell.tintColor = .telaBlue
                if agent.workerID == self.selectedAgent?.workerID,
                    self.selectedAgent != nil {
                    cell.accessoryType = .checkmark
                }
            }
            return cell
        })
        updateSnapshot()
        */
    }
    
    internal func configureDataSource() {
        self.dataSource = DataSource(tableView: subview.tableView, cellProvider: { (tableView, indexPath, objectID) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(AgentCell.self, for: indexPath)
            let agent = self.fetchedResultsController.object(at: indexPath)
            cell.backgroundColor = .clear
            if self.pickerDelegate == nil {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.tintColor = .telaBlue
                cell.shouldShowBadgeCount = false
                if agent.workerID == self.selectedAgent?.workerID,
                    self.selectedAgent != nil {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            cell.configureCell(with: agent)
            return cell
        })
    }
    
    /*
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    internal func updateSnapshot(animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, Agent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: animated, completion: {
            self.handleState()
        })
    }
    */
}
extension AgentsViewController.DataSource: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let newSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        let numberOfItems = self.snapshot().numberOfItems
        switch numberOfItems {
            case 0: self.apply(newSnapshot, animatingDifferences: false)
            case newSnapshot.numberOfItems: self.apply(newSnapshot, animatingDifferences: false)
            default: self.apply(newSnapshot, animatingDifferences: true)
        }
    }
}
extension AgentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgentCell.cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AgentCell else { return }
        let selectedAgent = fetchedResultsController.object(at: indexPath)
        if pickerDelegate == nil {
            let vc = CustomersViewController(agent: selectedAgent)
            vc.view.backgroundColor = .telaGray1
            navigationController?.pushViewController(vc, animated: true)
        } else {
            tableView.resetCheckmarks()
            cell.accessoryType = .checkmark
            pickerDelegate?.agentsController(didPick: selectedAgent, at: indexPath, controller: self)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard pickerDelegate == nil else { return nil }
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
