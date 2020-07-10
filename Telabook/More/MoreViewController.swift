//
//  MoreViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    
    var delegate:LogoutDelegate?
    var options:[String] = {
        let role = AppData.getUserRole()
        switch role {
            case .Developer: return ["Profile Settings", "Companies", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Application Information", "Log Out"]
            case .Owner: return ["Profile Settings", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Application Information", "Log Out"]
            case .Operator: return ["Profile Settings", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Application Information", "Log Out"]
            case .Agent: return ["Profile Settings", "Blacklisted Numbers", "Scheduled Messages", "Disabled Accounts", "App Settings", "Application Information", "Log Out"]
        }
    }()
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    
    
    
    // MARK: - Methods
    
    private func commonInit() {
        title = "MORE"
        view.backgroundColor = .telaGray1
        setUpNavBar()
        configureTableView()
    }
    private func configureTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UITableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
  
    
    
    
    
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                        let vc = BlacklistViewController()
                        self.show(vc, sender: self)
                    case 3:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 4:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 5:
                        let vc = AppSettingsViewController()
                        self.show(vc, sender: self)
                    case 6:
                        let vc = AppInfoViewController()
                        self.show(vc, sender: self)
                    case 7:
                        alertLogout()
                    default: fatalError()
                    
            }
            case .Owner, .Operator, .Agent:
                switch indexPath.row {
                    case 0:
                        let vc = SettingsViewController()
                        self.show(vc, sender: self)
                    case 1:
                        let vc = BlacklistViewController()
                        self.show(vc, sender: self)
                    case 2:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 3:
                        let vc = ScheduleMessageViewController()
                        self.show(vc, sender: self)
                    case 4:
                        let vc = AppSettingsViewController()
                        self.show(vc, sender: self)
                    case 5:
                        let vc = AppInfoViewController()
                        self.show(vc, sender: self)
                    case 6:
                        alertLogout()
                    default: fatalError()
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
