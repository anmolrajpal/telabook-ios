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

protocol AgentPickerDelegate: class {
    func agentsController(didPick agent: Agent, at indexPath: IndexPath, controller: AgentsViewController)
}
protocol MessageForwardingAgentSelectionDelegate: class {
    func agentsController(didSelect agent: Agent, workerID: Int, at indexPath: IndexPath, controller: AgentsViewController)
}
class AgentsViewController: UITableViewController {
    
    // MARK: - Stored Properties / declarations
    
    weak var pickerDelegate: AgentPickerDelegate?
    weak var messageForwardingDelegate: MessageForwardingAgentSelectionDelegate?
    
    var selectedIndexPath:IndexPath?
    var selectedAgent:Agent?
    var viewDidAppear = false
    var showOnlyDisabledAccounts = false
    
    var handle:UInt!
    let reference = Config.FirebaseConfig.Node.wasNotSeen.reference
    
    let context:NSManagedObjectContext = PersistentContainer.shared.viewContext
    var fetchedResultsController: NSFetchedResultsController<Agent>! = nil
    
    var dataSource:DataSource! = nil
    let searchController = UISearchController(searchResultsController: nil)
    var currentSearchText = ""
    
    
    var messageNotificationPayload: MessagePayloadJSON? {
        didSet {
            handleMessagePayload()
        }
    }
    
    func handleMessagePayload()  {
        guard let payload = messageNotificationPayload else { return }
        let workerId = Int(payload.workerId ?? "0") ?? 0
        if workerId == 0 { return }
        if let agent = agents.first(where: { $0.workerID == Int32(workerId) }) {
            let vc = CustomersViewController(agent: agent)
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.pushViewController(vc, animated: false)
                vc.messageNotificationPayload = payload
                self?.messageNotificationPayload = nil
            }
        }
    }
    
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
        observeReachability()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
        synchronizeAgents()
        addFirebaseObservers()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFirebaseObservers()
        stopObservingReachability()
        messageNotificationPayload = nil
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
