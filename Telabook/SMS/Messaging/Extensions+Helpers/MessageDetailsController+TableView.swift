//
//  MessageDetailsController+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension MessageDetailsViewController {
    
    func dateString(from date:Date?) -> String {
        guard let date = date else { return "--" }
        return Date.getStringFromDate(date: date, dateFormat: .hmma)
    }
    enum Section:Int {
        case defaultInfo = 0, debugInfo
        
        var header:String? {
            switch self {
                case .defaultInfo: return "Details"
                case .debugInfo: return "Debug Info"
            }
        }
        var footer:String? {
            switch self {
                case .defaultInfo: return "Default Info"
                case .debugInfo: return "Debug Info"
            }
        }
        var rows:[PropertyRow] {
            switch self {
                case .defaultInfo: return [
                    .deliveredByProvider, .sentByProvider, .sentByApi
                ]
                case .debugInfo: return [
                    .firebaseUID, .conversationID, .conversationNode
                ]
            }
        }
    }
    enum PropertyRow:CaseIterable {
        case sentByApi, sentByProvider, deliveredByProvider, firebaseUID, conversationID, conversationNode
        
        
        var section:Section {
            switch self {
                case .sentByApi: return .defaultInfo
                case .sentByProvider: return .defaultInfo
                case .deliveredByProvider: return .defaultInfo
                case .firebaseUID: return .debugInfo
                case .conversationID: return .debugInfo
                case .conversationNode: return .debugInfo
            }
        }
        var property:MessageProperty {
            switch self {
                case .sentByApi: return MessageProperty(name: "Sent", value: nil)
                case .sentByProvider: return MessageProperty(name: "Sent by Provider", value: nil)
                case .deliveredByProvider: return MessageProperty(name: "Delivered", value: nil)
                case .firebaseUID: return MessageProperty(name: "Firebase UID", value: nil)
                case .conversationID: return MessageProperty(name: "Conversation ID", value: nil)
                case .conversationNode: return MessageProperty(name: "Conversation Node", value: nil)
            }
        }
    }
    struct MessageProperty: Hashable {
        let name: String
        let value: Any?
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: MessageProperty, rhs: MessageProperty) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    
    typealias SectionType = Section
    typealias ItemType = PropertyRow
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {
        weak var controller:MessageDetailsViewController?
        // MARK: header/footer titles support
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard let controller = controller else { return nil }
            if controller.isFromCurrentSender(message: controller.message) {
                let sectionKind = Section(rawValue: section)
                return sectionKind?.header
            } else {
                let sectionKind = Section(rawValue: 1)
                return sectionKind?.header
            }
        }
        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//            let sectionKind = Section(rawValue: section)
            return nil
        }
    }
    func configureTableView() {
        tableView.register(KeyValueCell.self)
        configureDataSource()
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            let cell = tableView.dequeueReusableCell(KeyValueCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            switch item.section {
                case .defaultInfo:
                    let imageSize = CGSize(width: 18, height: 18)
                    cell.textLabel?.text = item.property.name
                    switch item {
                        case .deliveredByProvider:
                            cell.imageView?.image = self.blueDoubleTickImage(size: imageSize)
                            cell.detailTextLabel?.text = self.dateString(from: self.message.deliveredByProviderAt)
                        case .sentByProvider:
                            cell.imageView?.image = self.grayDoubleTickImage(size: imageSize)
                            cell.detailTextLabel?.text = self.dateString(from: self.message.sentByProviderAt)
                        case .sentByApi:
                            cell.imageView?.image = self.singleTickImage(size: imageSize)
                            cell.detailTextLabel?.text = self.dateString(from: self.message.sentByApiAt)
                        default:
                       let errorMessage = "### \(#function) | ### \(#file) | Error: Unhandled case for property row under defaultInfo section: \(item)"
                       printAndLog(message: errorMessage, log: .default, logType: .error)
                       fatalError(errorMessage)
                    }
                case .debugInfo:
                    cell.textLabel?.text = item.property.name
                    switch item {
                        case .firebaseUID:
                            cell.detailTextLabel?.text = self.message.messageId
                        case .conversationID:
                            cell.detailTextLabel?.text = String(self.message.conversationID)
                        case .conversationNode:
                            cell.detailTextLabel?.text = self.message.conversation?.node
                        default:
                       let errorMessage = "### \(#function) | ### \(#file) | Error: Unhandled case for property row under debugInfo section: \(item)"
                       printAndLog(message: errorMessage, log: .default, logType: .error)
                       fatalError(errorMessage)
                }
            }
            return cell
        })
        dataSource.controller = self
        updateUI(animating: false)
    }
    
    func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot() else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.tableView.reloadData() }
        })
    }
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        if isFromCurrentSender(message: message) {
            snapshot.appendSections([.defaultInfo])
            snapshot.appendItems(Section.defaultInfo.rows, toSection: .defaultInfo)
        }
        if AppData.getUserRole() == .Developer {
            snapshot.appendSections([.debugInfo])
            snapshot.appendItems(Section.debugInfo.rows, toSection: .debugInfo)
        }
        return snapshot
    }
}
