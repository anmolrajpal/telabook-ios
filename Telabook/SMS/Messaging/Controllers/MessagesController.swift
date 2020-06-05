//
//  MessagesController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import MessageKit
import AVFoundation
import os

class MessagesController: MessagesViewController {
    
    
    
    
    let screenEntryTime = Date()
    var handle:UInt!
    var childUpdatedHandle:UInt!
    var childAddedHandle:UInt!
    let customer:Customer
    let node:Config.FirebaseConfig.Node
    let reference:DatabaseReference
    let conversationID:Int
    let viewContext:NSManagedObjectContext
    var thisSender:MessageSender
    let conversationReference:DatabaseReference
    
    
    init(context:NSManagedObjectContext, customer:Customer, conversationReference:DatabaseReference) {
        self.viewContext =  context
        self.customer = customer
        self.conversationReference = conversationReference
        self.node = .messages(companyID: AppData.companyId, node: customer.node!)
        self.reference = node.reference
        self.conversationID = Int(customer.externalConversationID)
        self.thisSender = .init(senderId: String(customer.agent?.workerID ?? 0), displayName: customer.agent?.personName ?? "")
        super.init(nibName: nil, bundle: nil)
        
        setupFetchedResultsController()
        
        performFetch()
//        fetchMoreMessages()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        synthesizer.stopSpeaking(at: .immediate)
    }
    let synthesizer = AVSpeechSynthesizer()
    
    internal var storageUploadTask:StorageUploadTask!
    internal var fetchedResultsController: NSFetchedResultsController<UserMessage>!
    
    
    var limit: Int = 20
    
    
    
    
    var didSentNewMessage = false
    
    /*
    var messages:[UserMessage] = [] {
        didSet {
            if !messages.isEmpty {
                self.stopSpinner()
            }
        }
    }
    */
    var messages:[UserMessage] {
        fetchedResultsController.fetchedObjects?.reversed() ?? []
    }
    
    
    
    /*
    lazy var fetchedResultsController: NSFetchedResultsController<UserMessage> = {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        
        fetchRequest.predicate = conversationPredicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(UserMessage.date), ascending: false)
        ]
        
//        fetchRequest.fetchOffset = self.offset
//        fetchRequest.fetchLimit = self.limit
        fetchRequest.fetchBatchSize = 15
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        return controller
    }()
    */
    /*
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    internal var fetchedResults:[UserMessage]? {
        return fetchedResultsController.fetchedObjects?.reversed()
    }
    internal var fetchedResultsCount:Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    */
    
    
    var headerSpinnerView:SpinnerReusableView?
    
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    
    var collectionViewOperations: [BlockOperation] = []
    
    
    
//    var scrollsToBottomOnKeyboardBeginsEditing: Bool = false
//    var maintainPositionOnKeyboardFrameChanged: Bool = false
    
//    var additionalBottomInset: CGFloat = 0 {
//        didSet {
//            let delta = additionalBottomInset - oldValue
//            messageCollectionViewBottomInset += delta
//        }
//    }
    var isFirstLayout: Bool = true
    internal var isMessagesControllerBeingDismissed: Bool = false
    
    
//    internal var messageCollectionViewBottomInset: CGFloat = 0 {
//        didSet {
//            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
//            messagesCollectionView.verticalScrollIndicatorInsets.bottom = messageCollectionViewBottomInset
//        }
//    }
    

    
    
    //MARK: Lifecycle
    override func loadView() {
        super.loadView()
//        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .telaGray1
        setUpNavBar()
//        setupFetchedResultsController()
        commonInit()
        loadInitialMessagesFromFirebase()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        reference.removeObserver(withHandle: handle)
        stopObservingReachability()
        removeFirebaseObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = customer.addressBookName?.isEmpty ?? true ? customer.phoneNumber : customer.addressBookName
        observeReachability()
//        loadMessages()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFirebaseObservers()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if isFirstLayout {
//            defer { isFirstLayout = false }
//            if self.isLastSectionVisible() == true {
//                self.messagesCollectionView.scrollToBottom(animated: true)
//            }
//        }
//        if isFirstLayout {
//            defer { isFirstLayout = false }
////            addKeyboardObservers()
//            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
//        }
//        adjustScrollViewTopInset()
        
        
        
        
    }
    
    func addFirebaseObservers() {
        childAddedHandle = observeNewMessages()
        childUpdatedHandle = observeExistingMessages()
    }
    func removeFirebaseObservers() {
        reference.removeObserver(withHandle: childAddedHandle)
        reference.removeObserver(withHandle: childUpdatedHandle)
    }
    
    

//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
//        let dataSource = messagesFlowLayout.messagesDataSource
//        let message = dataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! UserMessage
////        messagesFlowLayout.estimatedItemSize = MessagesCollectionViewFlowLayout.automaticSize
//        if message.isFault {
//            print("Fault at indexPath: \(indexPath)")
//            return .zero
//        } else {
//            print("Firing Fault at indexPath: \(indexPath)")
//            return messagesFlowLayout.sizeForItem(at: indexPath)
//        }
////        return .init(width: collectionView.frame.width, height: 200)
//    }
    
    
    
    
    
    
    
    /*
    func loadMoreMessagesFromFirebase(offsetMessage:UserMessage) {
        guard !isLoading else { return }
        isLoading = true
        let key = offsetMessage.firebaseKey!
        reference.queryEnding(atValue: key).queryLimited(toLast: UInt(limit + 1)).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                #if !RELEASE
                print("Snapshot Does not exists: returning")
                #endif
                return
            }
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
//                    print(snapshot)
                    guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                        #if !RELEASE
                        print("Invalid Data Error: Failed to create message from Firebase Message")
                        #endif
                        os_log("Invalid Data, Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, type: .debug)
                        continue
                    }
                    //                    print(conversation)
                    messages.append(message)
                }
            }
            self.persistFirebaseMessagesInStore(entries: Array(messages.dropFirst()))
        }) { error in
            #if !RELEASE
            print("Value Single Event Observer Error: \(error)")
            #endif
            os_log("Firebase Single Event Observer Error while observing Messages: %@", log: .firebase, type: .error, error.localizedDescription)
        }
    }
 */
    
    func observeNewMessages() -> UInt {
        return reference.queryOrdered(byChild: "date").queryStarting(atValue: screenEntryTime.milliSecondsSince1970).observe(.childAdded, with: { snapshot in
            if snapshot.exists() {
                print("New Message Child Added: \(snapshot)")
                guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                    #if !RELEASE
                    print("###\(#function) Invalid Data for Snapshot key: \(snapshot.key). Error: Failed to create message from Firebase Message")
                    #endif
                    os_log("Invalid Data for Snapshot key: %@. Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, type: .debug, snapshot.key)
                    return
                }
                self.persistFirebaseMessagesInStore(entries: [message])
            }
        }) { error in
            #if !RELEASE
            print("###\(#function) Child Added Observer Event Error: \(error)")
            #endif
            os_log("Firebase Child Added Observer Event Error while observing new Messages: %@", log: .firebase, type: .error, error.localizedDescription)
        }
    }
    func observeExistingMessages() -> UInt {
        return reference.queryOrdered(byChild: "date").queryStarting(atValue: screenEntryTime.milliSecondsSince1970).observe(.childChanged, with: { snapshot in
            if snapshot.exists() {
                print("Existing Message Child Updated: \(snapshot)")
                guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                    #if !RELEASE
                    print("###\(#function) Invalid Data for Snapshot key: \(snapshot.key). Error: Failed to create updated message from Firebase Message.")
                    #endif
                    os_log("Invalid Data for Snapshot key: %@. Unable to create updated Message from Firebase Message due to invalid data. Hence not updating it in core data and the updated message will not be visible to user.", log: .firebase, type: .debug, snapshot.key)
                    return
                }
                self.persistFirebaseMessagesInStore(entries: [message])
            }
        }) { error in
            #if !RELEASE
            print("###\(#function) Child Changed Observer Event Error: \(error)")
            #endif
            os_log("Firebase Child Changed Observer Event Error while observing existing Messages: %@", log: .firebase, type: .error, error.localizedDescription)
        }
    }
    
    
    func loadMessages() {
        if messages.isEmpty { self.startSpinner() }
        
        handle = reference.queryLimited(toLast: UInt(limit)).observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                #if !RELEASE
                print("Snapshot Does not exists: returning")
                #endif
                return
            }
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
//                    print(snapshot)
                    guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                        #if !RELEASE
                        print("Invalid Data Error: Failed to create message from Firebase Message")
                        #endif
                        os_log("Invalid Data, Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, type: .debug)
                        continue
                    }
                    //                    print(conversation)
                    messages.append(message)
                }
            }
//            self.firebaseCustomers = conversations
            self.persistFirebaseMessagesInStore(entries: messages)
            //            print(snapshot.value as Any)
        }) { error in
            #if !RELEASE
            print("Value Observer Event Error: \(error)")
            #endif
            os_log("Firebase Value Observer Event Error while observing Messages: %@", log: .firebase, type: .error, error.localizedDescription)
        }
    }
    
    
    
    
    func loadInitialMessagesFromFirebase() {
        print("Loading Initial Messages from Firebase")
      
        reference.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                #if !RELEASE
                print("Snapshot Does not exists: returning")
                #endif
                return
            }
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    //                    print(snapshot)
                    guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                        #if !RELEASE
                        print("Invalid Data Error: Failed to create message from Firebase Message")
                        #endif
                        os_log("Invalid Data, Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, type: .debug)
                        continue
                    }
                    //                    print(conversation)
                    messages.append(message)
                }
            }
            self.persistFirebaseMessagesInStore(entries: Array(messages))
        }) { error in
            #if !RELEASE
            print("Value Single Event Observer Error: \(error)")
            #endif
            os_log("Firebase Single Event Observer Error while observing Messages: %@", log: .firebase, type: .error, error.localizedDescription)
        }
    }
    
    
    func loadMoreMessagesFromFirebase(offsetMessage:UserMessage) {
        print("Loading More Messages from Firebase")
        
        let key = offsetMessage.firebaseKey!
        print("### \(#function) Message Count : \(messages.count) | offset message text: \(offsetMessage.textMessage ?? "---") | Key: \(key)")
        
        reference.queryEnding(atValue: key).queryLimited(toLast: UInt(21)).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                #if !RELEASE
                print("Snapshot Does not exists: returning")
                #endif
                return
            }
            var messages:[FirebaseMessage] = []
            print("Snapshot Children Count: \(snapshot.children.allObjects.count)")
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
//                                        print(snapshot)
                    guard let message = FirebaseMessage(snapshot: snapshot, conversationID: self.conversationID) else {
                        #if !RELEASE
                        print("Invalid Data Error: Failed to create message from Firebase Message")
                        #endif
                        os_log("Invalid Data, Unable to create Message from Firebase Message due to invalid data. Hence not saving it in local db and the message will not be visible to user.", log: .firebase, type: .debug)
                        continue
                    }
                    //                    print(conversation)
                    messages.append(message)
                }
            }
            self.persistFirebaseMessagesInStore(entries: Array(messages.dropFirst()))
        }) { error in
            #if !RELEASE
            print("Value Single Event Observer Error: \(error)")
            #endif
            os_log("Firebase Single Event Observer Error while observing Messages: %@", log: .firebase, type: .error, error.localizedDescription)
        }
    }
    
    
    
    
    
   
    
    
    var shouldShowLoader = true {
        didSet {
            print("Should Show Loader = \(shouldShowLoader)")
        }
    }
    
    func reloadDataKeepingOffset() {
        let offset = self.messagesCollectionView.contentOffset.y + messagesCollectionView.adjustedContentInset.bottom
        let oldY = self.messagesCollectionView.contentSize.height - offset
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.layoutIfNeeded()
        let y = self.messagesCollectionView.contentSize.height - oldY
        let newOffset = CGPoint(x: 0, y: y)
        self.messagesCollectionView.contentOffset = newOffset
//        print("Old Offset: \(oldOffset) & New Offset: \(newOffset)")
//        guard let topVisibleMessage = messagesCollectionView.messagesDataSource?.messageForItem(at: messagesCollectionView.indexPathForItem(at: newOffset) ?? IndexPath(item: 0, section: 0), in: messagesCollectionView) as? UserMessage else { return }
        print("Old Offset: \(offset) | Old Y : \(oldY) | New Offset: \(newOffset)")
        if newOffset.y <= 0 {
            self.shouldShowLoader = false
            self.messagesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            self.messagesCollectionView.reloadSections([0])
            self.messagesCollectionView.layoutIfNeeded()
        } else {
            self.shouldShowLoader = true
        }
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let offsetTime = Calendar.current.date(byAdding: .second, value: 2, to: screenEntryTime)!
            if !isLoading && Date() > offsetTime {
                print("isLoading: \(isLoading)")
//                firstMessage = fetchedResults?.first
                guard let offsetMessage = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
                    return
                }
                self.fetchMoreMessages(offsetMessage: offsetMessage)
            }
        }
    }
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
    var shouldFetchMore = true {
        didSet {
            if shouldFetchMore == false {
                print("should stop spinner")
//                self.headerSpinnerView?.spinner.stopAnimating()
//                self.messagesCollectionView.reloadSections([0])
            }
        }
    }
    
    
    var firstMessage:UserMessage? {
        didSet {
            if oldValue == firstMessage {
                print("First item is same. should not load more.")
                self.shouldFetchMore = false
            }
        }
    }
    
    func fetchMoreMessages(offsetMessage:UserMessage) {
        if self.isLoading == false {
            self.isLoading = true
        }
        limit += 20
        fetchedResultsController.fetchRequest.fetchLimit = limit

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performFetch()
            self.reloadDataKeepingOffset()
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.3) {
                self.loadMoreMessagesFromFirebase(offsetMessage: offsetMessage)
            }
            self.isLoading = false
        }
        
        
        
        
        
//        let objectsAfter = self.fetchedResultsController.fetchedObjects
            
        /*
        DispatchQueue.main.async {
            self.messagesCollectionView.performBatchUpdates({
                if let objectsBefore = objectsBefore,
                    !objectsBefore.isEmpty {
                    objectsBefore.forEach({
                        if objectsAfter?.firstIndex(of: $0) == nil {
                            self.messagesCollectionView.deleteSections([objectsBefore.firstIndex(of: $0)!])
                        }
                    })
                }
                
                if let objectsAfter = objectsAfter,
                    !objectsAfter.isEmpty {
                    objectsAfter.forEach({
                        if objectsBefore?.firstIndex(of: $0) == nil {
                            self.messagesCollectionView.insertSections([objectsAfter.firstIndex(of: $0)!])
                        }
                    })
                }
            }, completion: { [weak self] finished in
                self?.messagesCollectionView.layoutIfNeeded()
            })
        }
        */
        
        
        /*
        let operation = BlockOperation { [weak self] in
            if let objectsBefore = objectsBefore,
                !objectsBefore.isEmpty {
                objectsBefore.forEach({
                    if objectsAfter?.firstIndex(of: $0) == nil {
                        self?.messagesCollectionView.deleteSections([objectsBefore.firstIndex(of: $0)!])
                    }
                })
            }
            
            if let objectsAfter = objectsAfter,
                !objectsAfter.isEmpty {
                objectsAfter.forEach({
                    if objectsBefore?.firstIndex(of: $0) == nil {
                        self?.messagesCollectionView.insertSections([objectsAfter.firstIndex(of: $0)!])
                    }
                })
            }
        }
        
        collectionViewOperations.append(operation)
        
        DispatchQueue.main.async {
            self.messagesCollectionView.performBatchUpdates({
                self.collectionViewOperations.forEach { $0.start() }
            }, completion: { [weak self] finished in
                self?.collectionViewOperations.removeAll(keepingCapacity: false)
            })
        }
        */
    }
    
    
    
    
    
    
    
    
    /*
    func fetchMoreMessages() {
        guard !isLoading else { return }
        isLoading = true
//        self.offset += 20
        self.limit += 20
        fetchedResultsController.fetchRequest.fetchLimit = self.limit
        do {
            NSFetchedResultsController<UserMessage>.deleteCache(withName: fetchedResultsController.cacheName)
            try fetchedResultsController.performFetch()
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.reloadDataKeepingOffset()
//                    let offset = self.messagesCollectionView.contentOffset.y - self.messagesCollectionView.adjustedContentInset.bottom
//                    self.shouldFetchMore = offset >= 100
                }
//                self.loadMoreMessagesFromFirebase()
                self.isLoading = false
            }
            
            /*
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2) {
                self.isLoading = false
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
            }
             */
            
        } catch {
            #if !RELEASE
            print("Error fetching results: \(error)")
            #endif
            os_log("Core Data Error: %@", log: .coredata, type: .error, error.localizedDescription)
        }
    }
    */
    
    
    func loadInitialMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchMessagesFromStore(count: self.limit) { messages in
                DispatchQueue.main.async {
//                    self.messages = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
    }
    
    func fetchMessagesFromStore(count:Int, completion: @escaping (([UserMessage]) -> Void)) {
        let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
        let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", customer)
        
        
        fetchRequest.predicate = conversationPredicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserMessage.date, ascending: false)
        ]
        fetchRequest.fetchLimit = count
        fetchRequest.returnsObjectsAsFaults = false
        
        
        viewContext.perform {
            do {
                let result = try fetchRequest.execute()
                print(result)
                completion(result)
            } catch let error {
                print(error)
            }
        }
    }
    
    
    var isLoading = false
    
    
    lazy var scrollToBottomButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(SFSymbol.downIndicator.image(withSymbolConfiguration: .init(textStyle: .title2)), for: .normal)
        button.tintColor = UIColor.telaYellow
        button.isEnabled = false
        return button
    }()
    lazy var newMessagesCountLabel:UILabel = {
        let label = InsetLabel(3.5, 3.5, 7, 7)
        label.text = "5"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        label.textColor = UIColor.black
        label.layer.cornerRadius = label.frame.height / 2
        label.clipsToBounds = true
        label.backgroundColor = UIColor.telaYellow.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    lazy var downIndicatorContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.telaGray5
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    lazy var singleTick:NSAttributedString = {
        let singleTickAttachment = NSTextAttachment()
        let singleTickImage = #imageLiteral(resourceName: "tick.single.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaGray6)
        singleTickAttachment.image = singleTickImage
        singleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: singleTickAttachment.image!.size.width, height: singleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: singleTickAttachment)
    }()
    lazy var grayDoubleTick:NSAttributedString = {
        let doubleTickAttachment = NSTextAttachment()
        let doubleTickImage = #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaGray6)
        doubleTickAttachment.image = doubleTickImage
        doubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: doubleTickAttachment.image!.size.width, height: doubleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: doubleTickAttachment)
    }()
    lazy var blueDoubleTick:NSAttributedString = {
        let blueDoubleTickAttachment = NSTextAttachment()
        let blueDoubleTickImage = #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaBlue)
        blueDoubleTickAttachment.image = blueDoubleTickImage
        blueDoubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: blueDoubleTickAttachment.image!.size.width, height: blueDoubleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: blueDoubleTickAttachment)
    }()

    var newMessagesCountLabelHeightConstraint:NSLayoutConstraint!
    var downIndicatorBottomConstraint:NSLayoutConstraint!
    var downIndicatorShouldShow:Bool = false {
        didSet {
            if downIndicatorShouldShow != oldValue {
                self.changeDownIndicatorState(show: downIndicatorShouldShow)
            }
        }
    }
    func changeDownIndicatorState(show:Bool, animated:Bool = true) {
        if show {
            UIView.animate(withDuration: 0.2) {
                self.downIndicatorContainerView.alpha = 1
            }
            self.scrollToBottomButton.isEnabled = true
        } else {
            UIView.animate(withDuration: 0.2) {
                self.downIndicatorContainerView.alpha = 0
            }
            self.scrollToBottomButton.isEnabled = false
        }
    }
    
    
    internal var indexPathForMessageBottomLabelToShow:IndexPath?
    
    func isLastSectionVisible() -> Bool {
        let count = messages.count
        guard count != 0 else { return false }
        let lastIndexPath = IndexPath(item: 0, section: count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section - 1].messageSender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section + 1].messageSender
    }
    
    func isNextMessageDateInSameDay(at indexPath:IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section + 1 < messages.count else { return false }
        return Calendar.current.isDate(messages[indexPath.section].sentDate, inSameDayAs: messages[indexPath.section + 1].sentDate)
    }
    /*
    func isPreviousMessageSenderSame(for message:UserMessage, at indexPath:IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        
        guard let messages = self.fetchedResults, !messages.isEmpty else { return false }
        let count = messages.count
        
        guard let index = messages.firstIndex(where: { $0 == message }) else { return false }
        let section = count - 1 - index
        
        return messages[section].messageSender == messages[section - 1].messageSender
    }
    
    func isNextMessageSenderSame(for message:UserMessage, at indexPath:IndexPath) -> Bool {
        
        guard let messages = self.fetchedResults, !messages.isEmpty else { return false }
        let count = messages.count
        
        guard indexPath.section + 1 < count else { return false }
        
        guard let index = messages.firstIndex(where: { $0 == message }) else { return false }
        let section = count - 1 - index
        
        return messages[section].messageSender == messages[section + 1].messageSender
    }
    */
    
    
//    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
//        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
//    }
    
    
    
    /*
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let messages = self.fetchedResults, !messages.isEmpty else { return false }
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section - 1].messageSender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let messages = self.fetchedResults, !messages.isEmpty else { return false }
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section + 1].messageSender
    }
    
    func isNextMessageDateInSameDay(at indexPath:IndexPath) -> Bool {
        guard let messages = self.fetchedResults, !messages.isEmpty else { return false }
        guard indexPath.section + 1 < messages.count else { return false }
        return Calendar.current.isDate(messages[indexPath.section].sentDate, inSameDayAs: messages[indexPath.section + 1].sentDate)
    }
    */
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
//        updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    
    
    func reloadMessages(messages:[UserMessage]) {
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            //            self?.messagesCollectionView.scrollToBottom(animated: true)
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    
    
    
    // MARK: - Inset Computation
    

    
    private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        // we only need to adjust for the part of the keyboard that covers (i.e. intersects) our collection view;
        // see https://developer.apple.com/videos/play/wwdc2017/242/ for more details
        let intersection = messagesCollectionView.frame.intersection(keyboardFrame)
        
        if intersection.isNull || intersection.maxY < messagesCollectionView.frame.maxY {
            // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
            // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
            return max(0, additionalBottomInset - automaticallyAddedBottomInset)
        } else {
            return max(0, intersection.height + additionalBottomInset - automaticallyAddedBottomInset)
        }
    }
    
    internal func requiredInitialScrollViewBottomInset() -> CGFloat {
        guard let inputAccessoryView = inputAccessoryView else { return 0 }
        return max(0, inputAccessoryView.frame.height + additionalBottomInset - automaticallyAddedBottomInset)
    }
    
    /// iOS 11's UIScrollView can automatically add safe area insets to its contentInset,
    /// which needs to be accounted for when setting the contentInset based on screen coordinates.
    ///
    /// - Returns: The distance automatically added to contentInset.bottom, if any.
    private var automaticallyAddedBottomInset: CGFloat {
        return messagesCollectionView.adjustedContentInset.bottom - messagesCollectionView.contentInset.bottom
    }
//    override func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
//
//    }
//    override func setTypingIndicatorViewHidden(_ isHidden: Bool, animated: Bool, whilePerforming updates: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
//
//    }
//    override var isTypingIndicatorHidden: Bool {
//        messagesCollectionView.isTypingIndicatorHidden
//    }
    
    
    
    
    
    
    
    
    
    
    
    
}




extension MessagesController {

}
