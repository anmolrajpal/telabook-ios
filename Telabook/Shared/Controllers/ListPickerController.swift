//
//  ListPickerController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class ListPickerController: UITableViewController {
    
    
    
    
    // MARK: - Properties
    private var listItems:[ListItem]
    var dataSource:DataSource!
    var allowsMultipleSelection:Bool = false
    var shouldPopOnSingleSelection:Bool = true
    private var selectedItemIndexPath:IndexPath? {
        guard let index = listItems.firstIndex(where: { $0.isSelected }) else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    
    // MARK: - Type Alias
    typealias PickerStyle = UITableView.Style
    
    
    
    
    // MARK: - init
    init(listItems:[ListItem], style:PickerStyle = .plain) {
        self.listItems = listItems
        super.init(style: style)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    private func commonInit() {
        setUpNavBar()
        configureTableView()
    }
}



extension ListPickerController {
    enum Section { case main }
    
    typealias SectionType = Section
    typealias ItemType = ListItem
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {}
    
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.register(SubtitleTableViewCell.self)
        tableView.register(UITableViewCell.self)
        configureDataSource()
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell:UITableViewCell
            if item.subtitle == nil {
                cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                cell.textLabel?.text = item.title
            } else {
                cell = tableView.dequeueReusableCell(SubtitleTableViewCell.self, for: indexPath)
                cell.textLabel?.text = item.title
                cell.detailTextLabel?.text = item.subtitle
            }
            cell.backgroundColor = UIColor.telaGray4
            cell.accessoryType = item.isSelected ? .checkmark : .none
            
            if item.isDisabled {
                cell.selectionStyle = .none
                cell.textLabel?.textColor = UIColor.tertiaryLabel
            } else {
                cell.selectionStyle = .default
                cell.textLabel?.textColor = UIColor.label
            }
            cell.tintColor = UIColor.telaBlue
            return cell
        })
        updateUI()
    }
    func updateUI(animating:Bool = true) {
        guard let snapshot = currentSnapshot() else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let _ = self else { return }
//            self.tableView.reloadData()
        })
    }
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(listItems)
        return snapshot
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if item.isDisabled { return }
        if !allowsMultipleSelection {
            if item.isSelected {
                if shouldPopOnSingleSelection {
                    navigationController?.popViewController(animated: true)
                    return
                } else {
                    return
                }
            } else {
                guard let previouslySelectedIndexPath = selectedItemIndexPath,
                    let previousCell = tableView.cellForRow(at: previouslySelectedIndexPath),
                    let previouslySelectedItem = dataSource.itemIdentifier(for: previouslySelectedIndexPath) else {
                        return
                }
                let updatedPreviouslySelectedItem = ListItem(identifier: previouslySelectedItem.identifier,
                                              title: previouslySelectedItem.title,
                                              subtitle: previouslySelectedItem.subtitle,
                                              isSelected: !previouslySelectedItem.isSelected,
                                              isDisabled: previouslySelectedItem.isDisabled,
                                              handler: previouslySelectedItem.handler)
                listItems.remove(at: previouslySelectedIndexPath.row)
                listItems.insert(updatedPreviouslySelectedItem, at: previouslySelectedIndexPath.row)
                previousCell.accessoryType = updatedPreviouslySelectedItem.isSelected ? .checkmark : .none
            }
        }
        let newItem = ListItem(identifier: item.identifier, title: item.title, subtitle: item.subtitle, isSelected: !item.isSelected, isDisabled: item.isDisabled, handler: item.handler)
        listItems.remove(at: indexPath.row)
        listItems.insert(newItem, at: indexPath.row)
        cell.accessoryType = newItem.isSelected ? .checkmark : .none
        updateUI()
        newItem.handler(newItem)
        if !allowsMultipleSelection && shouldPopOnSingleSelection {
            navigationController?.popViewController(animated: true)
        }
    }
}
