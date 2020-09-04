//
//  AgentCalls+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 02/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AgentCallsViewController {
    class Section: Hashable {
        var identifier = UUID()
        
        var title: String {
            if let date = groupedCalls[0].recentCall.timestampDate {
                let string = Date.getStringFromDate(date: date, dateFormat: .dMMMMyyyy)
                return string
            } else {
                return "Invalid Date"
            }
        }
        
        var groupedCalls: [ItemType]
        
        init(groupedCalls: [ItemType]) {
            self.groupedCalls = groupedCalls
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: Section, rhs: Section) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }
    
    
    // MARK: - Value Types
    
    typealias SectionType = Section
    typealias ItemType = GroupedCall
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return snapshot().sectionIdentifiers[section].title
        }
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.register(AgentCallCell.self)
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, groupedCall) -> UITableViewCell? in
            guard self != nil else { return nil }
            let cell = tableView.dequeueReusableCell(AgentCallCell.self, for: indexPath)
            let parameters: AgentCallCell.Parameters = .init(profileImageURL: nil,
                                                             name: groupedCall.recentCall.customerName,
                                                             phoneNumber: groupedCall.recentCall.customerCid ?? "",
                                                             count: groupedCall.calls.count,
                                                             callDirection: groupedCall.recentCall.callDirection,
                                                             callStatus: groupedCall.recentCall.callStatus,
                                                             date: groupedCall.recentCall.timestampDate)
            cell.configureCell(with: parameters)
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
            return cell
        })
    }
    
    
    func initialSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.groupedCalls, toSection: section)
        }
        return snapshot
    }
    func currentSnapshot() -> Snapshot {
        guard dataSource != nil else {
            fatalError("### \(#function) Datasource not initialized")
        }
        return dataSource.snapshot()
    }
    func updateUI(with snapshot: Snapshot? = nil, animating:Bool = true, reloadingData:Bool = false) {
        guard dataSource != nil else { return }
        dataSource.apply(snapshot ?? initialSnapshot(), animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.tableView.reloadData() }
        })
    }
}

extension AgentCallsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgentCallCell.cellHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
