//
//  MessageDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import AVFoundation

protocol MessageDetailsControllerDelegate: AnyObject {
    func deleteMessage(message: UserMessage, controller:MessageDetailsViewController)
}

class MessageDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate:MessageDetailsControllerDelegate?
    let synthesizer = AVSpeechSynthesizer()
    var dataSource:DataSource! = nil
    
    
    // MARK: - init
    
    let message:UserMessage
    let thisSender:MessageSender
    
    init(message: UserMessage, currentSender:MessageSender) {
        self.message = message
        self.thisSender = currentSender
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        synthesizer.stopSpeaking(at: .immediate)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        message.shouldRevealDeletedMessage = false
    }
    deinit {
        synthesizer.stopSpeaking(at: .immediate)
        message.shouldRevealDeletedMessage = false
    }
    
    
    /// - Tag:  Intial Setup
    private func commonInit() {
        view.backgroundColor = UIColor.telaGray1
        title = "Message Info"
        configureNavigationBarAppearance()
        configureHierarchy()
        configureMessagesCollectionView()
        configureTableView()
        configureDataSource()
        if AppData.getUserRole() == .Developer {
            message.shouldRevealDeletedMessage = true
        }
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.reloadSections([0])
        }, completion: { [weak self] _ in
          self?.messagesCollectionView.scrollToLastItem(animated: true)
        })
    }
    
    
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var messagesCollectionView = MessagesCollectionView()
    
    lazy var tableView:UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = UIColor.telaGray4
        view.allowsSelection = false
        view.bounces = false
        view.alwaysBounceVertical = false
        view.tableFooterView = UIView()
        return view
    }()
    lazy var singleTick:NSAttributedString = {
        let singleTickAttachment = NSTextAttachment()
        singleTickAttachment.image = singleTickImage()
        singleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: singleTickAttachment.image!.size.width, height: singleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: singleTickAttachment)
    }()
    lazy var grayDoubleTick:NSAttributedString = {
        let doubleTickAttachment = NSTextAttachment()
        doubleTickAttachment.image = grayDoubleTickImage()
        doubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: doubleTickAttachment.image!.size.width, height: doubleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: doubleTickAttachment)
    }()
    lazy var blueDoubleTick:NSAttributedString = {
        let blueDoubleTickAttachment = NSTextAttachment()
        blueDoubleTickAttachment.image = blueDoubleTickImage()
        blueDoubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: blueDoubleTickAttachment.image!.size.width, height: blueDoubleTickAttachment.image!.size.height)
        return NSAttributedString(attachment: blueDoubleTickAttachment)
    }()
    
    func singleTickImage(size: CGSize = .init(width: 15, height: 15)) -> UIImage {
        return #imageLiteral(resourceName: "tick.single.glyph").image(scaledTo: size)!.withTintColor(.telaGray6)
    }
    func grayDoubleTickImage(size: CGSize = .init(width: 15, height: 15)) -> UIImage {
        return #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: size)!.withTintColor(.telaGray6)
    }
    func blueDoubleTickImage(size: CGSize = .init(width: 15, height: 15)) -> UIImage {
        return #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: size)!.withTintColor(.telaBlue)
    }
    
    
    /// - Tag: Setup Views
    private func configureHierarchy() {
        view.addSubview(messagesCollectionView)
        layoutConstraints()
    }
    private func layoutConstraints() {
//        messagesCollectionView.fillSuperview()
        let guide = view.safeAreaLayoutGuide
        messagesCollectionView.anchor(top: guide.topAnchor, left: guide.leftAnchor, bottom: guide.bottomAnchor, right: guide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    
    
    
    
    // MARK: - Methods
    
    private func configureMessagesCollectionView() {
        messagesCollectionView.dataSource = self
        messagesCollectionView.delegate = self
        
        messagesCollectionView.collectionViewLayout = CustomMessagesCollectionViewFlowLayout()
        messagesCollectionView.register(MMSMessageCell.self)
        messagesCollectionView.register(MessageReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        
//        messagesCollectionView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.4)
        
//        messagesCollectionView.bounces = false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        
        
        let layout = messagesCollectionView.collectionViewLayout as? CustomMessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)))
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}
