//
//  LoginViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import MessageKit

protocol LoginDelegate {
    func didLoginIWithSuccess()
}
class LoginViewController: UIViewController {
    var delegate:LoginDelegate?
    var token:String?
    var userInfo:UserInfoCodable?
    var isEmailValid = false
    var isPasswordValid = false
    
    
    
    // MARK: - Constructors
    lazy private(set) var subview: LoginView = {
        return LoginView(frame: UIScreen.main.bounds)
    }()
    
    
    
    // MARK: - Lifecycle
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
}
