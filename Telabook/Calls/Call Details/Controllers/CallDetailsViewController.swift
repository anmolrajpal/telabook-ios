//
//  CallDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class CallDetailsViewController: UITableViewController {
    
    
    // MARK: - Initialization
    
    let callDetails:AgentCallProperties
    
    init(agentCall: AgentCallProperties) {
        self.callDetails = agentCall
        super.init(style: .grouped)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let header = tableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size.height = newSize.height
        }
    }

    
}
