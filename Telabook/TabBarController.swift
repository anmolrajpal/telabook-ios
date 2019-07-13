//
//  TabBarController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
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
//        setUpTabBarViewControllers()
//        authenticate()
    }
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.isLoggedIn()
    }
    func showLoginController() {
        let loginViewController = LoginViewController()
        UserDefaults.standard.setIsLoggedIn(value: false)
        UserDefaults.clearUserData()
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
        if isLoggedIn() {
            let emailId = UserDefaults.standard.getEmailId()
            let password = UserDefaults.standard.getPassword()
            print("Email => \(emailId)\nPassword => \(password)")
            setUpTabBarViewControllers()
        } else {
//            self.spinner.stopAnimating()
            print("Presented View Controller:")
            print(self.presentedViewController as Any)
            guard let _ = self.presentedViewController as? LoginViewController else {
                print("Presenting Login View Controller")
                let loginViewController = LoginViewController()
                UserDefaults.standard.setIsLoggedIn(value: false)
                UserDefaults.clearUserData()
                DispatchQueue.main.async {
                    self.present(loginViewController, animated: false, completion: nil)
                }
                return
            }
        }
    }
    private func setUpTabBarViewControllers() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let callsViewController = UINavigationController(rootViewController: CallsViewController())
        let smsViewController = UINavigationController(rootViewController: SMSViewController())
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        let moreViewController = UINavigationController(rootViewController: MoreViewController())
        homeViewController.tabBarItem = UITabBarItem(title: "HOME", image: #imageLiteral(resourceName: "tab_home_inactive"), selectedImage: #imageLiteral(resourceName: "tab_home_active"))
        callsViewController.tabBarItem = UITabBarItem(title: "CALLS", image: #imageLiteral(resourceName: "tab_call_inactive"), selectedImage: #imageLiteral(resourceName: "tab_call_active"))
        smsViewController.tabBarItem = UITabBarItem(title: "SMS", image: #imageLiteral(resourceName: "tab_sms_inactive"), selectedImage: #imageLiteral(resourceName: "tab_sms_active"))
        settingsViewController.tabBarItem = UITabBarItem(title: "SETTINGS", image: #imageLiteral(resourceName: "tab_settings_inactive"), selectedImage: #imageLiteral(resourceName: "tab_settings_active"))
        moreViewController.tabBarItem = UITabBarItem(title: "MORE", image: #imageLiteral(resourceName: "tab_more_inactive"), selectedImage: #imageLiteral(resourceName: "tab_more_active"))
        let role = CustomUtils.shared.getUserRole()
        var viewControllersList:[UIViewController]
        if role == .Agent {
            viewControllersList = [homeViewController, callsViewController, smsViewController,  moreViewController]
        } else {
            viewControllersList = [homeViewController, callsViewController, smsViewController, settingsViewController, moreViewController]
        }
        setupTabBarUI()
        viewControllers = viewControllersList
        isLoaded = true
    }
    fileprivate func setupTabBarUI() {
        tabBar.barTintColor = UIColor.telaGray4
        tabBar.tintColor = UIColor.telaBlue
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
        NSAttributedString.Key.foregroundColor: UIColor.telaBlue], for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment.vertical = -5
    }
}
