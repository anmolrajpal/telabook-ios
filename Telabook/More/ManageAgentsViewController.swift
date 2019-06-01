//
//  ManageAgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ManageAgentsViewController: UIViewController {
    fileprivate var filteredSearch = [Agent]()
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    fileprivate var isSearching = false
    
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
        self.navigationItem.title = "MANAGE AGENTS"
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
    
    
    let agents:[Agent] = [
        Agent(profileImage: #imageLiteral(resourceName: "smiley_icon"), name: "Anmol Rajpal", details: "Dev Service | Mon-Fri | 10 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "landing_operators"), name: "Allan Martinez", details: "Mall Service | Mon-Fri | 5 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "tab_home_active"), name: "Nicole Cooper", details: "Wedding Service | Mon-Fri | 20 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "block_rounded"), name: "Jon Snow", details: "Night Service | Mon-Fri | 2 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "unblock_rounded"), name: "Khaleesi", details: "Sports Service | Mon-Fri | 9 Threads"),
        Agent(profileImage: #imageLiteral(resourceName: "landing_callgroup"), name: "Tyrion Lanister", details: "Dev Service | Mon-Fri | 7 Threads")
    ]
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
}
struct Agent {
    let profileImage:UIImage?
    let name:String?
    let details:String?
}
extension ManageAgentsViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredSearch.count
        } else {
            return self.agents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ManageAgentsCell.self), for: indexPath) as! ManageAgentsCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        var agentItem:Agent?
        if isSearching {
            agentItem = self.filteredSearch[indexPath.row]
        } else {
            agentItem = self.agents[indexPath.row]
        }
        cell.agent = agentItem
        return cell
    }
   
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchController.view.backgroundColor = UIColor.telaBlack.withAlphaComponent(0.6)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count == 0 {
            searchController.view.backgroundColor = UIColor.telaBlack.withAlphaComponent(0.6)
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            searchController.view.backgroundColor = .clear
            isSearching = true
            filteredSearch = agents.filter({$0.name?.range(of: searchBar.text!, options: String.CompareOptions.caseInsensitive) != nil})
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ManageAgentsCell.cellHeight
    }
    
}
