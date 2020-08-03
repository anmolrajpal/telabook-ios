//
//  DisabledAccounts+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension DisabledAccountsController {
    enum Section { case main }
    
    class DataSource: UITableViewDiffableDataSource<Section, DisabledAccountProperties> {}
    
    internal func configureTableView() {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 85, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.refreshControl = tableViewRefreshControl
        tableView.register(AgentCell.self)
        tableView.delegate = self
    }
    
    internal func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, agent) -> UITableViewCell? in
            guard self != nil else { return nil }
            let cell = tableView.dequeueReusableCell(DisabledAccountCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.shouldShowBadgeCount = false
            cell.accessoryType = .disclosureIndicator
            cell.configureCell(with: agent)
            return cell
        })
    }
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, DisabledAccountProperties>? {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DisabledAccountProperties>()
        snapshot.appendSections([.main])
        snapshot.appendItems(disabledAccounts)
        return snapshot
    }
    func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot(), dataSource != nil else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData && self.viewDidAppear { self.tableView.reloadData() }
            self.handleState()
        })
    }
}



// MARK:  - UITableViewDelegate
/// - tag: UITableViewDelegate
extension DisabledAccountsController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
