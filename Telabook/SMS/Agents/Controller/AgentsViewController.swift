//
//  AgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import CoreData

class AgentsViewController: UIViewController {
    let fetchRequest: NSFetchRequest<Agent>
    init(fetchRequest: NSFetchRequest<Agent>) {
        self.fetchRequest = fetchRequest
        super.init(nibName: nil, bundle: nil)
        setupFetchedResultsController()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Constructors
    lazy private(set) var subview: AgentsView = {
        return AgentsView(frame: UIScreen.main.bounds)
    }()
    
    
    
    internal var fetchedResultsController: NSFetchedResultsController<Agent>!
    
    enum Section { case main }
    var diffableDataSource: UITableViewDiffableDataSource<Section, Agent>?
    var snapshot: NSDiffableDataSourceSnapshot<Section, Agent>!
    
    internal var currentSearchText = ""
    
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    //MARK: init
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "MANAGE AGENTS"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectionIndexPath = self.subview.tableView.indexPathForSelectedRow {
            self.subview.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Common setup
    private func setup() {
        setUpNavBar()
        setupTableView()
        setupTargetActions()
        setupSearchController()
        synchronizeWithTimeLogic()
    }
}
