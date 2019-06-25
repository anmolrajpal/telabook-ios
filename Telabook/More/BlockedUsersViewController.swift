//
//  BlockedUsersViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
struct Blacklist {
    let id:Int?
    let number:String?
    let externalConversationId:Int?
    let description:String?
}
class BlockedUsersViewController: UIViewController {
    internal var filteredSearch = [BlacklistCodable]()
    internal var searchController = UISearchController(searchResultsController: nil)
    internal var isSearching = false
    internal var blacklist:[BlacklistCodable]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let list = blacklist {
                if list.isEmpty {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Blocked Users"
                    self.tableView.isHidden = true
                }
            }
        }
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupTableView()
        setupSearchBar()
        initiateFetchBlacklistSequence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "BLOCKED USERS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        view.addSubview(refreshButton)
    }
    fileprivate func setupConstraints() {
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive = true
        refreshButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        refreshButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    fileprivate func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search Blacklist"
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //Setup cancel button in search bar
        let attributes:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.telaRed,
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
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
    
    
    
    @objc func handleRefreshAction() {
        self.setPlaceholdersViewsState(isHidden: true)
        self.setViewsState(isHidden: true)
//        self.startSpinner()
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.refreshButton.isHidden = isHidden
    }
    fileprivate func setViewsState(isHidden: Bool) {
        self.tableView.isHidden = isHidden
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
    let refreshButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        button.addTarget(self, action: #selector(handleRefreshAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
}

