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

protocol CustomerPickerDelegate: AnyObject {
    func customersController(didPick customer:Customer, at indexPath:IndexPath, controller:UIViewController)
}
protocol MessageForwardingDelegate: AnyObject {
    func forwardMessage(to selectedConversations: [Customer], controller: CustomersViewController)
}


class CustomersViewController: UITableViewController {
    
    // MARK: - Properties / Declarations
    
    var screenEnteredAt = Date()
    
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
    
    var isDownloading = false
    
    var childUpdatedHandle:UInt! = nil
    
    var childAddedHandle:UInt! = nil
    
    var childDeletedHandle:UInt! = nil
    
    
    var selectedSegment:Segment = .Inbox {
        didSet {
            guard var snapshot = currentSnapshot() else {
                configureFetchedResultsController()
                return
            }
//            snapshot.deleteItems(customers) // This is better but it gives a small delay when deleting large data set
            snapshot.deleteSections([.main])
            dataSource.apply(snapshot, animatingDifferences: false)
            configureFetchedResultsController()
        }
    }
    
    var messageNotificationPayload: MessagePayloadJSON? {
        didSet {
            handleMessagePayload()
        }
    }
    
    
    
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
    var allConversations: [Customer] {
        let fetchRequest:NSFetchRequest = Customer.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@", agent)
        fetchRequest.predicate = predicate
        var conversations = [Customer]()
        context.performAndWait {
            do {
                conversations = try fetchRequest.execute()
            } catch {
                printAndLog(message: "Error fetching all conversations. Error: \(error.localizedDescription)", log: .coredata, logType: .error)
            }
        }
        return conversations
    }
    
  
    
    
    // MARK: - Init / Deinit
    
    init(agent: Agent) {
        self.agent = agent
        self.node = .conversations(companyID: AppData.companyId, workerID: Int(agent.workerID))
        self.reference = node.reference
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\(self): Deinitialized")
    }
    
    
    
    // Enum - Semgented control
    enum Segment:Int, CaseIterable { case Inbox, Archived ; var stringValue:String { String(describing: self).uppercased() } }
    
    
    
    
    
    
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureNavigationBarHeaderView()
        commonInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        observeReachability()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenEnteredAt = Date()
        viewDidAppear = true
        configureFetchedResultsController()
        addFirebaseObservers()
        fetchConversations()
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
//        stopObservingReachability()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        view.bringSubviewToFront(segmentedControl) // This is used when adding segmented control in self.view
    }
    
    
    
    
    
    // MARK: - Methods
    
    func handleMessagePayload()  {
        guard let payload = messageNotificationPayload else { return }
        let conversationID = Int(payload.externalConversationId ?? "0") ?? 0
        if conversationID == 0 { return }
        
        if let conversation = getConversationFromStore(conversationID: conversationID, agent: agent) {
            showMessagesController(forConversation: conversation, animated: true)
        } else {
            // wait for firebase observers to upsert conversation in store and then they will handle notification payload
        }
    }
    func showMessagesController(forConversation conversation: Customer, animated: Bool) {
        let id = conversation.customerID
        guard id != 0,
            conversation.node != nil else { return }
        let vc = MessagesController(customer: conversation)
        messageNotificationPayload = nil
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(vc, animated: animated)
        }
        viewDidAppear = false
    }
    
    
    
    
    
    // MARK: - Constructors
    
    lazy var fetchRequest:NSFetchRequest<Customer> = {
        let fetchRequest:NSFetchRequest<Customer> = Customer.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.propertiesToFetch = ["\(#keyPath(Customer.customerID))", "\(#keyPath(Customer.phoneNumber))", "\(#keyPath(Customer.addressBookName))", "\(#keyPath(Customer.colorCode))", "\(#keyPath(Customer.isPinned))", "\(#keyPath(Customer.lastMessageDateTime))", "\(#keyPath(Customer.messageType))"]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Customer.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(Customer.lastMessageDateTime), ascending: false)
        ]
        return fetchRequest
    }()
    
    
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
