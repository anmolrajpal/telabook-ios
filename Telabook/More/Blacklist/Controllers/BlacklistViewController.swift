//
//  BlacklistViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

class BlacklistViewController: UIViewController {
    
    
    lazy private(set) var subview: BlacklistView = {
        return BlacklistView(frame: UIScreen.main.bounds)
    }()
    enum Section { case main }
    internal var fetchedResultsController: NSFetchedResultsController<BlockedUser>!
    
    
    var dataSource: DataSource! = nil
    
    internal var currentSearchText = ""
    
    var isDownloading = false
    var viewContext:NSManagedObjectContext!
    
    var isFetchedResultsAvailable:Bool {
        return !blacklist.isEmpty
    }
    var blacklist:[BlockedUser] {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        super.loadView()
        view.addSubview(subview)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        subview.frame = view.bounds
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "BLACKLIST"
        observeReachability()
        if let selectionIndexPath = self.subview.tableView.indexPathForSelectedRow {
            self.subview.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopObservingReachability()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
}
