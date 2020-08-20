//
//  AutoResponseViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class AutoResponseViewController: UIViewController {
    
    // MARK: - Constructors
    lazy private(set) var subview: AutoResponseView = {
        return AutoResponseView(frame: UIScreen.main.bounds)
    }()
    
    
    // MARK: - Init / Deinit
    
    let agent: Agent
    init(agent: Agent) {
        self.agent = agent
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\(self) : Deinitialized")
    }
    
    
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
}
