//
//  CallsTabAgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

class CallsTabAgentsViewController: UITableViewController {
    
    // MARK: - Stored Properties / declarations
    
    var selectedIndexPath:IndexPath?
    var selectedAgent: Agent?
    var viewDidAppear = false
    var showOnlyDisabledAccounts = false
    
    var handle: UInt!
    let reference = Config.FirebaseConfig.Node.wasNotSeen.reference
    
    let context:NSManagedObjectContext = PersistentContainer.shared.viewContext
    var fetchedResultsController: NSFetchedResultsController<Agent>! = nil
    
    var dataSource:DataSource! = nil
    let searchController = UISearchController(searchResultsController: nil)
    var currentSearchText = ""
    
    
    
    
    
    // MARK: - Computed Properties
    
    internal var agents:[Agent] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        observeReachability()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
        synchronizeAgents()
//        addFirebaseObservers()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        removeFirebaseObservers()
    }
    
    deinit {
        print("\(self): Deinitialized")
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
