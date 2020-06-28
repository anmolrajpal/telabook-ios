//
//  ScheduledMessages+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ScheduleMessageViewController {
    enum Section { case  main }
    
    typealias SectionType = Section
    typealias ItemType = ScheduledMessage
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {}
    internal func configureTableView() {
        tableView.delegate = self
        tableView.register(ScheduledMessageCell.self)
        configureDataSource()
    }
    private func configureDataSource() {
        self.dataSource = DataSource(tableView: tableView, cellProvider: { (tableView, indexPath, scheduledMessage) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(ScheduledMessageCell.self, for: indexPath)
            cell.configureCell(with: scheduledMessage)
            cell.selectionStyle = .none
//            cell.scheduledMessage = scheduledMessage
            return cell
        })
        updateUI(animating: false)
    }
    internal func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot() else { return }
        guard dataSource != nil else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.tableView.reloadData() }
            if !self.scheduledMessages.isEmpty {
                self.stopSpinner()
                self.placeholderLabel.isHidden = true
            } else {
                self.placeholderLabel.isHidden = false
                self.placeholderLabel.text = "No Data"
            }
        })
    }
    private func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(scheduledMessages)
        return snapshot
    }
}

extension ScheduleMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 174
    }
}
