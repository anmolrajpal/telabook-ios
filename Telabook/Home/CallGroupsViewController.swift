//
//  CallGroupsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class CallGroupsViewController: UIViewController {
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        self.navigationItem.title = "CALL GROUPS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        
    }
    fileprivate func setupConstraints() {
        
    }
}
