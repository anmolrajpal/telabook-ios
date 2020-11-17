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
    let screenEnteredAt = Date()
    
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
    
//    var handle:UInt!
    
    var childUpdatedHandle:UInt! = nil
    
    var childAddedHandle:UInt! = nil
    
    var childDeletedHandle:UInt! = nil
    
//    var firebaseCustomers:[FirebaseCustomer] = []
    
    var selectedSegment:Segment = .Inbox {
        didSet { configureFetchedResultsController() }
    }
    
    var messageNotificationPayload: MessagePayloadJSON? {
        didSet {
            handleMessagePayload()
        }
    }
    func handleMessagePayload()  {
        guard let payload = messageNotificationPayload else { return }
        let conversationID = Int(payload.externalConversationId ?? "0") ?? 0
        if conversationID == 0 { return }
        
        if let conversation = getConversationFromStore(conversationID: conversationID, agent: agent) {
            showMessagesController(forConversation: conversation, animated: true)
        } else {
            // wait for firebase observers to upsert conversation in store and then they will handle notification payload
        }
        
        /*
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@ AND \(#keyPath(Customer.externalConversationID)) = %d", agent, conversationID)
        fetchRequest.fetchLimit = 1
        context.performAndWait {
            if let conversation = try? fetchRequest.execute().first {
                let vc = MessagesController(customer: conversation)
                messageNotificationPayload = nil
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                // fetch from firebase
            }
        }
        */
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
    // MARK: - Init
    
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
//        stopObservingReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        observeReachability()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppear = true
//        fetchCustomers()
        addFirebaseObservers()
        fetchConversations()
        
       
    }

    
    
    // MARK: - Methods
    
    
    /*
    internal func fetchCustomers() {
        if !isFetchedResultsAvailable {
            showLoadingPlaceholers()
            selectedSegment == .Inbox ? startInboxSpinner() : startArchivedSpinner()
        }
     
        let workerIDstring = String(agent.workerID)
        
        handle = reference.observe(.value, with: { snapshot in
//            print(snapshot)
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
    */
    
    private func fetchConversations() {
        if !isFetchedResultsAvailable {
            showLoadingPlaceholers()
            selectedSegment == .Inbox ? startInboxSpinner() : startArchivedSpinner()
        }
        printAndLog(message: "Previous firebase conversations fetched at: \(String(describing: agent.allConversationsFetchedAt))", log: .ui, logType: .info)
        if !allConversations.isEmpty && agent.allConversationsFetchedAt != nil {
            print("Fetching recent conversations")
            fetchRecentConversations()
        } else {
            print("Fetching all conversations")
            fetchAllConversations()
        }
    }
    
    
    private func addFirebaseObservers() {
        childAddedHandle = observeConversationAdded()
        childUpdatedHandle = observeConversationUpdated()
        childDeletedHandle = observeConversationDeleted()
    }
    private func removeFirebaseObservers() {
        if childAddedHandle != nil { reference.removeObserver(withHandle: childAddedHandle) }
        if childUpdatedHandle != nil { reference.removeObserver(withHandle: childUpdatedHandle) }
        if childDeletedHandle != nil { reference.removeObserver(withHandle: childDeletedHandle) }
    }
    
    func saveConversationsFetchTime() {
        agent.allConversationsFetchedAt = Date()
        let context = agent.managedObjectContext!
        context.perform {
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "*** \(self) > ### \(#function) > Error saving context after setting allConversationsFetchedAt value. Error: \(error.localizedDescription)", log: .coredata, logType: .error)
                fatalError()
            }
        }
    }
    
    private func fetchAllConversations() {
        let workerIDstring = String(agent.workerID)
        reference.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            self.saveConversationsFetchTime()
            printAndLog(message: "All firebase conversations fetched at: \(String(describing: self.agent.allConversationsFetchedAt))", log: .ui, logType: .info)
            
            guard snapshot.exists() else {
                self.stopRefreshers()
                self.handleState()
                return
            }
            var conversations = [FirebaseCustomer]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let conversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                        conversations.append(conversation)
                    }
                }
            }
//            self.firebaseCustomers = conversations
            self.persistFirebaseEntriesToCoreDataStore(entries: conversations)
        } withCancel: { error in
            let errorMessage = "*** \(self) > ### \(#function) > Error fetching all conversations from Firebase <single event value observer> | Error: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    func getFirebaseConversation(forConversationID conversationID: Int, completion: @escaping (_ firebaseConversation: FirebaseCustomer?) -> Void) {
        let workerIDstring = String(agent.workerID)
        
        reference.child("\(conversationID)").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                    completion(firebaseConversation)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        } withCancel: { error in
            let errorMessage = "*** \(self) > ### \(#function) > Error fetching conversation for conversationID: \(conversationID) | Error: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
            completion(nil)
        }
    }
    private func fetchRecentConversations() {
        let workerIDstring = String(agent.workerID)
        reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: agent.allConversationsFetchedAt!.milliSecondsSince1970).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            self.saveConversationsFetchTime()
            printAndLog(message: "Recent firebase conversations fetched at: \(String(describing: self.agent.allConversationsFetchedAt))", log: .ui, logType: .info)
            
            guard snapshot.exists() else {
                return
            }
            var conversations = [FirebaseCustomer]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let conversation = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) {
                        conversations.append(conversation)
                    }
                }
            }
//            self.firebaseCustomers = conversations
            
            
            self.upsertRecentFirebaseConversationsInStore(entries: conversations)
        } withCancel: { error in
            let errorMessage = "*** \(self) > ### \(#function) > Error fetching all conversations from Firebase <single event value observer> | Error: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    func observeConversationAdded() -> UInt {
        let workerID = String(agent.workerID)
        return reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: screenEnteredAt.milliSecondsSince1970).observe(.childAdded, with: { [weak self] snapshot in
            guard let self = self else { return }
            print("Conversation child added | Snapshot: \(snapshot)")
            if snapshot.exists() {
                guard let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerID) else {
                    return
                }
                print("Conversation child added, persisting firebase conversation in store")
                self.persistFirebaseConversationInStore(entry: firebaseConversation)
            }
        }) { error in
            printAndLog(message: "*** \(self) > ### \(#function) > Firebase Child Added Observer Event Error while observing new conversation: \(error)", log: .firebase, logType: .error)
        }
    }
    func observeConversationUpdated() -> UInt {
        let workerID = String(agent.workerID)
        return reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: screenEnteredAt.milliSecondsSince1970).observe(.childChanged, with: { [weak self] snapshot in
            guard let self = self else { return }
            if snapshot.exists() {
                guard let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerID) else {
                    return
                }
                self.persistFirebaseConversationInStore(entry: firebaseConversation)
            }
        }) { error in
            printAndLog(message: "*** \(self) > ### \(#function) > Firebase Child Added Observer Event Error while observing new conversation: \(error)", log: .firebase, logType: .error)
        }
    }
    func observeConversationDeleted() -> UInt {
        let workerID = String(agent.workerID)
        return reference.queryOrdered(byChild: "updated_at").queryStarting(atValue: screenEnteredAt.milliSecondsSince1970).observe(.childRemoved, with: { [weak self] snapshot in
            guard let self = self else { return }
            print("Conversation child deleted | Snapshot: \(snapshot)")
            if snapshot.exists() {
                guard let firebaseConversation = FirebaseCustomer(snapshot: snapshot, workerID: workerID) else {
                    return
                }
                print("*** \(self) > ### \(#function) |> Firebase conversation node deleted.")
                let conversationID = firebaseConversation.conversationID
                guard let conversationToDelete = self.getConversationFromStore(conversationID: conversationID, agent: self.agent) else {
                    print("Cannot find conversation to delete in core data store. | Conversation ID: \(conversationID)")
                    return
                }
                self.context.performAndWait {
                    self.agent.removeFromCustomers(conversationToDelete)
                    self.context.delete(conversationToDelete)
                    do {
                        if self.context.hasChanges { try self.context.save() }
                    } catch {
                        print(error)
                    }
                }
//                self.persistFirebaseConversationInStore(entry: firebaseConversation)
            }
        }) { error in
            printAndLog(message: "*** \(self) > ### \(#function) > Firebase Child Added Observer Event Error while observing new conversation: \(error)", log: .firebase, logType: .error)
        }
    }
    
    
    
    
    
    func getConversationFromStore(conversationID: Int, agent: Agent) -> Customer? {
        var conversation: Customer? = nil
        let fetchRequest:NSFetchRequest = Customer.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@ AND \(#keyPath(Customer.externalConversationID)) = %d", agent, Int32(conversationID))
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        context.performAndWait {
            do {
                conversation = try fetchRequest.execute().first
            } catch {
                print("*** \(self) > ### \(#function) > Error fetching conversation from store for conversation id: \(conversationID). | Error: \(error.localizedDescription)")
            }
        }
        return conversation
    }
    
    internal func persistFirebaseConversationInStore(entry: FirebaseCustomer) {
        let existingConversation = getConversationFromStore(conversationID: entry.conversationID, agent: agent)
        let isPinned = existingConversation?.isPinned ?? false
        let customerDetails = existingConversation?.customerDetails?.serverObject
        
        context.performAndWait {
            let conversation = Customer(context: context, conversationEntryFromFirebase: entry, agent: agent)
            conversation.isPinned = isPinned
            if let existingCustomerDetails = customerDetails {
                _ = CustomerDetails(context: context, customerDetailsEntryFromServer: existingCustomerDetails, conversationWithCustomer: conversation)
            }
            do {
                if context.hasChanges { try context.save() }
            } catch let error {
                printAndLog(message: "Error persisting observed message: \(error)", log: .coredata, logType: .error)
            }
        }
        handleMessagePayload()
    }
    internal func upsertRecentFirebaseConversationsInStore(entries: [FirebaseCustomer]) {
        context.performAndWait {
            _ = entries.map { entry -> Customer in
                let existingConversation = self.getConversationFromStore(conversationID: entry.conversationID, agent: agent)
                let isPinned = existingConversation?.isPinned ?? false
                let customerDetails = existingConversation?.customerDetails?.serverObject
                let conversation = Customer(context: context, conversationEntryFromFirebase: entry, agent: agent)
                conversation.isPinned = isPinned
                if let existingCustomerDetails = customerDetails {
                    _ = CustomerDetails(context: context, customerDetailsEntryFromServer: existingCustomerDetails, conversationWithCustomer: conversation)
                }
                return conversation
            }
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "### \(#function) > Error upserting conversations in core data: \(error.localizedDescription)", log: .coredata, logType: .error)
            }
        }
        handleMessagePayload()
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
