//
//  AppInfoViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {
    lazy private(set) var subview: AppInfoView = {
      return AppInfoView(frame: UIScreen.main.bounds)
    }()
    
    
    // MARK: init
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        title = "APP INFORMATION"
        let version = Bundle.versionNumber ?? ""
        let build = Bundle.buildNumber ?? ""
        subview.appVersionLabel.text = "Version \(version) (\(build))"
    }
}
