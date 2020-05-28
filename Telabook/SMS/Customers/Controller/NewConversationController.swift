//
//  NewConversationController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit


protocol StartNewConversationDelegate {
    func conversation(didStartNewConversationWithID id: Int, node:String)
}

class NewConversationController: UIViewController {
    var delegate:StartNewConversationDelegate?
    
    /// The workerID of the Agent
    let senderID:Int
    
    lazy private(set) var subview: NewConversationView = {
        return NewConversationView(frame: UIScreen.main.bounds)
    }()
    
    
    
    init(senderID:Int) {
        self.senderID = senderID
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Lifecycle
    
    override func loadView() {
        super.loadView()
        view.addSubview(subview)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        subview.frame = view.bounds
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subview.numberTextField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
    }
}
