//
//  OnlineUsersViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import FirebaseStorage
class OnlineUsersViewController: UIViewController {
    internal var onlineUsers:[OnlineUser]? = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            guard let users = onlineUsers,
                !users.isEmpty else {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Online Users"
                    self.tableView.isHidden = true
                    return
            }
            self.placeholderLabel.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "OPERATORS ONLINE"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupTableView()
        fetchOnlineUsers()
        OnlineUsersAPI.shared.observeOnlineUsers()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
    }
    fileprivate func setupConstraints() {
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 100, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
    }
    let placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Turn on Mobile Data or Wifi to Access Telabook"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    fileprivate func setupTableView() {
        tableView.register(OnlineUserCell.self, forCellReuseIdentifier: NSStringFromClass(OnlineUserCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func fetchOnlineUsers() {
        OnlineUsersAPI.shared.fetchOnlineUsers { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                
            } else if let users = data {
                self.onlineUsers = users
            }
        }
    }
    
    
    
    
    
}
