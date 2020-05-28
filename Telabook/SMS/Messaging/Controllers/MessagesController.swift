//
//  MessagesController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
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
    init(context:NSManagedObjectContext, customer:Customer) {
        self.viewContext =  context
        self.customer = customer
        self.node = .messages(companyID: AppData.companyId, node: customer.node!)
        self.reference = node.reference
        self.conversationID = Int(customer.externalConversationID)
        self.thisSender = .init(senderId: String(customer.agent?.workerID ?? 0), displayName: customer.agent?.personName ?? "")
        super.init(nibName: nil, bundle: nil)
        setupFetchedResultsController()
//        self.preLoadMessages(node: node)
//        self.preLoadChats(node: customer.node) { messages in
//
//        }
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
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    internal var fetchedResults:[UserMessage]? {
        return fetchedResultsController.fetchedObjects
    }
    internal var fetchedResultsCount:Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
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
    private var isFirstLayout: Bool = true
    internal var isMessagesControllerBeingDismissed: Bool = false
    
    
    internal var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.verticalScrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }
    

    
    
    //MARK: Lifecycle
    override func loadView() {
        super.loadView()
//        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .telaGray1
        setUpNavBar()
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
        if isFirstLayout {
            defer { isFirstLayout = false }
//            addKeyboardObservers()
            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
        }
//        if isFirstLayout {
//            defer { isFirstLayout = false }
////            addKeyboardObservers()
//            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
//        }
//        adjustScrollViewTopInset()
    }
    
    
    func loadMessages() {
        if !isFetchedResultsAvailable {
            self.startSpinner()
        }
        handle = reference.queryLimited(toLast: 50).observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                #if !RELEASE
                print("Snapshot Does not exists: returning")
                #endif
                return
            }
            var messages:[FirebaseMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    print(snapshot)
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
    
    
    
    func isLastSectionVisible() -> Bool {
        
        guard let messages = self.fetchedResultsController.fetchedObjects, !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let messages = self.fetchedResultsController.fetchedObjects, !messages.isEmpty else { return false }
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section - 1].messageSender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let messages = self.fetchedResultsController.fetchedObjects, !messages.isEmpty else { return false }
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
