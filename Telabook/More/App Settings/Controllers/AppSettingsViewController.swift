//
//  AppSettingsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class AppSettingsViewController:UIViewController {
 
    // MARK: - Properties
    var dataSource: DataSource! = nil
    var selectedIndexPath:IndexPath?
    
    
    
    // MARK: - Constructors
    lazy private(set) var subview: AppSettingsView = {
        return AppSettingsView(frame: UIScreen.main.bounds)
    }()
    
    
    
    
    //MARK: - Lifecycle
    
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clearsTableViewSelectionOnViewDidAppear(animated)
    }
    deinit {
        removeForegroundNotificationsObservers()
    }
}
