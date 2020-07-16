//
//  Messages+DataSource.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit

extension MessagesController: MessagesDataSource {
    func currentSender() -> SenderType {
        return self.thisSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let message = message as! UserMessage
        if !isPreviousMessageDateInSameDay(at: indexPath) {
            guard let date = message.date else { return nil }
            let formattedDate = Date.getStringFromDate(date: date, dateFormat: CustomDateFormat.chatHeaderDate)
            return NSAttributedString(string: formattedDate, attributes: [
                .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)!,
                .foregroundColor: UIColor.telaGray7
                ]
            )
        }
        return nil
    }
    
    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        let cell = messagesCollectionView.dequeueReusableCell(BotMessageCell.self, for: indexPath)
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        return cell

    }
    
    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        CustomMessageSizeCalculator(layout: messagesCollectionView.messagesCollectionViewFlowLayout)
    }
    
    
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        let message = message as! UserMessage
        guard let time = message.date else { return nil }
        let formattedTime = Date.getStringFromDate(date: time, dateFormat: CustomDateFormat.hmma)
        
        let attributedText = NSMutableAttributedString(string: "")
        let prefix = NSAttributedString(
            string: formattedTime + " ",
            attributes: [
                .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)!,
                .foregroundColor: UIColor.telaGray6
            ]
        )
        
        attributedText.append(prefix)
        if isFromCurrentSender(message: message) {
            switch true {
                case message.deliveredByProviderAt != nil: attributedText.append(blueDoubleTick)
                case message.sentByProviderAt != nil: attributedText.append(grayDoubleTick)
                case message.sentByApiAt != nil: attributedText.append(singleTick)
                default: break
            }
        }
        
        return attributedText
    }
    
    
    
    func messageFooterView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let view = messagesCollectionView.dequeueReusableFooterView(NewMessagesCountReusableView.self, for: indexPath)
        view.count = 4
        return view
    }
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let view = messagesCollectionView.dequeueReusableHeaderView(SpinnerReusableView.self, for: indexPath)
//        view.spinner.startAnimating()
//        headerSpinnerView = view
        return view
    }
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        if elementKind == UICollectionView.elementKindSectionHeader && shouldShowLoader {
//            headerSpinnerView?.spinner.startAnimating()
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
//        if elementKind == UICollectionView.elementKindSectionHeader || !shouldShowLoader{
//            headerSpinnerView?.spinner.stopAnimating()
//        }
//    }
}
class SpinnerReusableView:MessageReusableView {
    static let viewHeight = CGFloat(60)
    
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .medium)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        spinner.startAnimating()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        spinner.stopAnimating()
    }
    override class var requiresConstraintBasedLayout: Bool { true }
}

class NewMessagesCountReusableView:MessageReusableView {
    static let viewHeight = CGFloat(60)
    
    var count:Int? {
        didSet {
            if let count = count {
                countLabel.text = "\(count) NEW MESSAGES"
            } else {
                countLabel.text = nil
            }
        }
    }
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
        label.textColor = .telaGray7
        label.backgroundColor = UIColor.telaGray3.withAlphaComponent(0.5)
        label.textAlignment = .center
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countLabel)
        countLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 30)
        countLabel.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool { true }
}
open class CustomMessagesCollectionViewFlowLayout: MessagesCollectionViewFlowLayout {
    public var leftNormalInsets = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 0)
    public var leftTailInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    public var rightNormalInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 10)
    public var rightTailInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    
    
    
    lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    lazy var photoItemMessageSizeCalculator = PhotoMessageSizeCalculator(layout: self)
    lazy var videoItemMessageSizeCalculator = PhotoMessageSizeCalculator(layout: self)

    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
            case .photo: return photoItemMessageSizeCalculator
            case .video: return videoItemMessageSizeCalculator
            case .custom: return customMessageSizeCalculator
            default: return super.cellSizeCalculatorForItem(at: indexPath)
        }
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        // Append any of your custom `MessageSizeCalculator` if you wish for the convenience
        // functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
        superCalculators.append(photoItemMessageSizeCalculator)
        superCalculators.append(videoItemMessageSizeCalculator)
        superCalculators.append(customMessageSizeCalculator)
        return superCalculators
    }
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }
    
    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else { return .zero }
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
        return CGSize(width: collectionViewWidth - inset, height: 44)
    }
  
}


open class PhotoMessageSizeCalculator: MessageSizeCalculator {
    
    
    public var incomingMessageLabelInsets = UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 14)
    public var outgoingMessageLabelInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 18)

    public var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    
    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        
        
        let sizeForMediaItem = { (maxWidth: CGFloat, item: ImageItem) -> CGSize in
            
            if maxWidth < item.size.width {
                // Maintain the ratio if width is too great
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        }
        
        switch message.kind {
        case .photo(let item as ImageItem):
            attributedText = NSAttributedString(string: item.imageText ?? "", attributes: [.font: messageLabelFont])
            messageContainerSize = sizeForMediaItem(maxWidth, item)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        if !attributedText.string.isEmpty {
            let messageLabelSize = labelSize(for: attributedText, considering: messageContainerSize.width)
            messageContainerSize.height += messageLabelSize.height
            
//            let messageInsets = messageLabelInsets(for: message)
//            messageContainerSize.width += messageInsets.left + messageInsets.right
//            messageContainerSize.height += messageInsets.top + messageInsets.bottom
        }
        return messageContainerSize
    }
    
    
    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont

        switch message.kind {
        case .photo(let mediaItem as ImageItem):
            guard let text = mediaItem.attributedText, !text.string.isEmpty else { return }
            guard let font = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return }
            attributes.messageLabelFont = font
        default: break
        }
    }
    
    internal func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }
}
