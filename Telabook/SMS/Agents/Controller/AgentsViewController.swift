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

protocol AgentPickerDelegate {
    func agentsController(didPick agent:Agent, at indexPath:IndexPath, controller:UIViewController)
}

class AgentsViewController: UIViewController {
    
    // MARK: - Properties
    
    var pickerDelegate:AgentPickerDelegate?
    var selectedIndexPath:IndexPath?
    var selectedAgent:Agent?
    
    var handle:UInt!
    let reference = Config.FirebaseConfig.Node.wasNotSeen.reference

    let context:NSManagedObjectContext = PersistentContainer.shared.viewContext
    var fetchedResultsController: NSFetchedResultsController<Agent>! = nil
   
    var dataSource:DataSource! = nil
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - Constructors
    
    lazy private(set) var subview: AgentsView = {
        return AgentsView(frame: UIScreen.main.bounds)
    }()
    
    
    
    
    
    
//    var diffableDataSource: UITableViewDiffableDataSource<Section, Agent>?
//    var snapshot: NSDiffableDataSourceSnapshot<Section, Agent>!
    
    internal var currentSearchText = ""
    
    
    
    
    
    
    
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
    
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeReachability()
        addFirebaseObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        synchronizeAgents()
        
        if let selectionIndexPath = self.subview.tableView.indexPathForSelectedRow {
            self.subview.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFirebaseObservers()
        stopObservingReachability()
    }
 
    
    
}
