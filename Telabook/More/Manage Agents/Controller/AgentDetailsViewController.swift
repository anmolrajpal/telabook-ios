//
//  AgentDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class AgentDetailsViewController: UIViewController {
    lazy private(set) var subview: AgentDetailsView = {
      return AgentDetailsView(frame: UIScreen.main.bounds)
    }()
    let agent:Agent
    init(agent:Agent) {
        self.agent = agent
        super.init(nibName: nil, bundle: nil)
        self.setupAgentDetails(details: agent)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Agent Details"
    }
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarAppearance()
        setupTargetActions()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
