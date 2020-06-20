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
    
    
    // MARK: - init
    
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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    
    
    
    // MARK: - Properties
    
    let synthesizer = AVSpeechSynthesizer()
    internal var storageUploadTask:StorageUploadTask!
    internal var fetchedResultsController: NSFetchedResultsController<UserMessage>!
    internal var indexPathForMessageBottomLabelToShow:IndexPath?
    var isLoading = false
    var limit: Int = 20
    var offset:Int = 0
    var didSentNewMessage = false
    
    var collectionViewOperations: [BlockOperation] = []
    
    var isFirstLayout: Bool = true
    internal var isMessagesControllerBeingDismissed: Bool = false
    
    var newMessagesCountLabelHeightConstraint:NSLayoutConstraint!
    var downIndicatorBottomConstraint:NSLayoutConstraint!
    var downIndicatorShouldShow:Bool = false {
        didSet {
            if downIndicatorShouldShow != oldValue {
                self.changeDownIndicatorState(show: downIndicatorShouldShow)
            }
        }
    }
    
    var shouldShowLoader = true {
        didSet {
            //            print("Should Show Loader = \(shouldShowLoader)")
        }
    }
    var shouldFetchMore = true {
        didSet {
            if shouldFetchMore == false {
                DispatchQueue.main.async {
                    guard self.messagesCollectionView.numberOfSections > 0 else { return }
                    self.messagesCollectionView.reloadSections([0])
                }
                print("should not fetch more")
                //                self.headerSpinnerView?.spinner.stopAnimating()
                //                self.messagesCollectionView.reloadSections([0])
            }
        }
    }
    
    var messages:[UserMessage] = [] {
        didSet {
            if !messages.isEmpty {
                self.stopSpinner()
            }
        }
    }
    
    
    var mediaMessages:[UserMessage] {
        messages.filter({ $0.messageType == .multimedia && $0.imageLocalURL() != nil })
    }
    
    
//    var mediaMessages:[URL] {
//        var contents = [URL]()
//        do {
//            contents = try FileManager.default.contentsOfDirectory(at: customer.mediaFolder(), includingPropertiesForKeys: nil)
//        } catch {
//            printAndLog(message: error.localizedDescription, log: .ui, logType: .error)
//        }
//        return contents
//    }
    
    
    
//    var messages:[UserMessage] {
//        fetchedResultsController.fetchedObjects?.reversed() ?? []
//    }
    
    
    
    let serialQueue = DispatchQueue(label: "conversation-media-download-queue")
    
    let uploadService = UploadService()
    let downloadService = DownloadService()
    
    lazy var downloadSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier:
        "com.telabook.web.downloadSession")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    lazy var uploadSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier:
        "com.telabook.web.uploadSession")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    
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
    

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        uploadService.uploadsSession = uploadSession
        downloadService.downloadsSession = downloadSession
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopObservingReachability()
        removeFirebaseObservers()
        markAllMessagesAsSeen()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.becomeFirstResponder()
        observeReachability()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFirebaseObservers()
    }
    
    private func addFirebaseObservers() {
        childAddedHandle = observeNewMessages()
        childUpdatedHandle = observeExistingMessages()
    }
    private func removeFirebaseObservers() {
        if childAddedHandle != nil { reference.removeObserver(withHandle: childAddedHandle) }
        if childUpdatedHandle != nil { reference.removeObserver(withHandle: childUpdatedHandle) }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! UserMessage
        if case .photo = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(MMSCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView, upload: uploadService.activeUploads[message.imageURL!], download: downloadService.activeDownloads[message.imageURL!])
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }


    
    
    //MARK: - Override
    
    // MARK: Implementation may be faulty as the top key from core data is the proper key but there may be possible loss where app is unable to create conversation from Firebase and save it to core data. and hence, at first load, new entries from firebase get appends in core data. Thus, offset difference is there and some firebase entries won't be overwritten when updated.
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard messages.count > 2 else { return }
//        if indexPath.section == 0 {
//            let offsetTime = Calendar.current.date(byAdding: .second, value: 2, to: screenEntryTime)!
//            if !isLoading && Date() > offsetTime {
//                print("isLoading: \(isLoading)")
////                firstMessage = fetchedResults?.first
//
//                self.loadMoreMessages(offsetMessage: messages[0])
////                self.fetchMoreMessages(offsetMessage: messages[0])
//            }
//        }
//    }
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

    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.section == 0 {
//            let offsetTime = Calendar.current.date(byAdding: .second, value: 2, to: screenEntryTime)!
//            if !isLoading && Date() > offsetTime {
//                print("isLoading: \(isLoading)")
//                //                firstMessage = fetchedResults?.first
//                self.loadMoreMessages(offsetMessage: messages[0])
//                //                self.fetchMoreMessages(offsetMessage: messages[0])
//            }
//        }
//        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
////        cell.layer.shouldRasterize = true
////        cell.layer.rasterizationScale = UIScreen.main.scale
//        return cell
//    }
    
    
    
    
    
    
    // MARK: - Views
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
    lazy var mediaTextView:UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.isEditable = false
        textView.textAlignment = .left
        textView.isSelectable = false
        textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        textView.textColor = UIColor.telaWhite
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 7, bottom: 6, right: 7)
        return textView
    }()
    
    

    
}
