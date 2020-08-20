//
//  CustomerDetails+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension CustomerDetailsController {
    
    enum Section { case main }
    
    typealias SectionType = Section
    typealias ItemType = LookupConversationProperties
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> { }
    
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.register(CustomerCell.self)
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, conversation) -> UITableViewCell? in
            guard self != nil else { return nil }
            let cell = tableView.dequeueReusableCell(CustomerCell.self, for: indexPath)
            cell.configureCell(with: conversation)
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
            return cell
        })
    }
    
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(lookupConversations)
        return snapshot
    }
    
    func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot(), dataSource != nil else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.tableView.reloadData() }
            if self.lookupConversations.isEmpty {
                self.historyPlaceholderLabel.text = "No Data"
                self.historyPlaceholderLabel.isHidden = false
            } else {
                self.historyPlaceholderLabel.isHidden = true
            }
            self.stopHistorySpinner()
            self.handleSegmentViewsState()
        })
    }
}


extension CustomerDetailsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomerCell.cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let conversation = dataSource.itemIdentifier(for: indexPath) else { return }
        initiateOpenConversationSequence(for: conversation)
    }
    
    
    
    
    
    
    
    private func initiateOpenConversationSequence(for conversation: ItemType) {
        guard let conversationID = conversation.externalConversationId, conversationID != 0 else {
            printAndLog(message: "### \(#function) - Conversation Id = 0 for conversation: \(conversation)", log: .ui, logType: .error)
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Conversation data corrupted")
            }
            return
        }
        guard let node = conversation.node, !node.isBlank else {
            printAndLog(message: "### \(#function) - Conversation node unavailable in conversation: \(conversation)", log: .ui, logType: .error)
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Conversation data corrupted")
            }
            return
        }
        let group = node.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        guard let workerIdSubstring = group.first,
            let workerID = Int(workerIdSubstring),
            workerID != 0 else {
                printAndLog(message: "### \(#function) - Failed to get worker id from node: \(node)", log: .ui, logType: .error)
                DispatchQueue.main.async {
                    UIAlertController.showTelaAlert(title: "Error", message: "Agent details unavailable.")
                }
                return
        }
        
        openConversation(workerID: workerID, conversationID: conversationID)
    }
    
    private func openConversation(workerID: Int, conversationID: Int) {
        let context = PersistentContainer.shared.viewContext
        
        // MARK: - Fetch Agent from store for this workerID
        let agentsFetchRequest: NSFetchRequest<Agent> = Agent.fetchRequest()
        agentsFetchRequest.predicate = NSPredicate(format: "\(#keyPath(Agent.workerID)) = %d", workerID)
        var optionalAgent: Agent?
        var coreDataError: Error?
        context.performAndWait {
            do {
                optionalAgent = try agentsFetchRequest.execute().first
            } catch {
                coreDataError = error
            }
        }
        guard let agent = optionalAgent else {
            let message = coreDataError != nil ?
                "### \(#function) - Failed to fetch agent from core data store where Worker ID: \(workerID) | Error: \n\(coreDataError!.localizedDescription)" :
                                "### \(#function) - Failed to fetch agent from core data store where Worker ID: \(workerID)"
            printAndLog(message: message, log: .coredata, logType: .error)
            
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Agent details unavailable.")
            }
            return
        }
        
        // MARK: - Fetch Conversation from store for this externalConversationID
        let conversationFetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        conversationFetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.externalConversationID)) = %d AND \(#keyPath(Customer.agent)) == %@", conversationID, agent)
        var optionalConversation: Customer?
        var conversationFetchError: Error?
        context.performAndWait {
            do {
                optionalConversation = try conversationFetchRequest.execute().first
            } catch {
                conversationFetchError = error
            }
        }
        if let error = conversationFetchError {
            let message = "### \(#function) - Failed to fetch conversation from core data store where Worker ID: \(workerID) & conversationID: \(conversationID) | Error: \n\(error.localizedDescription)"
            printAndLog(message: message, log: .coredata, logType: .error)
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "App Error. Please report.")
            }
            return
        }
        
        
        if let conversation = optionalConversation {
            // MARK: - Conversation available in store
            
            DispatchQueue.main.async {
                let vc = MessagesController(customer: conversation)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            // MARK: - Conversation unavailable in store; Fetching from Firebase
            
            let reference = Config.FirebaseConfig.Node.conversations(companyID: AppData.companyId, workerID: workerID).reference
            reference.child("\(conversationID)").observeSingleEvent(of: .value, with: { snapshot in
                print("•••••••••••••\nSnapshot:\n\(snapshot)\n\n•••••••••••")
                if let firebaseConversationObject = FirebaseCustomer(snapshot: snapshot, workerID: "\(workerID)") {
                    
                    // MARK: - Saving new firebase conversation object in store
                    var newConversation: Customer?
                    context.performAndWait {
                        newConversation = Customer(context: context, conversationEntryFromFirebase: firebaseConversationObject, agent: agent)
                        do {
                            if context.hasChanges { try context.save() }
                        } catch {
                            printAndLog(message: "### \(#function) - Error saving new conversation into store where Firebase Conversation Object: \(firebaseConversationObject) & Error: \n\(error.localizedDescription)", log: .coredata, logType: .error)
                            fatalError()
                        }
                    }
                    DispatchQueue.main.async {
                        let vc = MessagesController(customer: newConversation!)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    printAndLog(message: "### \(#function) - Cannot create Firebase Customer object because data is corrupted or unhandled datatype", log: .firebase, logType: .error)
                    DispatchQueue.main.async {
                        UIAlertController.showTelaAlert(title: "Error", message: "Corrupted conversation data from server.")
                    }
                }
                
            }) { error in
                printAndLog(message: "Failed to fetch conversation from Firebase where conversation ID: \(conversationID) and Worker ID: \(workerID) | Error: \n\(error.localizedDescription)", log: .firebase, logType: .error)
                DispatchQueue.main.async {
                    UIAlertController.showTelaAlert(title: "Error", message: "Failed to get conversation details from server. Please try again.")
                }
            }
        }
    }
}



