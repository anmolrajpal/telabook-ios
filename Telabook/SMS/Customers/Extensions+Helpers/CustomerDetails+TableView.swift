//
//  CustomerDetails+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

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
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let conversation = dataSource.itemIdentifier(for: indexPath) else { return }
        
        print(conversation.externalConversationId ?? 0)
    }
}



