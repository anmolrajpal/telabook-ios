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

protocol CustomerPickerDelegate: class {
    func customersController(didPick customer:Customer, at indexPath:IndexPath, controller:UIViewController)
}
protocol MessageForwardingDelegate: class {
    func forwardMessage(to selectedConversations: [Customer], controller: CustomersViewController)
}
class CustomersViewController: UITableViewController {
    
    // MARK: - Properties
    
    weak var messageForwardingDelegate: MessageForwardingDelegate?
    
    weak var pickerDelegate:CustomerPickerDelegate?
    
    var selectedConversationsToForwardMessage = [Customer]()
    
    var viewDidAppear = false
    
    var dataSource: CustomerDataSource! = nil
    
    var fetchedResultsController: NSFetchedResultsController<Customer>! = nil
    
    let searchController = UISearchController(searchResultsController: nil)
    
    internal var currentSearchText = ""
    
    var selectedIndexPath:IndexPath?
    
    var selectedCustomer:Customer?
    
    let node:Config.FirebaseConfig.Node
    
    let context:NSManagedObjectContext = PersistentContainer.shared.viewContext
    
    let agent:Agent
    
    let reference:DatabaseReference
    
    var handle:UInt!
    
    var firebaseCustomers:[FirebaseCustomer] = []
    
    var selectedSegment:Segment = .Inbox {
        didSet { configureFetchedResultsController() }
    }
    
    

    // MARK: - Init
    
    init(agent:Agent) {
        self.agent = agent
        self.node = .conversations(companyID: AppData.companyId, workerID: Int(agent.workerID))
        self.reference = node.reference
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        
    }
    
    
    
    
    enum Segment:Int, CaseIterable { case Inbox, Archived ; var stringValue:String { String(describing: self).uppercased() } }
    
    
    
    
    // MARK: - Computed Properties
    
    internal var isFetchedResultsAvailable:Bool {
        return !(fetchedResultsController.fetchedObjects?.isEmpty ?? true)
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var customers:[Customer] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureNavigationBarHeaderView()
        commonInit()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if let headerView = navigationController?.navigationBar.subviews.first(where: { $0 is UISegmentedControl }) {
//            headerView.removeFromSuperview()
//        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFirebaseObservers()
        stopObservingReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeReachability()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppear = true
        fetchCustomers()
    }

    
    
    // MARK: - Methods
    
    internal func fetchCustomers() {
        if !isFetchedResultsAvailable {
            showLoadingPlaceholers()
            selectedSegment == .Inbox ? startInboxSpinner() : startArchivedSpinner()
        }
     
        let workerIDstring = String(agent.workerID)
        
        handle = reference.observe(.value, with: { snapshot in
            var conversations:[FirebaseCustomer] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let conversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                        conversations.append(conversation)
                    }
                }
            }
            self.firebaseCustomers = conversations
            self.persistFirebaseEntriesToCoreDataStore(entries: conversations)
        }) { error in
            print("Value Observer Event Error: \(error)")
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var segmentedControl:UISegmentedControl = {
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
            ]
        let unselectedAttributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaGray7
        ]
        let control = UISegmentedControl(items: CustomersViewController.Segment.allCases.map { $0.stringValue })
        control.selectedSegmentIndex = CustomersViewController.Segment.Inbox.rawValue
        control.tintColor = .clear
        control.selectedSegmentTintColor = .telaGray6
        control.setTitleTextAttributes(attributes, for: UIControl.State.selected)
        control.setTitleTextAttributes(unselectedAttributes, for: UIControl.State.normal)
        control.backgroundColor = .telaGray3
        control.layer.cornerRadius = 0
        return control
    }()
    lazy var inboxSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var archivedSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var inboxPlaceholderLabel:UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var archivedPlaceholderLabel:UILabel = {
        let label = UILabel()
        label.text = "No Archived Conversations"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var refreshButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        return button
    }()
    
    
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "autoresponse_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(#imageLiteral(resourceName: "autoresponse_icon").withTintColor(.gray, renderingMode: .alwaysOriginal), for: .disabled)
        return button
    }()
    
    
    // MARK: Alert Views
    lazy var reasonTextView:UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.isEditable = true
        textView.textAlignment = .left
        textView.isSelectable = true
        textView.backgroundColor = UIColor.telaGray4
        textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
        textView.textColor = UIColor.telaGray7
        textView.sizeToFit()
        textView.isScrollEnabled = true
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 7
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    lazy var characterCountLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Character limit: 70"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    
    
    
    
    
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
