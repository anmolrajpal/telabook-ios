//
//  ManageAgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ManageAgentsViewController: UIViewController {
    internal var filteredSearch = [InternalConversationsCodable]()
    internal var searchController = UISearchController(searchResultsController: nil)
    internal var isSearching = false
    internal var agents:[InternalConversationsCodable]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let agents = agents {
                if agents.isEmpty {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Agents"
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
        initiateFetchAgentsSequence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "MANAGE AGENTS"
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
    }
    fileprivate func setupConstraints() {
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive = true
    }
    
    /*
    let agents:[Agent] = [
        Agent(profileImage: #imageLiteral(resourceName: "smiley_icon"), name: "Anmol Rajpal", details: "Dev Service | Mon-Fri | 10 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "landing_operators"), name: "Allan Martinez", details: "Mall Service | Mon-Fri | 5 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "tab_home_active"), name: "Nicole Cooper", details: "Wedding Service | Mon-Fri | 20 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "block_rounded"), name: "Jon Snow", details: "Night Service | Mon-Fri | 2 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "unblock_rounded"), name: "Khaleesi", details: "Sports Service | Mon-Fri | 9 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "landing_callgroup"), name: "Tyrion Lanister", details: "Dev Service | Mon-Fri | 7 Threads")
    ]
    */
    fileprivate func setupTableView() {
        tableView.register(ManageAgentsCell.self, forCellReuseIdentifier: NSStringFromClass(ManageAgentsCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
    fileprivate func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search Agents"
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
}
struct Agent {
    let profileImage:UIImage?
    let name:String?
    let details:String?
}

