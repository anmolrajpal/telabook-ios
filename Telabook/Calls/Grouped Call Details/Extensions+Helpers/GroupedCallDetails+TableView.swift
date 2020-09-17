//
//  GroupedCallDetails+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension GroupedCallDetailsViewController {
    
    enum Section { case main }
    
    typealias SectionType = Section
    typealias ItemType = AgentCallProperties
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> { }
    
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.register(AgentCallCell.self)
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, agentCall) -> UITableViewCell? in
            guard self != nil else { return nil }
            let cell = tableView.dequeueReusableCell(AgentCallCell.self, for: indexPath)
            let parameters: AgentCallCell.Parameters = .init(profileImageURL: nil,
                                                             name: agentCall.customerName,
                                                             phoneNumber: agentCall.customerCid ?? "",
                                                             count: 0,
                                                             callDirection: agentCall.callDirection,
                                                             callStatus: agentCall.callStatus,
                                                             date: agentCall.timestampDate)
            cell.configureCell(with: parameters)
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
            return cell
        })
    }
    
    func initialSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(agentCalls, toSection: .main)
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

// MARK: - UITableViewDelegate

extension GroupedCallDetailsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgentCallCell.cellHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let agentCall = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = CallDetailsViewController(agentCall: agentCall)
        navigationController?.pushViewController(vc, animated: true)
    }
}
