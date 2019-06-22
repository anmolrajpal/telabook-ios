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
    internal var filteredSearch = [Blacklist]()
    internal var searchController = UISearchController(searchResultsController: nil)
    internal var isSearching = false
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
    }
    fileprivate func setupConstraints() {
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    
    var blackList:[Blacklist] = [
        Blacklist(id: 1, number: "+19897002188", externalConversationId: 101, description: "iOS Dev"),
        Blacklist(id: 2, number: "+19876543210", externalConversationId: 102, description: "Android Dev"),
        Blacklist(id: 3, number: "+11234567890", externalConversationId: 103, description: "Web Dev"),
        Blacklist(id: 4, number: "+16789054321", externalConversationId: 104, description: "CEO"),
        Blacklist(id: 5, number: "+11234509876", externalConversationId: 105, description: "Director")
    ]
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
}

