//
//  MoreViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    var delegate:LogoutDelegate?
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
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        let alertVC = UIAlertController.telaAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setTitleColor(color: .telaBlue)
        let logoutAction = UIAlertAction(title: "Log Out", style: .default) { _ in self.callSignOutSequence() }
        logoutAction.setTitleColor(color: .systemRed)
        
        alertVC.addAction(logoutAction)
        alertVC.addAction(cancelAction)
        alertVC.preferredAction = logoutAction
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
//            self.signOut()
            if AppData.isRememberMeChecked {
                DispatchQueue.main.async {
                    self.delegate?.presentLogin()
                }
            } else {
                self.dumpCoreData()
            }
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
            case .Developer: return ["Profile Settings", "Companies", "Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Clear Cache", "Application Information", "Log Out"]
            case .Owner: return ["Profile Settings", "Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Clear Cache", "Application Information", "Log Out"]
            case .Operator: return ["Profile Settings", "Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Clear Cache", "Application Information", "Log Out"]
            case .Agent: return ["Profile Settings", "Manage Agents", "Gallery", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Clear Cache", "Application Information", "Log Out"]
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
    
    fileprivate func alertClearCache() {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        let alert = UIAlertController.telaAlertController(title: "Clear Cache", message: "This will clear all cached images and data from the app")
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
    internal func clearCacheDirectory() {
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
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
            case .Developer:
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
                        let vc = AppSettingsViewController()
                        self.show(vc, sender: self)
                    case 8:
                        alertClearCache()
                    case 9:
                        let vc = AppInfoViewController()
                        self.show(vc, sender: self)
                    case 10:
                        alertLogout()
                    default: fatalError()
                    
            }
            case .Owner, .Operator, .Agent:
                switch indexPath.row {
                    case 0:
                        let vc = SettingsViewController()
                        self.show(vc, sender: self)
                    case 1:
                        let vc = ManageAgentsViewController()
                        self.show(vc, sender: self)
                    case 2:
                        let vc = GalleryViewController()
                        self.show(vc, sender: self)
                    case 3:
                        let vc = BlacklistViewController()
                        self.show(vc, sender: self)
                    case 4:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 5:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 6:
                        let vc = AppSettingsViewController()
                        self.show(vc, sender: self)
                    case 7:
                        alertClearCache()
                    case 8:
                        let vc = AppInfoViewController()
                        self.show(vc, sender: self)
                    case 9:
                        alertLogout()
                    default: fatalError()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}






extension UIAlertAction {
    func setTitleColor(color:UIColor) {
        self.setValue(color, forKey: "titleTextColor")
    }
}


extension UIAlertController {
    
    //Set background color of UIAlertController
    func configureBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func configureTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func configureMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    //Set tint color of UIAlertController
    func configureTint(color: UIColor) {
        self.view.tintColor = color
    }
}
