//
//  SettingsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import Firebase
import CoreData
class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpNavBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "SETTINGS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setUpNavBarItems() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleRightBarButtonItem))
        let normalStateAttributes = [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)!,
                                     NSAttributedString.Key.foregroundColor: UIColor.telaRed]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(normalStateAttributes, for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(normalStateAttributes, for: .highlighted)
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
    fileprivate func dumpCoreDataStorage() {
        do {
            
            let context = PersistenceService.shared.persistentContainer.viewContext
            let entityNames = [String(describing: ExternalConversation.self), String(describing: InternalConversation.self), String(describing: Permission.self), String(describing: User.self)]
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                do {
                    let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                    _ = objects.map{$0.map{context.delete($0)}}
                    PersistenceService.shared.saveContext()
                } catch let error {
                    print("ERROR DELETING : \(error)")
                }
            }
        }
    }
    func callSignOutSequence() {
        FirebaseAuthService.shared.signOut { (error) in
            guard error == nil else {
                UIAlertController.showTelaAlert(title: "Signout Failed", message: error?.localizedDescription ?? "Try again", controller: self)
                return
            }
            self.dumpCoreDataStorage()
            self.signOut()
        }
    }
}
