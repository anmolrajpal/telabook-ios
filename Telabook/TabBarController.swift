//
//  TabBarController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    
    enum Tabs: Int, Codable {
        case tab1, tab2, tab3
        
        private var tabName:String {
            switch self {
                case .tab1: return "SMS"
                case .tab2: return "CALLS"
                case .tab3: return "MORE"
            }
        }
        private var tabImage:UIImage {
            switch self {
                case .tab1: return #imageLiteral(resourceName: "tab_sms_inactive")
                case .tab2: return #imageLiteral(resourceName: "tab_call_inactive")
                case .tab3: return #imageLiteral(resourceName: "tab_more_inactive")
            }
        }
        private var tabSelelctedImage:UIImage {
            switch self {
                case .tab1: return #imageLiteral(resourceName: "tab_sms_active")
                case .tab2: return #imageLiteral(resourceName: "tab_call_active")
                case .tab3: return #imageLiteral(resourceName: "tab_more_active")
            }
        }
        var tabBarItem:UITabBarItem {
            UITabBarItem(title: tabName, image: tabImage, selectedImage: tabSelelctedImage)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func didReceiveMemoryWarning() {
        print("Did Receive memory warning on \(self)")
    }
    private func commonInit() {
        delegate = self
        authenticate()
    }
    
    fileprivate func authenticate(animated:Bool = false) {
        guard !AppData.isLoggedIn else { configureTabBarController(); return }
        selectedViewController?.view.isHidden = true
        viewControllers = nil
        guard !(presentedViewController is LoginViewController) else { return }
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        loginViewController.isModalInPresentation = true
        AppData.clearData()
        AppData.isLoggedIn = false
        DispatchQueue.main.async {
            self.present(loginViewController, animated: animated, completion: nil)
        }
    }
    
    private func configureTabBarController() {
        var controllers = [UINavigationController]()
        
        // MARK: - Tab 1
        let agentsNavController = UINavigationController(rootViewController: AgentsViewController())
        agentsNavController.tabBarItem = Tabs.tab1.tabBarItem
        controllers.append(agentsNavController)
        
        // MARK: - Tab 2
        let callsNavController = UINavigationController(rootViewController: CallsTabAgentsViewController())
        callsNavController.tabBarItem = Tabs.tab2.tabBarItem
        controllers.append(callsNavController)
        
        // MARK: - Tab 3
        let moreViewController = MoreViewController()
        moreViewController.delegate = self
        let moreNavController = UINavigationController(rootViewController: moreViewController)
        moreNavController.tabBarItem = Tabs.tab3.tabBarItem
        controllers.append(moreNavController)
        
        configureTabBarUI()
        viewControllers = controllers
        selectedIndex = AppData.selectedTab.rawValue
    }
    
    private func configureTabBarUI() {
//        tabBar.barTintColor = UIColor.telaGray4
        tabBar.tintColor = UIColor.telaBlue
        let normalAttributes:[NSAttributedString.Key: Any] = [
            .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
            .foregroundColor: UIColor.telaGray7
        ]
        let selectedAttributes:[NSAttributedString.Key: Any] = [
            .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
            .foregroundColor: UIColor.telaBlue
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment.vertical = -5
    }
    
    fileprivate func configureNotifications() {
        if AppData.isLoggedIn && AppData.workerId != 0 {
            requestNotifications {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    let topic = "operator_ios_\(AppData.workerId)"
                    Messaging.messaging().subscribe(toTopic: topic) { error in
                        if let error = error {
                            printAndLog(message: "### \(#function) Error subscribing to topic: \(topic) | Error: \n\(error)", log: .notifications, logType: .error)
                        } else {
                            printAndLog(message: "Successfully subscribed to topic: \(topic)", log: .notifications, logType: .info)
                        }
                    }
                }
            }
        }
    }
}
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        AppData.selectedTab = Tabs(rawValue: selectedIndex)!
    }
}


extension TabBarController: LoginDelegate {
    func didLoginIWithSuccess() {
        configureTabBarController()
        configureNotifications()
        
    }
}
extension TabBarController: LogoutDelegate {
    func presentLogin() {
        AppData.isLoggedIn = false
        authenticate(animated: true)
    }
}
protocol LogoutDelegate: class {
    func presentLogin()
}
