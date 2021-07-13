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
    
    class DataSource: UITableViewDiffableDataSource<Section, Agent> {}
    
    internal func configureTableView() {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 85, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.refreshControl = tableViewRefreshControl
        tableView.register(AgentCell.self)
        tableView.delegate = self
    }
    
    internal func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, agent) -> UITableViewCell? in
            guard let self = self else { return nil }
            let cell = tableView.dequeueReusableCell(AgentCell.self, for: indexPath)
//            let agent = self.fetchedResultsController.object(at: indexPath)
            cell.backgroundColor = .clear
            switch true {
                case self.pickerDelegate != nil:
                    cell.tintColor = .telaBlue
                    cell.shouldShowBadgeCount = false
                    if agent.workerID == self.selectedAgent?.workerID,
                        self.selectedAgent != nil {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                }
                case self.messageForwardingDelegate != nil:
                    cell.shouldShowBadgeCount = false
                    cell.accessoryType = .disclosureIndicator
                default:
                    cell.accessoryType = .disclosureIndicator
            }
            /*
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
            */
            cell.configureCell(with: agent)
            return cell
        })
    }
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, Agent>? {
        guard fetchedResultsController != nil else { return nil }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Agent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(agents)
        return snapshot
    }
    func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot(), dataSource != nil else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData && self.viewDidAppear { self.tableView.reloadData() }
            if !self.isDownloading {
                self.handleState()
                self.stopRefreshers()
            }
        })
    }
}
/*
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
*/



// MARK: - Table View Delegate

extension AgentsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgentCell.cellHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AgentCell else { return }
        guard let selectedAgent = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch true {
            case pickerDelegate != nil:
                tableView.resetCheckmarks()
                cell.accessoryType = .checkmark
                pickerDelegate?.agentsController(didPick: selectedAgent, at: indexPath, controller: self)
            case messageForwardingDelegate != nil:
                messageForwardingDelegate?.agentsController(didSelect: selectedAgent, workerID: Int(selectedAgent.workerID), at: indexPath, controller: self)
            default:
                let vc = CustomersViewController(agent: selectedAgent)
                navigationController?.pushViewController(vc, animated: true)
                viewDidAppear = false
        }
        
        /*
        if pickerDelegate == nil {
            let vc = CustomersViewController(agent: selectedAgent)
            navigationController?.pushViewController(vc, animated: true)
            viewDidAppear = false
        } else {
            tableView.resetCheckmarks()
            cell.accessoryType = .checkmark
            pickerDelegate?.agentsController(didPick: selectedAgent, at: indexPath, controller: self)
        }
        */
    }
    
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard pickerDelegate == nil && messageForwardingDelegate == nil else { return nil }
        let index = indexPath.row
        let agent = agents[index]
        let identifier = String(index) as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            var menuItems = [UIMenuElement]()
            
            // MARK: - First Time SMS Action
            
            let firstTimeSMSAction = UIAction(title: "First Time SMS", image: #imageLiteral(resourceName: "automsg_icon")) { _ in
                self.showAutoResponseController(forAgent: agent)
            }
            menuItems.append(firstTimeSMSAction)
            
            
            
            
            // MARK: - Quick Responses Action
            
            let quickResponsesAction = UIAction(title: "Quick Responses", image: #imageLiteral(resourceName: "autoresponse_icon")) { _ in
                self.showQuickResponses(for: agent)
            }
            menuItems.append(quickResponsesAction)
            
            
            
            // MARK: - Address Book Action
            
            let addressBookAction = UIAction(title: "Address Book", image: #imageLiteral(resourceName: "addressbook")) { _ in
                self.showAddressBook(for: agent)
            }
            menuItems.append(addressBookAction)
            
            
            
            // MARK: - Agent's Gallery Action
            
            let galleryAction = UIAction(title: "Gallery", image: #imageLiteral(resourceName: "camera_icon")) { _ in
                self.showGallery(for: agent)
            }
            menuItems.append(galleryAction)
            
            
            
            
            // MARK: - Copy Agent's DID Number Action
            
            if let text = agent.didNumber, !text.isBlank {
                let copyDIDAction = UIAction(title: "Copy DID Number", image: SFSymbol.copy.image.withTintColor(.telaBlue, renderingMode: .alwaysOriginal)) { _ in
                    UIPasteboard.general.string = text
                }
                menuItems.append(copyDIDAction)
            }
            
            
            return UIMenu(title: "", children: menuItems)
        }
    }
    private func showAutoResponseController(forAgent agent: Agent) {
        guard agent.userID != 0 else {
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Corrupted data")
            }
            return
        }
        let vc = AutoResponseViewController(agent: agent)
        DispatchQueue.main.async {
            self.present(vc, animated: true)
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
    
    private func showAddressBook(for agent: Agent) {
        let vc = AddressBookViewController(agent: agent)
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
    private func showGallery(for agent:Agent) {
        let vc = AgentGalleryController(agent: agent)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
}
