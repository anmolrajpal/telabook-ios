//
//  ManageAgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
public enum RefreshMode {
    case spinner, refreshControl, none
}
class ManageAgentsViewController: UIViewController {
    // MARK: Constructors
    lazy private(set) var subview: ManageAgentsView = {
        return ManageAgentsView(frame: UIScreen.main.bounds)
    }()
    
    var fetchRequest: NSFetchRequest<Agent>!
    
    internal var fetchedResultsController: NSFetchedResultsController<Agent>!
    
    enum Section { case main }
    var diffableDataSource: UITableViewDiffableDataSource<Section, Agent>?
    var snapshot: NSDiffableDataSourceSnapshot<Section, Agent>!
    
    internal var filteredSearch = [InternalConversationsCodable]()
    
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
        setupFetchedResultsController()
        setupTableView()
        setupTargetActions()
        setupSearchController()
        synchronizeWithTimeLogic()
    }
    
}


extension ManageAgentsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSnapshot()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.updateSnapshot()
    }
}
extension ManageAgentsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = text
        setupFetchedResultsController()
    }
}
