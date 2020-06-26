//
//  CustomersViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage

class CustomersViewController: UIViewController {
    let fetchRequest: NSFetchRequest<Customer>
    let node:Config.FirebaseConfig.Node
    let context:NSManagedObjectContext
    let agent:Agent
    let reference:DatabaseReference
    var handle:UInt!
    var firebaseCustomers:[FirebaseCustomer] = []
    init(fetchRequest: NSFetchRequest<Customer>, viewContext:NSManagedObjectContext, agent:Agent) {
        self.fetchRequest = fetchRequest
        self.agent = agent
        self.context = viewContext
        self.node = .conversations(companyID: AppData.companyId, workerID: Int(agent.workerID))
        self.reference = node.reference
        super.init(nibName: nil, bundle: nil)
        
//        self.selectedSegment = .Inbox
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Enums
    enum Segment:Int, CaseIterable { case Inbox, Archived ; var stringValue:String { String(describing: self).uppercased() } }
    enum Section { case main }
    
    
    
    // MARK: Constructors
    lazy private(set) var subview: CustomersView = {
        return CustomersView(frame: UIScreen.main.bounds)
    }()
    
    var selectedSegment:Segment = .Inbox {
        didSet { self.setupFetchedResultsController() }
    }
    
    
    internal var fetchedResultsController: NSFetchedResultsController<Customer>!
    
    
    var dataSource: CustomerDataSource!
    
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
        reference.removeObserver(withHandle: handle)
        stopObservingReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = agent.personName?.uppercased() ?? agent.phoneNumber ?? "Customers"
        observeReachability()
        fetchCustomers()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectionIndexPath = self.subview.tableView.indexPathForSelectedRow {
            self.subview.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }

    
    // MARK: Common setup
    private func setup() {
        setUpNavBar()
        setupTableView()
        configureDataSource()
        setupFetchedResultsController()
        setupNavBarItems()
        setupTargetActions()
//        setupSearchController()
    }
    
    
    internal func fetchCustomers() {
        if !isFetchedResultsAvailable {
            showLoadingPlaceholers()
            selectedSegment == .Inbox ? startInboxSpinner() : startArchivedSpinner()
        }
     
        let workerIDstring = String(agent.workerID)
        
        handle = reference.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
//                print("Snapshot Does not exists: returning")
                return
            }
            var conversations:[FirebaseCustomer] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    guard let conversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) else {
//                        print("Unresolved Error: Unable to create conversation from Firebase Customer")
                        continue
                    }
//                    print(conversation)
                    conversations.append(conversation)
                }
            }
            self.firebaseCustomers = conversations
            self.persistFirebaseEntriesToCoreDataStore(entries: conversations)
//            print(snapshot.value as Any)
        }) { error in
            print("Value Observer Event Error: \(error)")
        }
        
        
        
        /*
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
        */
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
