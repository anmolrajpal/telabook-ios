//
//  AppSettings+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AppSettingsViewController {
    enum Section:Int {
        case mediaAutoDownload = 0, cacheControl
        
        var header:String {
            switch self {
            case .mediaAutoDownload: return "Media Auto-Download"
            case .cacheControl: return "Cache Control"
            }
        }
        var footer:String? {
            switch self {
            case .mediaAutoDownload: return "Controls media messages automatic download settings."
            case .cacheControl: return "Clears cache directory, all cached media and cleans up database."
            }
        }
        var rows:[SettingRow] {
            switch self {
                case .mediaAutoDownload: return [
                    .photosOption, .videosOption, .restoreDefaultsOption
                ]
                case .cacheControl: return [
                    .clearCache
                ]
            }
        }
    }
    enum SettingRow:CaseIterable {
        case photosOption, videosOption, restoreDefaultsOption, clearCache
        
        var section:Section {
            switch self {
                case .photosOption: return .mediaAutoDownload
                case .videosOption: return .mediaAutoDownload
                case .restoreDefaultsOption: return .mediaAutoDownload
                case .clearCache: return .cacheControl
            }
        }
        var setting:Setting {
            switch self {
                case .photosOption: return Setting(name: "Photos", value: AppData.autoDownloadImageMessagesState.stringValue)
                case .videosOption: return Setting(name: "Videos", value: AppData.autoDownloadVideoMessagesState.stringValue)
                case .restoreDefaultsOption: return Setting(name: "Restore Defaults", value: nil)
                case .clearCache: return Setting(name: "Clear Cache", value: nil)
            }
        }
    }
    struct Setting: Hashable {
        let name: String
        let value: String?
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: Setting, rhs: Setting) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    
    typealias SectionType = Section
    typealias ItemType = SettingRow
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {
        
        // MARK: header/footer titles support
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            let sectionKind = Section(rawValue: section)
            return sectionKind?.header
        }
        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            let sectionKind = Section(rawValue: section)
            return sectionKind?.footer
        }
    }
    func configureTableView() {
        self.subview.tableView.delegate = self
        self.subview.tableView.register(KeyValueCell.self, forCellReuseIdentifier: KeyValueCell.identifier)
        self.subview.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        configureDataSource()
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell:UITableViewCell
            switch item.section {
                case .mediaAutoDownload:
                    switch item {
                        case .restoreDefaultsOption:
                            cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            let isEnabled = !AppData.isMediaAutoDownloadSettingsStateAtDefault
                            cell.textLabel?.textColor = isEnabled ? .telaBlue : .tertiaryLabel
                            cell.selectionStyle = isEnabled ? .default : .none
                        default:
                            cell = tableView.dequeueReusableCell(withIdentifier: KeyValueCell.identifier, for: indexPath) as! KeyValueCell
                            cell.textLabel?.text = item.setting.name
                            cell.detailTextLabel?.text = item.setting.value
                            cell.accessoryType = .disclosureIndicator
                }
                case .cacheControl:
                    switch item {
                        case .clearCache:
                            cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.textLabel?.textColor = .telaBlue
                        default: fatalError()
                }
            }
            return cell
        })
        updateUI(animating: false)
    }
    func updateUI(animating:Bool = true, reloadingData:Bool = true) {
        guard let snapshot = currentSnapshot() else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.subview.tableView.reloadData() }
        })
    }
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.mediaAutoDownload])
        snapshot.appendItems(Section.mediaAutoDownload.rows)
        snapshot.appendSections([.cacheControl])
        snapshot.appendItems(Section.cacheControl.rows)
        return snapshot
    }
}


extension AppSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let option = self.dataSource.itemIdentifier(for: indexPath) else { return }
        handleSetting(forSelectedOption: option, at: indexPath, in: tableView)
    }
    
    
    
    func handleSetting(forSelectedOption item:SettingRow, at indexPath: IndexPath, in tableView:UITableView) {
        switch item {
            
            
            //MARK: - Photos Option
            case .photosOption:
                let options:[ListItem] =
                    MediaAutoDownloadState.allCases.map { state in
                        ListItem(title: state.stringValue,
                                 subtitle: state == .wifi ? "This feature will be available soon" : nil,
                                 isSelected: AppData.autoDownloadImageMessagesState == state,
                                 isDisabled: state == .wifi ? true : false,
                                 handler: { [weak self] _ in
                                    AppData.autoDownloadImageMessagesState = state
                                    self?.subview.tableView.reloadData()
                                    self?.subview.tableView.selectRow(at: self?.selectedIndexPath, animated: false, scrollPosition: .none)
                        })
                }
                let picker = ListPickerController(listItems: options, style: .insetGrouped)
                picker.title = item.setting.name
                show(picker, sender: self)
            
            
            
            
            //MARK: - Videos Option
            case .videosOption:
                let options:[ListItem] =
                    MediaAutoDownloadState.allCases.map { state in
                        ListItem(title: state.stringValue,
                                 isSelected: AppData.autoDownloadVideoMessagesState == state,
                                 handler: { [weak self] _ in
                                    AppData.autoDownloadVideoMessagesState = state
                                    self?.subview.tableView.reloadData()
                                    self?.subview.tableView.selectRow(at: self?.selectedIndexPath, animated: false, scrollPosition: .none)
                        })
                }
                let picker = ListPickerController(listItems: options, style: .insetGrouped)
                picker.title = item.setting.name
                show(picker, sender: self)
            
            
            
            
            
            //MARK: - Restore Defaults Option
            case .restoreDefaultsOption:
                tableView.deselectRow(at: indexPath, animated: true)
                let isEnabled = !AppData.isMediaAutoDownloadSettingsStateAtDefault
                if !isEnabled { return }
                AppData.restoreAutoDownloadMediaMessagesSettingsDefaults()
                self.updateUI(animating:false, reloadingData: false)
            
            
            
            
            //MARK: - Clear Cache
            case .clearCache:
                tableView.deselectRow(at: indexPath, animated: true)
                alertClearCache()
            
        }
    }
}

