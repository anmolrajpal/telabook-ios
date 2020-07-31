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
        case mediaAutoDownload = 0, cacheControl, notifications, general
        
        var header:String {
            switch self {
                case .mediaAutoDownload: return "Media Auto-Download"
                case .cacheControl: return "Cache Control"
                case .notifications: return "Notifications & Alerts"
                case .general: return "General"
            }
        }
        var footer:String? {
            switch self {
                case .mediaAutoDownload: return "Controls media messages automatic download settings."
                case .cacheControl: return "Clears cache directory, all cached media and cleans up database."
                case .notifications: return "Manage notification and alert preferences."
                case .general: return "Manage app general settings"
            }
        }
        var rows:[SettingRow] {
            switch self {
                case .mediaAutoDownload: return [
                    .photosOption, .videosOption, .restoreDefaultsOption
                ]
                case .cacheControl: return [
                    .clearAllCache, .clearAgentGalleryCache, .clearConversationGalleryCache
                ]
                case .notifications:
                    return [
                        .alertOnImageSave
                    ]
                case .general: return [
                    .appHaptics
                ]
            }
        }
    }
    enum SettingRow:CaseIterable {
        case photosOption, videosOption, restoreDefaultsOption, clearAllCache, clearAgentGalleryCache, clearConversationGalleryCache, enableNotifications, enableNotificationAlerts, alertOnImageSave, appHaptics
        
        var section:Section {
            switch self {
                case .photosOption: return .mediaAutoDownload
                case .videosOption: return .mediaAutoDownload
                case .restoreDefaultsOption: return .mediaAutoDownload
                case .clearAllCache: return .cacheControl
                case .clearAgentGalleryCache: return .cacheControl
                case .clearConversationGalleryCache: return .cacheControl
                case .enableNotifications: return .notifications
                case .enableNotificationAlerts: return .notifications
                case .alertOnImageSave: return .notifications
                case .appHaptics: return .general
            }
        }
        var setting:Setting {
            switch self {
                case .photosOption: return Setting(name: "Photos", value: AppData.autoDownloadImageMessagesState.stringValue)
                case .videosOption: return Setting(name: "Videos", value: AppData.autoDownloadVideoMessagesState.stringValue)
                case .restoreDefaultsOption: return Setting(name: "Restore Defaults", value: nil)
                case .clearAllCache: return Setting(name: "Clear All Cache", value: nil)
                case .clearAgentGalleryCache: return Setting(name: "Clear Agent's Gallery Cache", value: nil)
                case .clearConversationGalleryCache: return Setting(name: "Clear Conversation Gallery Cache", value: nil)
                case .enableNotifications: return Setting(name: "Enable Notifications", value: nil)
                case .enableNotificationAlerts: return Setting(name: "Enable Notification Alerts", value: nil)
                case .alertOnImageSave: return Setting(name: "Save Image Alerts", value: AppData.alertOnSavingMediaToLibrary)
                case .appHaptics: return Setting(name: "App Haptics", value: AppData.isHapticsEnabled)
            }
        }
    }
    struct Setting: Hashable {
        let name: String
        let value: Any?
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
        self.subview.tableView.register(KeyValueCell.self)
        self.subview.tableView.register(UITableViewCell.self)
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(tableView: subview.tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            let cell:UITableViewCell
            switch item.section {
                case .mediaAutoDownload:
                    switch item {
                        case .restoreDefaultsOption:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            let isEnabled = !AppData.isMediaAutoDownloadSettingsStateAtDefault
                            cell.textLabel?.textColor = isEnabled ? .telaBlue : .tertiaryLabel
                            cell.selectionStyle = isEnabled ? .default : .none
                        default:
                            cell = tableView.dequeueReusableCell(KeyValueCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.detailTextLabel?.text = item.setting.value as? String
                            cell.accessoryType = .disclosureIndicator
                }
                case .cacheControl:
                    switch item {
                        case .clearAllCache:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.textLabel?.textColor = .telaBlue
                        case .clearAgentGalleryCache:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.textLabel?.textColor = .telaBlue
                        case .clearConversationGalleryCache:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.textLabel?.textColor = .telaBlue
                        default: fatalError()
                }
                case .notifications:
                    switch item {
                        case .enableNotifications:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.textLabel?.textColor = .telaBlue
                        
                        case .enableNotificationAlerts:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.textLabel?.textColor = .telaBlue
                        
                        case .alertOnImageSave:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.selectionStyle = .none
                            let isOn = item.setting.value as! Bool
                            let switchButton = UISwitch()
                            switchButton.tintColor = UIColor.telaGray5
                            switchButton.thumbTintColor = UIColor.white
                            switchButton.onTintColor = UIColor.telaBlue
                            switchButton.isOn = isOn
                            switchButton.addTarget(self, action: #selector(self.saveMediaNotificationAlertStateDidChange(_:)), for: .valueChanged)
                            cell.accessoryView = switchButton
                        
                        default: fatalError()
                }
                case .general:
                    switch item {
                        case .appHaptics:
                            cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                            cell.textLabel?.text = item.setting.name
                            cell.selectionStyle = .none
                            let isOn = item.setting.value as! Bool
                            let switchButton = UISwitch.createTelaSwitch()
                            switchButton.isOn = isOn
                            switchButton.addTarget(self, action: #selector(self.appHapticFeebackSettingStateDidChange(_:)), for: .valueChanged)
                            cell.accessoryView = switchButton
                        default: fatalError()
                }
            }
            return cell
        })
        updateUI(animating: false)
    }
    
    
    func updateUI(with snapshot: NSDiffableDataSourceSnapshot<SectionType, ItemType>? = nil, animating:Bool = true, reloadingData:Bool = false) {
        if let snapshot = snapshot {
            dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
                guard let self = self else { return }
                if reloadingData { self.subview.tableView.reloadData() }
            })
        } else {
            guard let snapshot = currentSnapshot() else { return }
            dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
                guard let self = self else { return }
                if reloadingData { self.subview.tableView.reloadData() }
            })
        }
    }
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.mediaAutoDownload, .cacheControl, .notifications, .general])
        snapshot.appendItems(Section.mediaAutoDownload.rows, toSection: .mediaAutoDownload)
        snapshot.appendItems(Section.cacheControl.rows, toSection: .cacheControl)
        snapshot.appendItems(Section.notifications.rows, toSection: .notifications)
        snapshot.appendItems(Section.general.rows, toSection: .general)
        return snapshot
    }
}


extension AppSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let option = dataSource.itemIdentifier(for: indexPath) else { return }
        handleSetting(forSelectedOption: option, at: indexPath, in: tableView)
    }
    
    
    
    func handleSetting(forSelectedOption item:SettingRow, at indexPath: IndexPath, in tableView:UITableView) {
        switch item {
            
            /// - Tag: Media Auto-Download Section
            
            //MARK: - Photos Option
            case .photosOption:
                let options:[ListItem] =
                    MediaAutoDownloadState.allCases.map { state in
                        ListItem(title: state.stringValue,
                                 isSelected: AppData.autoDownloadImageMessagesState == state,
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
            
            
            
            
            
            /// - Tag: Cache Control Section
            
            //MARK: - Clear All Cache
            case .clearAllCache:
                tableView.deselectRow(at: indexPath, animated: true)
                alertClearCache()
            
            
            
            //MARK: - Clear Agent's Gallery Cache
            case .clearAgentGalleryCache:
                tableView.deselectRow(at: indexPath, animated: true)
                alertClearAgentGalleryCache()
            
            
            
            //MARK: - Clear Conversation Gallery Cache
            case .clearConversationGalleryCache:
                tableView.deselectRow(at: indexPath, animated: true)
                alertClearConversationGalleryCache()
            
            
            
            
            
            
            /// - Tag: Notifications and Alerts Section
            
            // MARK:- Enable Notifications - Open Settings
            case .enableNotifications:
                tableView.deselectRow(at: indexPath, animated: true)
                alertNotificationsEnabledNeeded()
            
            
            
            // MARK:- Enable Notification Alerts - Open Settings
            case .enableNotificationAlerts:
                tableView.deselectRow(at: indexPath, animated: true)
                alertNotificationAlertsEnabledNeeded()
            
            
            
            
            // MARK: - Alert on saving media to Photo Library
            case .alertOnImageSave: break
            
            
            
            
            
            
            
            
            /// - Tag: Cache Control Section
            
            // MARK: - In App Haptic Feedback setting
            case .appHaptics: break
            
            
            
        }
    }
}

