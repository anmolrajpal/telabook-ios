//
//  AppSettings+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import PINCache

extension AppSettingsViewController {
    // MARK: - common setup
    internal func commonInit() {
        title = "APP SETTINGS"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        configureTableView()
        configureDataSource()
        checkNotificationsPreferences()
        observeForegroundNotifications()
    }
    func checkNotificationsPreferences() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined, .denied:
                    guard var snapshot = self.currentSnapshot() else { return }
                    snapshot.insertItems([.enableNotifications], beforeItem: .alertOnImageSave)
                    DispatchQueue.main.async {
                        self.updateUI(with: snapshot)
                    }
                case .authorized, .provisional:
                    // Deliver Quietly
                    if settings.soundSetting == .disabled,
                        settings.alertSetting == .disabled,
                        settings.badgeSetting == .disabled {
                        guard var snapshot = self.currentSnapshot() else { return }
                        snapshot.insertItems([.enableNotificationAlerts], beforeItem: .alertOnImageSave)
                        DispatchQueue.main.async {
                            self.updateUI(with: snapshot)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                    }
            case .ephemeral: break
                @unknown default: fatalError()
            }
        }
    }
    internal func observeForegroundNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    internal func removeForegroundNotificationsObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    @objc
    private func applicationWillEnterForeground() {
        checkNotificationsPreferences()
    }
    internal func clearsTableViewSelectionOnViewDidAppear(_ animated: Bool) {
        if let selectionIndexPath = self.subview.tableView.indexPathForSelectedRow {
            self.subview.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    internal func alertClearCache() {
        let alert = UIAlertController.telaAlertController(title: "Clear All Cache", message: "This will clear all cached media and data from the app")
        let clearAction = UIAlertAction(title: "Clear", style: .default) { (action:UIAlertAction) in
            self.clearCache()
        }
        clearAction.setTitleColor(color: .systemRed)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setTitleColor(color: .telaBlue)
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        alert.preferredAction = clearAction
        self.present(alert, animated: true, completion: nil)
    }
    internal func alertClearConversationGalleryCache() {
        let alert = UIAlertController.telaAlertController(title: "Clear Cache", message: "This will clear all cached gallery items for all conversations")
        let clearAction = UIAlertAction(title: "Clear", style: .default) { (action:UIAlertAction) in
            self.clearConversationsGalleryCacheDirectory()
        }
        clearAction.setTitleColor(color: .systemRed)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setTitleColor(color: .telaBlue)
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        alert.preferredAction = clearAction
        self.present(alert, animated: true, completion: nil)
    }
    internal func alertClearAgentGalleryCache() {
        let alert = UIAlertController.telaAlertController(title: "Clear Cache", message: "This will clear all cached gallery items for all agents")
        let clearAction = UIAlertAction(title: "Clear", style: .default) { (action:UIAlertAction) in
            self.clearAgentGalleryCacheDirectory()
        }
        clearAction.setTitleColor(color: .systemRed)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setTitleColor(color: .telaBlue)
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        alert.preferredAction = clearAction
        self.present(alert, animated: true, completion: nil)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    private func clearCache() {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = DeleteAllEntities_Operation(context: PersistentContainer.shared.newBackgroundContext())
        operation.completionBlock = {
            if let error = operation.error {
                printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
            } else {
                PINCache.shared.removeAllObjects()
                imageCache.removeAllObjects()
                self.clearCacheDirectory()
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    private func clearCacheDirectory() {
        let appName:String = try! Configuration.value(for: .bundleDisplayName)
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let appFolderURL = cacheURL.appendingPathComponent(appName, isDirectory: true)
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: appFolderURL, includingPropertiesForKeys: nil, options: [])
            directoryContents.forEach({
                do {
                    try fileManager.removeItem(at: $0)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func clearConversationsGalleryCacheDirectory() {
        let cacheURL = AppDelegate.conversationMediaFolder
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            directoryContents.forEach({
                do {
                    try fileManager.removeItem(at: $0)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    private func clearAgentGalleryCacheDirectory() {
        let cacheURL = AppDelegate.agentGalleryMediaFolder
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            directoryContents.forEach({
                do {
                    try fileManager.removeItem(at: $0)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    
    
    
    @objc
    internal func saveMediaNotificationAlertStateDidChange(_ sender:UISwitch) {
        AppData.alertOnSavingMediaToLibrary = sender.isOn
    }
    
    @objc
    internal func appHapticFeebackSettingStateDidChange(_ sender:UISwitch) {
        AppData.isHapticsEnabled = sender.isOn
    }
    
}
