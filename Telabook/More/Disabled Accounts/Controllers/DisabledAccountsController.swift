//
//  DisabledAccountsController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class DisabledAccountsController: UITableViewController {
    var viewDidAppear = false
    var disabledAccounts = [DisabledAccountProperties]()
    var dataSource: DataSource! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }
    
    
    
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.white
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var tableViewRefreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.telaGray7
        return refreshControl
    }()

}
