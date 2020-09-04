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
import Network


public enum BackgroundIdentifier {
    case messageDownload, messageUpload
    
    var rawValue:String {
        let bundleID:String = try! Configuration.value(for: .bundleID)
        switch self {
            case .messageDownload: return "\(bundleID).messagesDownloadSession"
            case .messageUpload: return "\(bundleID).messagesUploadSession"
        }
    }
}
extension URLSessionConfiguration {
    static func background(withIdentifier identifier: BackgroundIdentifier) -> URLSessionConfiguration {
        return URLSessionConfiguration.background(withIdentifier: identifier.rawValue)
    }
}


class MessagesController: MessagesViewController {
    
    // MARK: - init
    var messageToForward:UserMessage?
    let click2CallManager = Click2CallManager.shared
    let mediaManager = MessageMediaManager.shared
    let downloadService:DownloadService
    let uploadService:UploadService
    let screenEntryTime = Date()
    var handle:UInt!
    var childUpdatedHandle:UInt!
    var childAddedHandle:UInt!
    let customer:Customer
    let node:Config.FirebaseConfig.Node
    let conversationID:Int
    let viewContext:NSManagedObjectContext = PersistentContainer.shared.viewContext
    var thisSender:MessageSender
    let reference:DatabaseReference
    let conversationReference:DatabaseReference
    
    
    init(customer: Customer) {
        self.customer = customer
        let conversationsNode: Config.FirebaseConfig.Node = .conversations(companyID: AppData.companyId, workerID: Int(customer.agent?.workerID ?? 0))
        self.conversationReference = conversationsNode.reference
        self.node = .messages(companyID: AppData.companyId, node: customer.node!)
        self.reference = node.reference
        self.conversationID = Int(customer.externalConversationID)
        self.thisSender = .init(senderId: String(customer.agent?.workerID ?? 0), displayName: customer.agent?.personName ?? "")
        self.downloadService = self.mediaManager.downloadService
        self.uploadService = self.mediaManager.uploadService
        super.init(nibName: nil, bundle: nil)
        self.mediaManager.delegate = self
//        setupFetchedResultsController()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        synthesizer.stopSpeaking(at: .immediate)
        print("\(self) : Deinitialized")
    }
    
    
    var isClick2CallOperationActive: Bool {
        return click2CallManager.isOperationActive(for: conversationID)
    }
    
    
    
    // MARK: - Properties
    
    var monitor: NWPathMonitor?
    
    let synthesizer = AVSpeechSynthesizer()
    
    let serialQueue = DispatchQueue(label: "media-loader-queue")
    
    let asyncFetcher = AsyncMMSFetcher()
    
    let autoDownloadImageMessagesState = AppData.autoDownloadImageMessagesState
    
    var shouldAutoDownloadImageMessages = false
    
    var storageUploadTask:StorageUploadTask!
    
    var indexPathForMessageBottomLabelToShow:IndexPath?
    
    var isLoading = false
    
    var limit: Int = 20
    
    var offset:Int = 0
    
    var unseenFetchLimit = 50
    
    var unseenFetchOffset = 0
    
    var didSentNewMessage = false
    
    var collectionViewOperations: [BlockOperation] = []
    
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
        messages.filter({ $0.messageType == .multimedia && $0.getImage() != nil })
    }
    
    
    
    
   // MARK: - Constructors


    
    //MARK: - Lifecycle
    

    override func viewDidLoad() {
//        super.messagesCollectionView = CustomMessagesCollectionView()
//        super.messagesCollectionView.collectionViewLayout = CustomMessagesCollectionViewFlowLayout()
        super.viewDidLoad()
        commonInit()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markAllMessagesAsSeen()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopMonitoringNetwork()
//        stopObservingReachability()
        removeFirebaseObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.becomeFirstResponder()
        configureNavigationBarItems()
        monitorNetwork()
//        observeReachability()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFirebaseObservers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        asyncFetcher.clearAllCache()
    }
    
    
    
    // MARK: - Methods
    
    private func addFirebaseObservers() {
        childAddedHandle = observeNewMessages()
        childUpdatedHandle = observeExistingMessages()
    }
    private func removeFirebaseObservers() {
        if childAddedHandle != nil { reference.removeObserver(withHandle: childAddedHandle) }
        if childUpdatedHandle != nil { reference.removeObserver(withHandle: childUpdatedHandle) }
    }
    private func monitorNetwork() {
        monitor = NWPathMonitor()
        
        let monitorQueue = DispatchQueue(label: "network-monitor")
        monitor?.start(queue: monitorQueue)
        
        monitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            switch self.autoDownloadImageMessagesState {
                case .never:
                    self.shouldAutoDownloadImageMessages = false
                case .wifi:
                    self.shouldAutoDownloadImageMessages = path.usesInterfaceType(.wifi)
                case .wifiPlusCellular:
                    self.shouldAutoDownloadImageMessages = path.status == .satisfied
            }
        }
        
    }
    private func stopMonitoringNetwork() {
        monitor?.cancel()
        monitor = nil
    }
    
    func downsample(imageAt imageURL: URL?, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        guard let imageURL = imageURL else { return nil }
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return nil }
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage)
    }
    
    
    // MARK: - Overriden methods
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! UserMessage
        

        switch message.kind {
            case .photo, .video:
                let cell = messagesCollectionView.dequeueReusableCell(MultimediaMessageCell.self, for: indexPath)
                cell.cellDelegate = self
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                if let sourceURL = message.imageLocalURL() {
                    if let fetchedImage = asyncFetcher.fetchedImage(for: sourceURL) {
                        cell.imageView.image = fetchedImage
                    } else {
                        cell.imageView.image = nil
                        
                        asyncFetcher.fetchAsync(sourceURL) { image in
                            DispatchQueue.main.async {
                                cell.imageView.image = image
                            }
                        }
                    }
                }
//                cell.layoutIfNeeded()
//                let imageViewSize = cell.imageView.bounds.size
//                let scale = collectionView.traitCollection.displayScale
//
//                serialQueue.async {
//                    let image = self.downsample(imageAt: message.imageLocalURL(), to: imageViewSize, scale: scale)
//                    DispatchQueue.main.async {
//                        cell.imageView.image = image
//                    }
//                }
                return cell
            default:
                return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        /*
        if case .photo = message.kind, case .video = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(MMSCell.self, for: indexPath)
            cell.cellDelegate = self
            cell.configure(with: message, at: indexPath, and: messagesCollectionView, upload: uploadService.activeUploads[message.imageURL!], download: downloadService.activeDownloads[message.imageURL!], shouldAutoDownload: shouldAutoDownloadImageMessages)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
        */
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? CustomMessagesCollectionViewFlowLayout else { return .zero }
        return messagesFlowLayout.sizeForItem(at: indexPath)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? CustomMessagesCollectionViewFlowLayout else {
            fatalError()
        }

        let indexPath = IndexPath(item: 0, section: section)
        let dataSource = layout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! UserMessage
        if isFromCurrentSender(message: message) {
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
                return layout.rightTailInsets
            } else {
                return layout.rightNormalInsets
            }
        } else {
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
                return layout.leftTailInsets
            } else {
                return layout.leftNormalInsets
            }
        }
    }
     
    
    /*
     
    // MARK: - Can Be used to play more with section insets
     
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? CustomMessagesCollectionViewFlowLayout else { return .zero }
        let dataSource = layout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! UserMessage

        
        let leftNormalHorizontalInset = layout.leftNormalInsets.horizontal
        let leftTailHorizontalInset = layout.leftTailInsets.horizontal
        let rightNormalHorizontalInset = layout.rightNormalInsets.horizontal
        let rightTailHorizontalInset = layout.rightTailInsets.horizontal
        
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let horizontalContentInset = contentInset.horizontal
        
        var size = layout.sizeForItem(at: indexPath)
        let inset:CGFloat
        
        if isFromCurrentSender(message: message) {
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
                inset = rightTailHorizontalInset + horizontalContentInset
            } else {
                inset = rightNormalHorizontalInset + horizontalContentInset
            }
        } else {
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
                inset = leftTailHorizontalInset + horizontalContentInset
            } else {
                inset = leftNormalHorizontalInset + horizontalContentInset
            }
        }
        
//        size.width += inset
        return size
//        return CGSize(width: collectionViewWidth - inset, height: size.height)
    }
     */
    
    
    
    
    // MARK: - Views
    
    var headerSpinnerView:SpinnerReusableView?
    var phoneBarButtonItem: UIBarButtonItem = {
        let phoneButtonImage = SFSymbol.phone·fill.image
        let phoneButton = UIBarButtonItem(image: phoneButtonImage, style: .plain, target: self, action: #selector(phoneButtonDidTapped(_:)))
        phoneButton.tintColor = UIColor.telaBlue
        return phoneButton
    }()
    lazy var phoneSpinnerBarButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(customView: phoneSpinner)
        barButton.isEnabled = false
        return barButton
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    
    var phoneSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .medium)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaBlue
        aiView.clipsToBounds = true
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
        let label = UILabel()
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



open class CustomMessagesCollectionView: MessagesCollectionView {
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero, collectionViewLayout: CustomMessagesCollectionViewFlowLayout())
    }
    public convenience init() {
        self.init(frame: .zero, collectionViewLayout: CustomMessagesCollectionViewFlowLayout())
    }
}
