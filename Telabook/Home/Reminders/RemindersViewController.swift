//
//  RemindersViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class RemindersViewController: UIViewController {
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupNavBarItems()
        
        self.navigationItem.title = "REMINDERS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupNavBarItems() {
        
//    navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)!, NSAttributedString.Key.foregroundColor: UIColor.telaBlue], for: .normal)
    }
    fileprivate func setupViews() {
        
    }
    fileprivate func setupConstraints() {
        
    }
}
