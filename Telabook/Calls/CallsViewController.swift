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
        let label = UILabel()
        label.text = "Launching soon"
        label.textColor = .white
        label.textAlignment = .center
        view.addSubview(label)
        label.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "CALLS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
