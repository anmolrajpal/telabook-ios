//
//  BlockedUsersViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class BlockedUsersViewController: UIViewController {

    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "BLOCKED USERS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        
    }
    fileprivate func setupConstraints() {
        
    }
}
