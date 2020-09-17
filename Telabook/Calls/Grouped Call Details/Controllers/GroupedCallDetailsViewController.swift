//
//  GroupedCallDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit


class GroupedCallDetailsViewController: UITableViewController {
    
    
    var agentCalls = [ItemType]()
    var dataSource: DataSource! = nil
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
}
