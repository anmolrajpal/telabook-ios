//
//  CallViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class CallsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "CALLS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
