//
//  QuickResponsesTableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit


extension QuickResponsesViewController {
    
    internal enum Section { case main }
    
    internal class DataSource: UITableViewDiffableDataSource<Section, QuickResponse> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    }
    
    internal func configureTableView() {
        subview.tableView.register(UITableViewCell.self)
        subview.tableView.delegate = self
    }
    
    
    internal func configureDataSource() {
        dataSource = DataSource(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, quickResponse) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = quickResponse.answer
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = UIColor.telaGray7
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
            return cell
        })
    }
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, QuickResponse>? {
        guard fetchedResultsController != nil else { return nil }
        var snapshot = NSDiffableDataSourceSnapshot<Section, QuickResponse>()
        snapshot.appendSections([.main])
        snapshot.appendItems(quickResponses)
        return snapshot
    }
    func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot() else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.subview.tableView.reloadData() }
            self.handleState()
        })
    }
    
    
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        if self.isFetchedResultsAvailable {
            DispatchQueue.main.async {
                self.subview.placeholderLabel.isHidden = true
            }
        } else {
            self.subview.placeholderLabel.text = "No Data"
            DispatchQueue.main.async {
                self.subview.placeholderLabel.isHidden = false
            }
        }
    }
}

extension QuickResponsesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction =  UIContextualAction(style: .normal, title: "Edit", handler: { (action,view,completion ) in
            if let selectedResponse = self.dataSource?.itemIdentifier(for: indexPath) {
                self.showEditResponseDialogBox(quickResponse: selectedResponse)
                completion(true)
            }
        })
        editAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit"), text: "Edit").withRenderingMode(.alwaysTemplate)
        editAction.backgroundColor = UIColor.telaIndigo
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "Delete", handler: { (action,view,completion ) in
            if let selectedResponse = self.dataSource?.itemIdentifier(for: indexPath) {
                self.deleteQuickResponse(forSelectedResponse: selectedResponse, agent: self.agent, completion: completion)
            }
        })
        deleteAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "delete_icon"), text: "Delete").withRenderingMode(.alwaysTemplate)
        deleteAction.backgroundColor = UIColor.telaRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}



//MARK: Prefetching Logic for images: To be implemented | Problem: Diffable Data Source
/*
let serialQueue = DispatchQueue(label: "Decode queue")
extension QuickResponsesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            serialQueue.async {
                if let cell = self.diffableDataSource?.itemIdentifier(for: indexPath) {
                    
                }
                let downsampledImage = downsample(images[indexPath.row])
                DispatchQueue.main.async { self.update(at: indexPath, with: downsampledImage) }
            }
        }
    }
}
*/
