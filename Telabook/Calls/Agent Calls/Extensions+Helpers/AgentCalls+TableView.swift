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
    func createSpinnerFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        footerView.addSubview(footerSpinner)
        footerSpinner.centerInSuperview()
        return footerView
    }
    func configureTableView() {
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
        tableView.tableFooterView = createSpinnerFooterView()
        tableView.delegate = self
        tableView.refreshControl = tableViewRefreshControl
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
            self.handleState()
        })
    }
}


// MARK: - UITableViewDelegate

extension AgentCallsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgentCallCell.cellHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let groupedCall = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if groupedCall.calls.count > 1 {
            let vc = GroupedCallDetailsViewController()
            vc.agentCalls = groupedCall.calls
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CallDetailsViewController(agentCall: groupedCall.recentCall)
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}


// MARK: - UIScrollViewDelegate

extension AgentCallsViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let footerView = tableView.tableFooterView {
            if !shouldFetchMore {
                footerView.frame.size.height = 0
                tableView.tableFooterView = footerView
            }
            shouldFetchMore && !sections.isEmpty ? footerSpinner.startAnimating() : footerSpinner.stopAnimating()
        }
        
        let position = scrollView.contentOffset.y
        let threshold = tableView.contentSize.height - 100 - scrollView.frame.size.height
        
        if position > threshold {
            paginateAgentCalls()
        }
    }
}
