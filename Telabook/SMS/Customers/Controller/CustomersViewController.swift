//
//  CustomersViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage

extension CustomersViewController.Segment: CaseIterable { }
class CustomersViewController: UIViewController {
    let fetchRequest: NSFetchRequest<Customer>
    let context:NSManagedObjectContext
    let agent:Agent
    init(fetchRequest: NSFetchRequest<Customer>, viewContext:NSManagedObjectContext, agent:Agent) {
        self.fetchRequest = fetchRequest
        self.agent = agent
        self.context = viewContext
        super.init(nibName: nil, bundle: nil)
        setupFetchedResultsController()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Enums
    enum Segment:Int { case Inbox, Archived ; var stringValue:String { String(describing: self).uppercased() } }
    enum Section { case main }
    
    
    
    // MARK: Constructors
    lazy private(set) var subview: CustomersView = {
        return CustomersView(frame: UIScreen.main.bounds)
    }()
    
    var selectedSegment:Segment = .Inbox {
        didSet { self.handleEvents(for: selectedSegment) }
    }
    
    
    internal var fetchedResultsController: NSFetchedResultsController<Customer>!
    
    
    var diffableDataSource: UITableViewDiffableDataSource<Section, Customer>?
    var snapshot: NSDiffableDataSourceSnapshot<Section, Customer>!
    
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        stopObservingReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = agent.personName?.uppercased() ?? agent.phoneNumber ?? "Customers"
        subview.segmentedControl.selectedSegmentIndex = selectedSegment.rawValue
//        observeReachability()
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
        setupNavBarItems()
        setupTableView()
        setupTargetActions()
//        setupSearchController()
        fetchCustomers()
    }
    
    
    internal func fetchCustomers() {
        let companyID = AppData.companyId
        let workerID = Int(agent.workerID)
        let node:Config.FirebaseConfig.Node = .conversations(companyID: companyID, workerID: workerID)
        let reference = node.reference
        
        reference.observe(.childAdded, with: { snapshot in
            print("Snapshot Key: \(snapshot.key)")
            guard let dictionary = snapshot.value else { return }
            do {
                print("\n\n")
                print(dictionary)
                print("\n\n")
                let decoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                let object = try decoder.decode(CustomerCodable.Datum.Conversation.self, from: jsonData)
//                let object = try DictionaryDecoder().decode(CustomerCodable.Datum.Conversation.self, from: dictionary)
                print(object)
                print("\n\n")
            } catch let err {
                print("JSON Decoding Error: \(err)")
            }
        }) { error in
            print(error)
        }
        
    }
}
class DictionaryEncoder {
    private let jsonEncoder = JSONEncoder()

    /// Encodes given Encodable value into an array or dictionary
    func encode<T>(_ value: T) throws -> Any where T: Encodable {
        let jsonData = try jsonEncoder.encode(value)
        return try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    }
}

class DictionaryDecoder {
    private let jsonDecoder = JSONDecoder()
    
    /// Decodes given Decodable type from given array or dictionary
    func decode<T>(_ type: T.Type, from json: Any) throws -> T where T: Decodable {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try jsonDecoder.decode(type, from: jsonData)
    }
}
