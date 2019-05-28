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
//        setViewsState()
//        self.spinner.startAnimating()
        //        viewControllers = []
        if isLoggedIn() {
            let emailId = UserDefaults.standard.getEmailId()
            guard let password = UserDefaults.standard.getPassword() else {
//                self.spinner.stopAnimating()
                let alertVC = UIAlertController(title: "Authentication Error", message: "Please sign in again.", preferredStyle: UIAlertController.Style.alert)
                DispatchQueue.main.async {
                    alertVC.addAction(UIAlertAction(title: "Sign in", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                        self.handleSignOut()
                    })
                    self.present(alertVC, animated: true, completion: nil)
                }
                return
            }
            print("Email => \(emailId)\nPassword => \(password)")
            setUpTabBarViewControllers()
//            UserAuthenticationService.shared.fetch(rollNo, password) { (data, error) in
//
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
//
//
//                    guard error == nil else {
//                        self.spinner.stopAnimating()
//                        let alertVC = UIAlertController(title: "Connection Error", message: "Request timed out. Please try again.", preferredStyle: UIAlertController.Style.alert)
//                        alertVC.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
//                            let loginController = LoginController()
//                            UserDefaults.standard.setIsLoggedIn(value: false)
//                            UserDefaults.clearUserData()
//                            DispatchQueue.main.async {
//                                self.present(loginController, animated: true, completion: nil)
//                            }
//                        })
//                        alertVC.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
//                            self.retry()
//                        })
//                        self.present(alertVC, animated: true, completion: nil)
//                        return
//                    }
//
//                    let result = data?.result
//                    _ = data?.message
//                    switch result {
//                    case ResultType.Failure.rawValue:
//                        self.spinner.stopAnimating()
//                        let alertVC = UIAlertController(title: "Authentication Error", message: "Please sign in again.", preferredStyle: UIAlertController.Style.alert)
//                        alertVC.addAction(UIAlertAction(title: "Sign in", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
//                            let loginController = LoginController()
//                            UserDefaults.standard.setIsLoggedIn(value: false)
//                            UserDefaults.clearUserData()
//                            DispatchQueue.main.async {
//                                self.present(loginController, animated: true, completion: nil)
//                            }
//                        })
//                        self.present(alertVC, animated: true, completion: nil)
//
//                    case ResultType.Success.rawValue:
//                        self.spinner.stopAnimating()
//                        self.setUpTabBarViewControllers()
//                    default:
//                        break
//                    }
//                })
//            }
        } else {
//            self.spinner.stopAnimating()
            let loginViewController = LoginViewController()
            UserDefaults.standard.setIsLoggedIn(value: false)
            UserDefaults.clearUserData()
            DispatchQueue.main.async {
                self.present(loginViewController, animated: false, completion: nil)
            }
            //            DispatchQueue.main.async {
            //                print("hahahha")
            //                self.showLoginController()
            //            }
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
        let viewControllersList = [homeViewController, callsViewController, smsViewController, settingsViewController, moreViewController]
        
        tabBar.barTintColor = UIColor.telaGray4
        tabBar.tintColor = UIColor.telaBlue
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!,
        NSAttributedString.Key.foregroundColor: UIColor.telaBlue], for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment.vertical = -5
//        tabBar.backgroundColor = UIColor.red
//        tabBar.itemSpacing = 15
//        tabBar.itemPositioning = 1
        viewControllers = viewControllersList
        isLoaded = true
    }
}
