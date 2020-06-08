//
//  AgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
import Firebase
class AgentsViewController: UIViewController {
    var handle:UInt!
    let reference = Config.FirebaseConfig.Node.wasNotSeen.reference
    let fetchRequest: NSFetchRequest<Agent>
    let context:NSManagedObjectContext
    init(fetchRequest: NSFetchRequest<Agent>, viewContext: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.context = viewContext
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
    internal var agents:[Agent] {
        return fetchedResultsController.fetchedObjects ?? []
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
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "SMS"
        observeReachability()
        addFirebaseObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingReachability()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        observeReachability()
        
        if let selectionIndexPath = self.subview.tableView.indexPathForSelectedRow {
            self.subview.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFirebaseObservers()
//        stopObservingReachability()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Common setup
    private func commonInit() {
        setUpNavBar()
        setupTableView()
        setupTargetActions()
        setupSearchController()
        synchronizeWithTimeLogic()
    }
}
