//
//  TabBarController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    static let shared = TabBarController()
    
    enum Tabs: Int, Codable {
        case tab1, tab2, tab3, tab4
        
        private var tabName:String {
            switch self {
                case .tab1: return "HOME"
                case .tab2: return "CALLS"
                case .tab3: return "SMS"
//                case .tab4: return "SETTINGS"
                case .tab4: return "MORE"
            }
        }
        private var tabImage:UIImage {
            switch self {
                case .tab1: return #imageLiteral(resourceName: "tab_home_inactive")
                case .tab2: return #imageLiteral(resourceName: "tab_call_inactive")
                case .tab3: return #imageLiteral(resourceName: "tab_sms_inactive")
//                case .tab4: return #imageLiteral(resourceName: "tab_settings_inactive")
                case .tab4: return #imageLiteral(resourceName: "tab_more_inactive")
            }
        }
        private var tabSelelctedImage:UIImage {
            switch self {
                case .tab1: return #imageLiteral(resourceName: "tab_home_active")
                case .tab2: return #imageLiteral(resourceName: "tab_call_active")
                case .tab3: return #imageLiteral(resourceName: "tab_sms_active")
//                case .tab4: return #imageLiteral(resourceName: "tab_settings_active")
                case .tab4: return #imageLiteral(resourceName: "tab_more_active")
            }
        }
        var tabBarItem:UITabBarItem {
            UITabBarItem(title: tabName, image: tabImage, selectedImage: tabSelelctedImage)
        }
    }
    
    var isLoaded:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authenticate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func setup() {
        self.delegate = self
        self.view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
//        setUpTabBarViewControllers()
//        authenticate()
    }
    
    func showLoginController() {
        let loginViewController = LoginViewController()
        loginViewController.isModalInPresentation = true
        loginViewController.delegate = self
        AppData.clearData()
        AppData.isLoggedIn = false
        
        tabBarController?.present(loginViewController, animated: true, completion: nil)
        //        present(loginController, animated: false, completion: {
        //            UserDefaults.standard.setIsLoggedIn(value: false)
        //            UserDefaults.clearUserData()
        //        })
    }
    private func handleSignOut() {
        self.showLoginController()
    }
    func authenticate() {
        if AppData.isLoggedIn {
            setUpTabBarViewControllers()
        } else {
            print("Presented View Controller:")
            print(self.presentedViewController as Any)
            guard let _ = self.presentedViewController as? LoginViewController else {
                print("Presenting Login View Controller")
                let loginViewController = LoginViewController()                
                loginViewController.delegate = self
                loginViewController.isModalInPresentation = true
                AppData.clearData()
                AppData.isLoggedIn = false
                
                DispatchQueue.main.async {
                    self.present(loginViewController, animated: false, completion: nil)
                }
                return
            }
        }
    }
    private func setUpTabBarViewControllers() {
        /*
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.spinner.stopAnimating()
        }
        */
        
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let callsViewController = UINavigationController(rootViewController: SMSViewController())
        let agentsViewController = UINavigationController(rootViewController: AgentsViewController(fetchRequest: Agent.fetchRequest(), viewContext: PersistentContainer.shared.viewContext))
//        let smsViewController = UINavigationController(rootViewController: SMSViewController())
//        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        let moreViewController = UINavigationController(rootViewController: MoreViewController())
        homeViewController.tabBarItem = Tabs.tab1.tabBarItem
        callsViewController.tabBarItem = Tabs.tab2.tabBarItem
//        smsViewController.tabBarItem = Tabs.tab3.tabBarItem
        agentsViewController.tabBarItem = Tabs.tab3.tabBarItem
//        settingsViewController.tabBarItem = Tabs.tab4.tabBarItem
        moreViewController.tabBarItem = Tabs.tab4.tabBarItem
        let role = CustomUtils.shared.getUserRole()
        var viewControllersList:[UIViewController]
        if role == .Agent {
            viewControllersList = [homeViewController, callsViewController, agentsViewController, moreViewController]
        } else {
            viewControllersList = [homeViewController, callsViewController, agentsViewController, moreViewController]
        }
        self.setupTabBarUI()
        self.viewControllers = viewControllersList
        self.selectedIndex = AppData.selectedTab.rawValue
        self.isLoaded = true
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.28) {
            self.setupTabBarUI()
            self.viewControllers = viewControllersList
            self.selectedIndex = AppData.selectedTab.rawValue
            self.isLoaded = true
        }
        */
    }
    fileprivate func setupTabBarUI() {
        tabBar.barTintColor = UIColor.telaGray4
        tabBar.tintColor = UIColor.telaBlue
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
        NSAttributedString.Key.foregroundColor: UIColor.telaBlue], for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment.vertical = -5
    }
    
    
    
    let spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.white
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
}
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        AppData.selectedTab = Tabs(rawValue: self.selectedIndex)!
    }
}


extension TabBarController: LoginDelegate {
    func didLoginIWithSuccess() {
        print("Login with success")
        self.setUpTabBarViewControllers()
    }
}
