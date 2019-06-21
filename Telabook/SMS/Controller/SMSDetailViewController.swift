//
//  SMSDetailViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
import MessageKit
import MessageInputBar
import Photos
import FirebaseStorage

class SMSDetailViewController: UIViewController {
    
    
    var messages:[Message] = []
    var messageInputBar = MessageInputBar()
    var messagesCollectionView = MessagesCollectionView()
    internal let internalConversation:InternalConversation
    internal let workerId:Int16
    init(conversation:InternalConversation) {
        self.internalConversation = conversation
        self.workerId = conversation.workerId
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "\(conversation.personName?.capitalized ?? "")"
        self.loadChats(node: conversation.internalNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var externalConversationsFRC: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: false)]
        fetchRequest.includesPendingChanges = false
       
        let workerIdPredicate = NSPredicate(format: "internal.workerId = %d", self.workerId)
        let archiveCheckPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value:false))
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workerIdPredicate, archiveCheckPredicate])
        fetchRequest.predicate = andPredicate
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceService.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    lazy var archivedConversationsFRC: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: false)]
        let workerIdPredicate = NSPredicate(format: "internal.workerId = %d", self.workerId)
        let archiveCheckPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value:true))
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workerIdPredicate, archiveCheckPredicate])
        fetchRequest.predicate = andPredicate
//        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.NSAndPredicateType, subpredicates: []
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceService.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        print("Archived FRC => \(frc)")
        frc.delegate = self
        return frc
    }()
//    lazy var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = {
//        return self.externalConversationsFRC
//    }()
    lazy var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = { return self.externalConversationsFRC }()
    
    
    
    
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
        setupTableView()
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        loadMockMessages()
        isMessagesControllerBeingDismissed = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupNavBarItems()
        setupDefaults()
        addMenuControllerObservers()
        addObservers()
        setupDelegates()
//        messagesCollectionView.isHidden = true
//        messageInputBar.isHidden = true
//        fetchedResultsController = externalConversationsFRC
//        self.preFetchData(isArchived: false)
//        self.fetchDataFromAPI(isArchive: false)
//        segmentedControl.selectedSegmentIndex = 0
//        updateTableContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController = externalConversationsFRC
        self.preFetchData(isArchived: false)
        let count = self.fetchedResultsController.sections?.first?.numberOfObjects
        if count == 0 {
            self.startSpinner()
        }
        self.startNetworkSpinner()
        
        self.fetchDataFromAPI(isArchive: false)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func setupDelegates() {
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
    }
    fileprivate func setupNavBarItems() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonTapped))
//        let editButton = UIBarButtonItem(image: #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(editButtonTapped))
//        editButton.imageInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        navigationItem.rightBarButtonItems = [addButton]
    }
    @objc func addButtonTapped() {
        let newContactVC = NewContactViewController()
        newContactVC.modalPresentationStyle = .overFullScreen
        newContactVC.view.backgroundColor = .telaGray1
        newContactVC.delegate = self
        self.present(newContactVC, animated: true, completion: nil)
    }
    @objc func editButtonTapped() {
        
    }
 
    
    func configureMessageCollectionView() {
        messagesCollectionView.isHidden = true
        messagesCollectionView.backgroundColor = UIColor.telaGray1
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        //        messagesCollectionView.messageCellDelegate = self
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 0)))
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    func configureMessageInputBar() {
        messageInputBar.isHidden = true
        messageInputBar.delegate = self
        //        messageInputBar.inputTextView.tintColor = .telaWhite
        messageInputBar.inputTextView.textColor = .telaWhite
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "autoresponse_icon"), for: .normal)
        
        messageInputBar.sendButton.title = nil
        //        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = UIColor.telaGray1
        messageInputBar.contentView.backgroundColor = UIColor.telaGray1
        messageInputBar.inputTextView.backgroundColor = UIColor.telaGray5
        messageInputBar.inputTextView.keyboardAppearance = UIKeyboardAppearance.dark
        messageInputBar.inputTextView.layer.borderWidth = 0
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 36)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        let cameraItem = InputBarButtonItem(type: .custom) // 1
        //        cameraItem.tintColor = .blue
        cameraItem.image = #imageLiteral(resourceName: "camera_icon")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed), // 2
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false) // 3
        //        messageInputBar.sendButton.setTitleColor(.telaGreen, for: .normal)
        //        messageInputBar.sendButton.setTitleColor(
        //            UIColor.telaGreen.withAlphaComponent(0.3),
        //            for: .highlighted
        //        )
    }
    @objc private func cameraButtonPressed() {
        promptPhotosPickerMenu()
    }
    private func handleSourceTypeCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.modalPresentationStyle = .overFullScreen
        present(picker, animated: true, completion: nil)
    }
    private func handleSourceTypeGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .overFullScreen
        present(picker, animated: true, completion: nil)
    }
    internal func promptPhotosPickerMenu() {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleSourceTypeCamera()
        })
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleSourceTypeGallery()
        })
       
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        
        alert.view.tintColor = UIColor.telaBlue
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alert.view.subviews.first?.backgroundColor = .clear
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
//                    item.isEnabled = !self.isSendingPhoto
                    
                }
            }
        }
    }
    fileprivate var storageUploadTask:StorageUploadTask!
    private func uploadImage(_ image: UIImage, callback: @escaping (URL?) -> Void) {
     
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            callback(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        
        let imageName = [UUID().uuidString, String(Int(Date().timeIntervalSince1970)*1000)].joined(separator: "-") + ".jpg"
        let ref = Config.StorageConfig.messageImageRef.child(imageName)
        
   
        storageUploadTask = ref.putData(data, metadata: metadata, completion: { (meta, error) in
            guard error == nil else {
                print("Error uploading: \(error!)")
                callback(nil)
                return
            }
            ref.downloadURL(completion: { (url, err) in
                guard let downloadUrl = url else {
                    if let err = err {
                        print("Error: Unable to get download url => \(err.localizedDescription)")
                    }
                    callback(nil)
                    return
                }
                callback(downloadUrl)
            })
        })
        
    }
    
    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        
        uploadImage(image) { [weak self] url in
            guard let `self` = self else {
                return
            }
            self.isSendingPhoto = false
            
            guard let url = url else {
                return
            }
            self.handleSendingMessageSequence(message: url.absoluteString, type: .MMS)
        }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
    
    
    
    
    
    
    // MARK: - Helpers
    func insert(_ message:Message) {
        self.messages.append(message)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    func insertMessage(_ message: Message) {
        messages.append(message)
        print(messages)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            self?.messagesCollectionView.scrollToBottom(animated: true)
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
        
    }
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    
    
    func loadChats(node:String?) {
        messages = []
        let companyId = UserDefaults.standard.getCompanyId()
        if let node = node {
            let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node).queryLimited(toLast: 50)
            
            query.observe(.childAdded, with: { [weak self] snapshot in
                let messageId = snapshot.key
                if let data = snapshot.value as? [String: Any] {
                    
                    
                    if let text = data["message"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
    //                    let senderNumber = data["sender_number"] as? String,
    //                    let isSenderWorker = data["sender_is_worker"] as? Int,
    //                    let type = data["type"] as? String,
                        let date = data["date"] as? Double {
                        let message = Message(text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date)))
                        self?.insertMessage(message)
                    } else if let imageUrl = data["img"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        //                    let senderNumber = data["sender_number"] as? String,
                        //                    let isSenderWorker = data["sender_is_worker"] as? Int,
                        //                    let type = data["type"] as? String,
                        let date = data["date"] as? Double {
                        guard let url = URL(string: imageUrl) else {
                            print("Unable to construct URL from imageURL => \(imageUrl)")
                            return
                        }
                        self?.downloadImage(at: url) { [weak self] image in
                            guard let `self` = self else {
                                return
                            }
                            guard let image = image else {
                                return
                            }
                            let message = Message(image: image, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date)))
                            self.insertMessage(message)
                        }
                    }
                }
            })
        }
    }
    
     func loadMockMessages() {
        messages = []
        let mockUser = Sender(id: "99", displayName: "Arya Stark")
        let message = Message(text: "Valar Morghulis!", sender: currentSender(), messageId: UUID().uuidString, date: Date())
//        self.insert(message)
         self.insertMessage(message)
        
            let replyMessage = Message(text: "Valar Dohaeris!", sender: mockUser, messageId: UUID().uuidString, date: Date())
//            self.insert(replyMessage)
            self.insertMessage(replyMessage)
            
        
    }
    
    
    fileprivate func setupViews() {
        view.addSubview(spinner)
        view.addSubview(segmentedControl)
        view.addSubview(messagesCollectionView)
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        view.addSubview(tryAgainButton)
    }
    fileprivate func setupConstraints() {
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        messagesCollectionView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        tableView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20).isActive = true
        tryAgainButton.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 20).isActive = true
        tryAgainButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    fileprivate func startSpinner() {
        OverlaySpinner.shared.spinner(mark: .Start)
    }
    fileprivate func stopSpinner() {
        OverlaySpinner.shared.spinner(mark: .Stop)
    }
    fileprivate func startNetworkSpinner() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    fileprivate func stopNetworkSpinner() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Being dismissed")
        
        isMessagesControllerBeingDismissed = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        messages.removeAll()
//        messagesCollectionView.reloadData()
        isMessagesControllerBeingDismissed = false
    }
    override func viewDidLayoutSubviews() {
        // Hack to prevent animation of the contentInset after viewDidAppear
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
        }
        adjustScrollViewTopInset()
    }
    
    // MARK: - Initializers
    
    deinit {
        removeKeyboardObservers()
        removeMenuControllerObservers()
        removeObservers()
        clearMemoryCache()
    }
    var scrollsToBottomOnKeyboardBeginsEditing: Bool = false
    var maintainPositionOnKeyboardFrameChanged: Bool = false
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override var inputAccessoryView: UIView? {
        return messageInputBar
    }

    override var shouldAutorotate: Bool {
        return false
    }
    var additionalBottomInset: CGFloat = 0 {
        didSet {
            let delta = additionalBottomInset - oldValue
            messageCollectionViewBottomInset += delta
        }
    }
    private var isFirstLayout: Bool = true
    internal var isMessagesControllerBeingDismissed: Bool = false
    
    internal var selectedIndexPathForMenu: IndexPath?
    
    internal var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }
    // MARK: - Methods [Private]
    
    private func setupDefaults() {
        extendedLayoutIncludesOpaqueBars = true
        UIScrollView().contentInsetAdjustmentBehavior = .never

        messagesCollectionView.keyboardDismissMode = .interactive
        messagesCollectionView.alwaysBounceVertical = true
    }
    // MARK: - Helpers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(clearMemoryCache), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc private func clearMemoryCache() {
//        MessageStyle.bubbleImageCache.removeAllObjects()
    }
    
    
    fileprivate func setupTableView() {
        tableView.register(SMSDetailCell.self, forCellReuseIdentifier: NSStringFromClass(SMSDetailCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
 
    @objc func handleTryAgainAction() {
        self.setPlaceholdersViewsState(isHidden: true)
        self.setViewsState(isHidden: true)
        self.startSpinner()
//        self.fetchUserData()
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.tryAgainButton.isHidden = isHidden
    }
    fileprivate func setViewsState(isHidden: Bool) {
        self.tableView.isHidden = isHidden
    }
    
    lazy var spinner:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
        //        indicator.backgroundColor = .black
        return indicator
    }()
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    let placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Turn on Mobile Data or Wifi to Access Telabook"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    let tryAgainButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TRY AGAIN", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        button.addTarget(self, action: #selector(handleTryAgainAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    let segmentedControl:UISegmentedControl = {
        let options = ["Inbox", "Direct Message", "Archived"]
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
            ]
        let unselectedAttributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaGray7
        ]
        let control = UISegmentedControl(items: options)
        control.selectedSegmentIndex = 0
        control.tintColor = .clear
        control.setTitleTextAttributes(attributes, for: UIControl.State.selected)
        control.setTitleTextAttributes(unselectedAttributes, for: UIControl.State.normal)
        control.backgroundColor = .telaGray3
        control.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        return control
    }()
    
    @objc fileprivate func segmentDidChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: handleSegmentControls(for: .Inbox)
        case 1: handleSegmentControls(for: .DirectMessage)
        case 2: handleSegmentControls(for: .Archived)
        default: fatalError("Invalid Segment")
        }
    }
    private enum SegmentType {
        case Inbox
        case DirectMessage
        case Archived
    }
    private func handleSegmentControls(for type:SegmentType) {
        switch type {
        case .Inbox:
            messageInputBar.inputTextView.resignFirstResponder()
            messagesCollectionView.isHidden = true
            messageInputBar.isHidden = true
            tableView.isHidden = false
            self.fetchedResultsController = self.externalConversationsFRC
            self.preFetchData(isArchived: false)
            self.fetchDataFromAPI(isArchive: false)
        case .DirectMessage:
            tableView.isHidden = true
            messagesCollectionView.isHidden = false
            messageInputBar.isHidden = false
        case .Archived:
            messageInputBar.inputTextView.resignFirstResponder()
            messagesCollectionView.isHidden = true
            messageInputBar.isHidden = true
            tableView.isHidden = false
            self.fetchedResultsController = self.archivedConversationsFRC
            self.preFetchData(isArchived: true)
            self.fetchDataFromAPI(isArchive: true)
        }
    }
    fileprivate func updateTableContent() {
//        self.preFetchData()
        self.fetchDataFromAPI(isArchive: false)
    }
    fileprivate func preFetchData(isArchived:Bool) {
        do {
            try self.fetchedResultsController.performFetch()
//            tableView.reloadDataWithLayout()
            tableView.reloadData()
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    
    fileprivate func fetchDataFromAPI(isArchive:Bool) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.stopSpinner()
                    self.stopNetworkSpinner()
                    UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    self.fetchExternalConversations(token: token, isArchived: isArchive)
                }
            }
        }
    }
    
    
    fileprivate func fetchExternalConversations(token:String, isArchived:Bool) {
        let companyId = UserDefaults.standard.getCompanyId()
        
        print("Worker ID => \(String(self.workerId))")
        ExternalConversationsAPI.shared.fetch(token: token, companyId: String(companyId), workerId: String(workerId), isArchived: isArchived) { (responseStatus, data, serviceError, error) in
            if let err = error {
                print("***Error Fetching Conversations****\n\(err.localizedDescription)")
                DispatchQueue.main.async {
                    self.stopSpinner()
                    self.stopNetworkSpinner()
                    self.showAlert(title: "Error", message: err.localizedDescription)
                }
            } else if let serviceErr = serviceError {
                print("***Error Fetching Conversations****\n\(serviceErr.localizedDescription)")
                DispatchQueue.main.async {
                    self.stopSpinner()
                    self.stopNetworkSpinner()
                    self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
//                            self.stopSpinner()
                            self.stopSpinner()
                            self.stopNetworkSpinner()
                            print("***No Content****\nResponse Status => \(status)")
//                            self.setViewsState(isHidden: true)
//                            self.setPlaceholdersViewsState(isHidden: false)
                            self.placeholderLabel.text = "No Archived Conversations"
                        }
                    } else {
                        print("***Invalid Response****\nResponse Status => \(status)")
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            self.stopNetworkSpinner()
                            self.showAlert(title: "Error", message: "Unable to fetch conversations. Please try again.")
                        }
                    }
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
//                        self.clearConversationData()
                        self.stopSpinner()
                        self.stopNetworkSpinner()
                        self.saveToCoreData(data: data, isArchived: isArchived)
                    }
                }
            }
        }
    }
    /*
    func saveToCoreData(data: Data, isArchived:Bool) {
        guard let context = CodingUserInfoKey.context else {
            fatalError("Failed to retrieve managed object context")
        }
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let decoder = JSONDecoder()
        decoder.userInfo[context] = managedObjectContext
        do {
            let response = try decoder.decode([ExternalConversation].self, from: data)
            if !isArchived {
                response.forEach({$0.internal = self.internalConversation})
                try managedObjectContext.save()
            } else {
                response.forEach({
                    $0.internal = self.internalConversation
                    $0.isArchived = true
                })
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: true)]
                fetchRequest.includesPendingChanges = false
                
                let workerIdPredicate = NSPredicate(format: "internal.workerId = %d", self.internalConversation!.workerId)
                let archiveCheckPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value:false))
                let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workerIdPredicate, archiveCheckPredicate])
                fetchRequest.predicate = andPredicate
                var res = try managedObjectContext.fetch(fetchRequest) as? [ExternalConversation]
                
                res?.append(contentsOf: response)
                try managedObjectContext.save()
            }
        } catch let error {
            print("Error Processing Response Data: \(error)")
            DispatchQueue.main.async {
                
            }
        }
    }
    */
    
    func clearConversationData() {
        do {
            
            let context = PersistenceService.shared.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
            fetchRequest.predicate = NSPredicate(format: "internal.workerId = %d", self.workerId)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                PersistenceService.shared.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    func clearStorage() {
        let isInMemoryStore = PersistenceService.shared.persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }
        
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            print("External Convos In Memory Store")
            do {
                let items = try managedObjectContext.fetch(fetchRequest)
                for item in items {
                    managedObjectContext.delete(item as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            print("External Convos Not In Memory Store")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
                PersistenceService.shared.saveContext()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    func showAlert(title:String, message:String) {
        let alertVC = UIAlertController.telaAlertController(title: title, message: message)
        alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

extension SMSDetailViewController : MessagesDataSource {
    func currentSender() -> Sender {
        return UserDefaults.standard.currentSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func isEarliest(_ message:Message) -> Bool {
        let filteredMessages = self.messages.filter{( Date.isDateSame(date1: message.sentDate, date2: $0.sentDate) )}
        return message == filteredMessages.min() ? true : false
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isEarliest(message as! Message) {
            let date = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.chatHeaderDate)
            return NSAttributedString(
                string: date,
                attributes: [
                    .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)!,
                    .foregroundColor: UIColor.telaGray7
                ]
            )
        }
        return nil
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let time = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.hmma)
        return NSAttributedString(
            string: time,
            attributes: [
                .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)!,
                .foregroundColor: UIColor.telaGray6
            ]
        )
    }
}
extension SMSDetailViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .telaBlue : .telaLightYellow
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .telaWhite : .telaBlack
    }
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    //    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    //        avatarView.image = nil
    //        avatarView.frame = .zero
    //        avatarView.setCorner(radius: .zero)
    //    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    //    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    //        return CGSize.zero
    //    }
    
}
extension SMSDetailViewController: MessagesLayoutDelegate {
    
    
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isEarliest(message as! Message) ? 30.0 : 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    
}
extension SMSDetailViewController : MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        //        messageInputBar.inputTextView.text = String()
        //        messageInputBar.invalidatePlugins()
        // Send button activity animation
        //        inputBar.sendButton.isEnabled = false
        inputBar.inputTextView.text = ""
        //        self.messagesCollectionView.scrollToBottom(animated: true)
        //        self.messageInputBar.sendButton.isEnabled = true
        //        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            
            DispatchQueue.main.async { [weak self] in
                //                self?.messageInputBar.inputTextView.placeholder = "New Message"
                self?.insertMessages(components)
                
            }
        }
    }
    private func insertMessages(_ data: [Any]) {
        //        let sender = UserDefaults.standard.currentSender
        for component in data {
            if let str = component as? String {
                DispatchQueue.main.async {
//                    self.insertMessage(Message(text: str, sender: UserDefaults.standard.currentSender, messageId: UUID().uuidString, date: Date()))
                    
                    self.handleSendingMessageSequence(message: str, type: .SMS)
                }
            } else if let _ = component as? UIImage {
                
                //                self.handleSendingMessageSequence(message: , type: .MMS)
            }
        }
    }
    
    fileprivate func handleSendingMessageSequence(message:String, type:ChatMessageType) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let token = token {
                let id = self.internalConversation.internalConversationId
                print("Internal Conversation ID => \(id)")
                guard id != 0 else {
                    print("Error: Internal Convo ID => 0")
                    self.messageInputBar.sendButton.isEnabled = true
                    return
                }
                DispatchQueue.main.async {
                    self.sendMessage(token: token, conversationId: String(id), message: message, type: type)
                }
                
            }
        }
    }
    
    
 private func sendMessage(token:String, conversationId:String, message:String, type:ChatMessageType) {
    ExternalConversationsAPI.shared.sendMessage(token: token, conversationId: conversationId, message: message, type: type, isDirectMessage: true) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    print("***Error Sending Message****\n\(err.localizedDescription)")
                    self.showAlert(title: "Error", message: err.localizedDescription)
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    print("***Error Sending Message****\n\(serviceErr.localizedDescription)")
                    self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error Sending Message****\nInvalid Response: \(status)")
                        self.showAlert(title: "\(status)", message: "Unable to send Message. Please try again")
                        self.messageInputBar.sendButton.isEnabled = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    print("Message sent: \(message)")
                    //                    self.messageInputBar.inputTextView.text = ""
                    //                    self.messagesCollectionView.scrollToBottom(animated: true)
                    //                    self.messageInputBar.sendButton.isEnabled = true
                }
                if let data = data {
                    print("Data length => \(data.count)")
                    print("Data => \(data)")
                }
            }
        }
    }
}
extension UIImagePickerController {
    open override var childForStatusBarHidden: UIViewController? {
        return nil
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension SMSDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let asset = info[.phAsset] as? PHAsset { // 1
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
                sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}




extension SMSDetailViewController: NewConversationDelegate {
    func startConversation(dismiss vc: UIViewController, result newConversation: NewConversationCodable) {
        DispatchQueue.global(qos: .background).async {
            self.fetchDataFromAPI(isArchive: false)
        }

        vc.dismiss(animated: true, completion: {
            if let id = newConversation.externalConversationId,
                id != 0,
                let node = newConversation.node {
                let chatVC = ChatViewController(conversationId: String(id), node: node)
                chatVC.title = newConversation.recipientPerson?.isEmpty ?? true ? newConversation.recipientNumber : newConversation.recipientPerson
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            }
        })
        
    }
    
    
}
