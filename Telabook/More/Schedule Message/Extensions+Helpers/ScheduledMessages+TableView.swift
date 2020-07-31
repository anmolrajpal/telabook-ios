//
//  ScheduledMessages+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

fileprivate protocol DataSourceDelegate: class {
    func dataSourceDidUpdate()
}

extension ScheduleMessageViewController {
    enum Section { case  main }
    
    typealias SectionType = Section
    typealias ItemType = ScheduledMessage
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>
    
    class DataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> {
        fileprivate weak var delegate:DataSourceDelegate?
    }
    internal func configureTableView() {
        tableView.delegate = self
        tableView.register(ScheduledMessageCell.self)
        configureDataSource()
    }
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, objectID) -> UITableViewCell? in
            guard let self = self else { return nil }
            let cell = tableView.dequeueReusableCell(ScheduledMessageCell.self, for: indexPath)
//            let scheduledMessage = self.viewContext.object(with: objectID) as! ScheduledMessage
            let scheduledMessage = self.fetchedResultsController.object(at: indexPath)
            cell.configureCell(with: scheduledMessage, animated: false)
            cell.selectionStyle = .none
            return cell
        })
        dataSource.delegate = self
//        performFetch()
//        updateUI(animating: false)
    }
//    internal func updateUI(animating:Bool = true, reloadingData:Bool = false) {
//        guard let snapshot = currentSnapshot() else { return }
//        guard dataSource != nil else { return }
//        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
//            guard let self = self else { return }
//            if reloadingData { self.tableView.reloadData() }
//            if !self.scheduledMessages.isEmpty {
//                self.stopSpinner()
//                self.placeholderLabel.isHidden = true
//            } else {
//                self.placeholderLabel.isHidden = false
//                self.placeholderLabel.text = "No Data"
//            }
//        })
//    }
//    private func currentSnapshot() -> Snapshot? {
//        var snapshot = Snapshot()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(scheduledMessages)
//        return snapshot
//    }
}

extension ScheduleMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 174
    }
}

extension ScheduleMessageViewController.DataSource: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let newSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        if self.snapshot().numberOfItems == 0 {
            self.apply(newSnapshot, animatingDifferences: false) {
                self.delegate?.dataSourceDidUpdate()
            }
        }
        if self.snapshot().numberOfItems == newSnapshot.numberOfItems {
            self.apply(newSnapshot, animatingDifferences: false) {
                self.delegate?.dataSourceDidUpdate()
            }
        }
        self.apply(newSnapshot, animatingDifferences: true) {
            self.delegate?.dataSourceDidUpdate()
        }
    }
}
extension ScheduleMessageViewController: DataSourceDelegate {
    func dataSourceDidUpdate() {
        if !self.scheduledMessages.isEmpty {
            self.stopSpinner()
            self.placeholderLabel.isHidden = true
        } else {
            self.placeholderLabel.isHidden = false
            self.placeholderLabel.text = "No Data"
        }
    }
}
//extension ScheduleMessageViewController:NSFetchedResultsControllerDelegate {
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//        updateUI(animating: false)
//    }
//}
