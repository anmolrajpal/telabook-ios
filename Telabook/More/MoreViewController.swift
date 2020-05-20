//
//  MoreViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupTableView()
//        setupAgentLogoutButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "MORE"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupAgentLogoutButton() {
        let role = AppData.getUserRole()
        if role == .Agent {
            setupNavBarItems()
        }
    }
    fileprivate func setupNavBarItems() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleRightBarButtonItem))
        let normalStateAttributes = [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)!,
            NSAttributedString.Key.foregroundColor: UIColor.telaRed]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(normalStateAttributes, for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(normalStateAttributes, for: .selected)
    }
    @objc func handleRightBarButtonItem() {
        alertLogout()
    }
    private func alertLogout() {
        let alertVC = UIAlertController.telaAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?")
        alertVC.addAction(UIAlertAction(title: "Log Out", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
            self.callSignOutSequence()
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    private func signOut() {
        let loginViewController = LoginViewController()
        loginViewController.isModalInPresentation = true
        AppData.clearData()
        AppData.isLoggedIn = false
        DispatchQueue.main.async {
            guard let tbc = self.tabBarController as? TabBarController else {
                return
            }
            tbc.isLoaded = false
            tbc.present(loginViewController, animated: true, completion: {
                tbc.selectedViewController?.view.isHidden = true
                tbc.viewControllers = nil
            })
        }
    }
    func callSignOutSequence() {
        FirebaseAuthService.shared.signOut { (error) in
            guard error == nil else {
                UIAlertController.showTelaAlert(title: "Signout Failed", message: error?.localizedDescription ?? "Try again", controller: self)
                return
            }
            self.signOut()
        }
    }
    fileprivate func setupViews() {
        view.addSubview(tableView)
    }
    fileprivate func setupConstraints() {
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    var options:[String] = {
        let role = AppData.getUserRole()
        switch role {
            case .Developer: return ["Profile Settings", "Companies", "Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "Application Information", "Log Out"]
            case .Owner: return ["Profile Settings", "Companies", "Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "Application Information", "Log Out"]
            case .Operator: return ["Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Archived SMSes", "Clear Cache"]
            case .Agent: return ["Profile Settings", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Clear Cache"]
        }
//        if role != .Agent {
//            return ["Manage Agents", "Gallery", "Blocked Users", "Schedule Message", "Archived SMSes", "Clear Cache"]
//        } else {
//            return ["Profile Settings", "Blocked Users", "Schedule Message", "Clear Cache"]
//        }
    }()
    

//    options = ["Manage Agents", "Gallery", "Blocked Users", "Archived SMSes"]
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    
    fileprivate func handleClearCache() {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        let alertVC = UIAlertController.telaAlertController(title: "Confirm clear cache?", message: "This will clear all cached images from the app")
        alertVC.addAction(UIAlertAction(title: "Clear", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
            self.clearCache()
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    fileprivate func clearCache() {
        imageCache.removeAllObjects()
    }
    
}
extension MoreViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = UIColor.telaWhite
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
        cell.accessoryType = .disclosureIndicator
        let option = options[indexPath.row]
        cell.textLabel?.text = option
        if option == "Log Out" {
            cell.textLabel?.textColor = UIColor.telaRed
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let role = AppData.getUserRole()
        
        switch role {
            case .Developer, .Owner:
                switch indexPath.row {
                    case 0:
                        let vc = SettingsViewController()
                        self.show(vc, sender: self)
                    case 1:
                        let vc = SelectCompanyViewController()
                        self.present(vc, animated: true, completion: nil)
                    case 2:
                        let vc = ManageAgentsViewController()
                        self.show(vc, sender: self)
                    case 3:
                        let vc = GalleryViewController()
                        self.show(vc, sender: self)
                    case 4:
                        let vc = BlacklistViewController()
                        self.show(vc, sender: self)
                    case 5:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 6:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 7:
                        let vc = AppInfoViewController()
                        self.show(vc, sender: self)
                    default: alertLogout()
            }
            case .Operator:
                switch indexPath.row {
                        case 0:
                            let vc = ManageAgentsViewController()
                            self.show(vc, sender: self)
                        case 1:
                            let vc = GalleryViewController()
                            self.show(vc, sender: self)
                        case 2:
                            let vc = BlockedUsersViewController()
                            self.show(vc, sender: self)
                        case 3:
                            let vc = ScheduleMessageViewController()
                            self.show(vc, sender: self)
                        case 4:
                            let vc = ArchivedSMSViewController()
                            self.show(vc, sender: self)
                        default: handleClearCache()
                }
            case .Agent:
                switch indexPath.row {
                        case 0:
                            let vc = SettingsViewController()
                            self.show(vc, sender: self)
                        case 1:
                            let vc = GalleryViewController()
                            self.show(vc, sender: self)
                        case 2:
                            let vc = BlockedUsersViewController()
                            self.show(vc, sender: self)
                        case 3:
                            let vc = ScheduleMessageViewController()
                            self.show(vc, sender: self)
                        default: handleClearCache()
                }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        /*
        
        if role == .Agent {
            switch indexPath.row {
                case 0:
                    let profileSettingsVC = SettingsViewController()
                    self.show(profileSettingsVC, sender: self)
                case 1:
                    let blockedUsersVC = BlockedUsersViewController()
                    self.show(blockedUsersVC, sender: self)
                case 2:
                    let scheduleMessageVC = ScheduleMessageViewController()
                    self.show(scheduleMessageVC, sender: self)
                case 3:
                    let galleryVC = GalleryViewController()
                    self.show(galleryVC, sender: self)
                case 4: handleClearCache()
            default: break
            }
        } else {
            switch indexPath.row {
                case 0:
                    let manageAgentsVC = ManageAgentsViewController()
                    self.show(manageAgentsVC, sender: self)
                case 1:
                    let galleryVC = GalleryViewController()
                    self.show(galleryVC, sender: self)
                case 2:
                    let blockedUsersVC = BlockedUsersViewController()
                    self.show(blockedUsersVC, sender: self)
                case 3:
                    let scheduleMessageVC = ScheduleMessageViewController()
                    self.show(scheduleMessageVC, sender: self)
                case 4:
                    let archivedSMSVC = ArchivedSMSViewController()
                    self.show(archivedSMSVC, sender: self)
                case 5: handleClearCache()
                default: break
            }
        }
        
        */
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}
