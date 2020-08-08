//
//  NormalDialerViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

protocol NormalDialerDelegate: class {
    func normalDialer(didEnteredNumberToDial number: String, controller: NormalDialerViewController)
}

class NormalDialerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: NormalDialerDelegate?
    
    // MARK: - View Constructors
    
    lazy private(set) var subview: NormalDialerView = {
        return NormalDialerView(frame: UIScreen.main.bounds)
    }()
    
    
    // MARK: - Lifecycle
    
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
