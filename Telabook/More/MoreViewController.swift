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
        let role = CustomUtils.shared.getUserRole()
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
        let alertVC = UIAlertController.telaAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?")
        alertVC.addAction(UIAlertAction(title: "Log Out", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
            self.callSignOutSequence()
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    private func signOut() {
        let loginViewController = LoginViewController()
        UserDefaults.standard.setIsLoggedIn(value: false)
        UserDefaults.clearUserData()
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
                UIAlertController.showAlert(alertTitle: "Signout Failed", message: error?.localizedDescription ?? "Try again", alertActionTitle: "Ok", controller: self)
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
        let role = CustomUtils.shared.getUserRole()
        if role != .Agent {
            return ["Manage Agents", "Gallery", "Blocked Users", "Archived SMSes"]
        } else {
            return ["Profile Settings", "Blacklisted Numbers", "Clear Cache"]
        }
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
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let role = CustomUtils.shared.getUserRole()
        if role == .Agent {
            switch indexPath.row {
                case 0:
                    let profileSettingsVC = SettingsViewController()
                    self.show(profileSettingsVC, sender: self)
                case 1:
                    let blockedUsersVC = BlockedUsersViewController()
                    self.show(blockedUsersVC, sender: self)
                case 2:
                    let galleryVC = GalleryViewController()
                    self.show(galleryVC, sender: self)
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
                    let archivedSMSVC = ArchivedSMSViewController()
                    self.show(archivedSMSVC, sender: self)
                default: break
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
