//
//  ManageAgentsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
public enum RefreshMode {
    case spinner, refreshControl
}
class ManageAgentsViewController: UIViewController {
    lazy private(set) var subview: ManageAgentsView = {
      return ManageAgentsView(frame: UIScreen.main.bounds)
    }()
    
    var fetchRequest: NSFetchRequest<Agent>!
    
    private var fetchedResultsController: NSFetchedResultsController<Agent>!
    
    enum Section { case main }
    var diffableDataSource: UITableViewDiffableDataSource<Section, Agent>?
    var snapshot: NSDiffableDataSourceSnapshot<Section, Agent>!
    
    internal var filteredSearch = [InternalConversationsCodable]()
    internal var searchController = UISearchController(searchResultsController: nil)
    internal var isSearching = false
//    internal var agents:[InternalConversationsCodable]? {
//        didSet {
//            DispatchQueue.main.async {
//                self.subview.tableView.reloadData()
//            }
//            if let agents = agents {
//                if agents.isEmpty {
//                    self.subview.placeholderLabel.isHidden = false
//                    self.subview.placeholderLabel.text = "No Agents"
//                    self.subview.tableView.isHidden = true
//                }
//            }
//        }
//    }
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupFetchedResultsController()
        setupTableView()
        setupTargetActions()
        setupSearchBar()
        
//        initiateFetchAgentsSequence()
//        fetchAgents()
        fetchedResultsController.sections?.first?.numberOfObjects == 0 ? initiateFetchAgentsSequence(withRefreshMode: .spinner) : initiateFetchAgentsSequence(withRefreshMode: .refreshControl)
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
    
    private func setupFetchedResultsController() {
        if fetchRequest == nil {
            fetchRequest = Agent.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Agent.date), ascending: false)]
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: PersistentContainer.shared.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: String(describing: self))
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            updateSnapshot()
        } catch {
            print("Error fetching results: \(error)")
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        
            fetchAgents()
        
    }
    fileprivate func setupTargetActions() {
        subview.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    fileprivate func setupTableView() {
        subview.tableView.refreshControl = subview.refreshControl
        subview.tableView.register(ManageAgentsCell.self, forCellReuseIdentifier: NSStringFromClass(ManageAgentsCell.self))
        subview.tableView.delegate = self
//        subview.tableView.dataSource = self
        self.diffableDataSource = UITableViewDiffableDataSource<Section, Agent>(tableView: self.subview.tableView, cellProvider: { (tableView, indexPath, agent) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ManageAgentsCell.self), for: indexPath) as! ManageAgentsCell
            cell.backgroundColor = .clear
            cell.agentDetails = agent
            return cell
        })
        updateSnapshot()
    }
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    private func updateSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Section, Agent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(snapshot, animatingDifferences: true, completion: {
            self.handleState()
        })
    }
    
    
    func handleState() {
        if self.fetchedResultsController.sections?.first?.numberOfObjects == 0 {
            DispatchQueue.main.async {
//                self.subview.tableView.isHidden = true
                self.subview.placeholderLabel.text = "Fetching"
                self.subview.placeholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
//                self.subview.tableView.isHidden = false
                self.subview.placeholderLabel.isHidden = true
            }
        }
    }
    func stopRefreshers() {
        self.subview.spinner.stopAnimating()
        self.subview.tableView.refreshControl?.endRefreshing()
    }
    
    func initiateFetchAgentsSequence(withRefreshMode refreshMode: RefreshMode) {
        if refreshMode == .spinner {
            DispatchQueue.main.async {
                self.subview.spinner.startAnimating()
                self.fetchAgents()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.subview.tableView.refreshControl?.beginExplicitRefreshing()
            }
        }
    }
    func fetchAgents() {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = AgentOperations.getOperationsToFetchLatestEntries(using: context)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        print("Entering Operations loop")
        operations.forEach { operation in
            if let operation = operation as? FetchMostRecentAgentsEntryOperation {
                operation.completionBlock = {
                    if let error = operation.error {
                        DispatchQueue.main.async {
                            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "OK", style: .destructive, handler: { action in
                                self.navigationController?.popViewController(animated: true)
                            }), controller: self, completion: {
                                queue.cancelAllOperations()
                                self.stopRefreshers()
                            })
                        }
                    }
                }
            } else if let operation = operation as? DownloadAgentsEntriesFromServerOperation {
                operation.completionBlock = {
                    guard case let .failure(error) = operation.result else { return }
                    DispatchQueue.main.async {
                        UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "OK", style: .destructive, handler: { action in
                            self.navigationController?.popViewController(animated: true)
                        }), controller: self, completion: {
                            queue.cancelAllOperations()
                            self.stopRefreshers()
                        })
                    }
                }
            } else if let operation = operation as? AddAgentsEntriesToStoreOperation {
                print("AddAgentsOperation - : \(operation)")
                operation.completionBlock = {
                    print("Reached Add Agents Completion Block")
                    if let error = operation.error {
                        DispatchQueue.main.async {
                            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "OK", style: .destructive, handler: { action in
                                self.navigationController?.popViewController(animated: true)
                            }), controller: self, completion: {
                                queue.cancelAllOperations()
                                self.stopRefreshers()
                            })
                        }
                    } else {
                        print("No Error")
                        DispatchQueue.main.async {
                            self.stopRefreshers()
                            self.updateSnapshot()
                        }
                    }
                }
            }
        }
    }
    fileprivate func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search Agents"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.sizeToFit()
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
            subview.tableView.tableHeaderView = searchController.searchBar
        }
    }
//    let tableView : UITableView = {
//        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
//        tv.translatesAutoresizingMaskIntoConstraints = false
//        tv.backgroundColor = .clear
//        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
//        tv.bounces = true
//        tv.alwaysBounceVertical = true
//        tv.clipsToBounds = true
//        tv.showsHorizontalScrollIndicator = false
//        tv.showsVerticalScrollIndicator = true
//        tv.tableFooterView = UIView(frame: CGRect.zero)
//        return tv
//    }()
//    let placeholderLabel:UILabel = {
//        let label = UILabel()
//        label.text = "Turn on Mobile Data or Wifi to Access Telabook"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
//        label.textColor = UIColor.telaGray6
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.sizeToFit()
//        label.isHidden = true
//        return label
//    }()
}
struct UserAgent {
    let profileImage:UIImage?
    let name:String?
    let details:String?
}




extension ManageAgentsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}
