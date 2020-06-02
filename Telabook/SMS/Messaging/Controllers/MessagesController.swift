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
//        setupFetchedResultsController()
        
//        self.performInitialFetch()
        
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
    
    
    var limit: Int = 25
    
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
    
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    internal var fetchedResults:[UserMessage]? {
        return fetchedResultsController.fetchedObjects?.reversed()
    }
    internal var fetchedResultsCount:Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
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
        setupFetchedResultsController()
        commonInit()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reference.removeObserver(withHandle: handle)
        stopObservingReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = customer.addressBookName?.isEmpty ?? true ? customer.phoneNumber : customer.addressBookName
        observeReachability()
        loadMessages()
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
    func loadMessages() {
        if !isFetchedResultsAvailable {
            self.startSpinner()
        }
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
    
    
    func loadMoreMessagesFromFirebase() {
        print("Sequence Calling")
        guard let offsetMessage = fetchedResults?.first else {
            return
        }
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
    
    
    
    
    
    func preLoadChats(node:String?, completion: @escaping ([Message]) -> Void) {
           var preLoadedMessages:[Message] = []
           let companyId = AppData.companyId
           if let node = node {
               let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node)
               query.observe(.childAdded, with: { snapshot in
                   let messageId = snapshot.key
                   if let data = snapshot.value as? [String: Any] {
                       if let imageUrl = data["img"] as? String,
                           let text = data["message"] as? String,
                           let senderId = data["sender"] as? Int,
                           let senderName = data["sender_name"] as? String,
                           let date = data["date"] as? Double {
                           guard let url = URL(string: imageUrl) else {
                               print("Unable to construct URL from imageURL => \(imageUrl)")
                               return
                           }
                           print("Image Message with text => \(text)")
                           let message = Message(imageUrl: url, text: text, sender: Sender(senderId: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                           preLoadedMessages.append(message)
                       } else if let imageUrl = data["img"] as? String,
                           let senderId = data["sender"] as? Int,
                           let senderName = data["sender_name"] as? String,
                           let date = data["date"] as? Double {
                           guard let url = URL(string: imageUrl) else {
                               print("Unable to construct URL from imageURL => \(imageUrl)")
                               return
                           }
                           let message = Message(imageUrl: url, sender: Sender(senderId: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                           preLoadedMessages.append(message)
                       } else if let text = data["message"] as? String,
                           let senderId = data["sender"] as? Int,
                           let senderName = data["sender_name"] as? String,
                           let date = data["date"] as? Double {
                           let message = Message(text: text, sender: Sender(senderId: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                           preLoadedMessages.append(message)
                       } else {
                           print("Unknown Scenario : ")
                           print(data)
                       }
                   }
                   DispatchQueue.main.async {
                       completion(preLoadedMessages)
                   }
               }) { (error) in
                   print("Error retrieving observer: \(error.localizedDescription)")
               }
           }
       }
    
    
    
    
    func reloadDataKeepingOffset() {
        let oldOffset = self.messagesCollectionView.contentSize.height - self.messagesCollectionView.contentOffset.y
        messagesCollectionView.reloadData()
//        UIView.animate(withDuration: 0.1) {
            self.messagesCollectionView.layoutIfNeeded()
//        }
        messagesCollectionView.contentOffset = CGPoint(x: 0, y: messagesCollectionView.contentSize.height - oldOffset)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.section < 10 {
//            print("Should call loader")
//        }
    }
    var shouldFetchMore = true {
        didSet {
            if shouldFetchMore == false {
                print("should stop spinner")
//                self.headerSpinnerView?.spinner.stopAnimating()
//                self.messagesCollectionView.reloadSections([0])
            }
        }
    }
    func fetchMoreMessages() {
        guard !isLoading else { return }
        isLoading = true
//        self.offset += 20
        self.limit += 25
        fetchedResultsController.fetchRequest.fetchLimit = self.limit
        do {
            NSFetchedResultsController<UserMessage>.deleteCache(withName: fetchedResultsController.cacheName)
            try fetchedResultsController.performFetch()
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.reloadDataKeepingOffset()
                    let offset = self.messagesCollectionView.contentOffset.y - self.messagesCollectionView.adjustedContentInset.bottom
                    self.shouldFetchMore = offset >= 100
                }
                self.loadMoreMessagesFromFirebase()
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
        let doubleTickImage = #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaBlue)
        doubleTickAttachment.image = doubleTickImage
        doubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: doubleTickAttachment.image!.size.width, height: doubleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: doubleTickAttachment)
    }()
    lazy var blueDoubleTick:NSAttributedString = {
        let blueDoubleTickAttachment = NSTextAttachment()
        let blueDoubleTickImage = #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaGray6)
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
        let count = fetchedResultsCount
        guard count != 0 else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
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
