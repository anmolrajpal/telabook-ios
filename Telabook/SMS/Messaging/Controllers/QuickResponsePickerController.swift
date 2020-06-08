//
//  QuickResponsePickerController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 31/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

protocol QuickResponsePickerDelegate {
    func manageButtonDidTap()
    func quickResponseDidPick(at indexPath:IndexPath, response:QuickResponse)
}
class QuickResponsePickerController:UIViewController {
    // MARK: - Constructors
    lazy private(set) var subview: QuickResponsePickerView = {
        return QuickResponsePickerView(frame: UIScreen.main.bounds)
    }()
    var delegate:QuickResponsePickerDelegate?
    
    let quickResponses:[QuickResponse]
    
    
    // MARK: - init
    required init(responses:[QuickResponse]) {
        self.quickResponses = responses
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view.addSubview(subview)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        subview.frame = view.bounds
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        title = "Select Quick Response"
    }
}
