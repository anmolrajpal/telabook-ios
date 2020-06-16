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
        self.thisSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        let messages = self.fetchedResults ?? []
        
//        messages.sort(by: { $0.sentDate < $1.sentDate })
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int { messages.count }
    
    func isEarliest(_ message:UserMessage) -> Bool {
//        guard let messages = self.fetchedResults else { return false }
        let filteredMessages = messages.filter{( Date.isDateSame(date1: message.sentDate, date2: $0.sentDate) )}
        return message == filteredMessages.min() ? true : false
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageDateInSameDay(at: indexPath) {
            let date = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.chatHeaderDate)
            return NSAttributedString(string: date, attributes: [
                .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)!,
                .foregroundColor: UIColor.telaGray7
                ]
            )
        }
        /*
        if isEarliest(message as! UserMessage) {
            let date = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.chatHeaderDate)
            return NSAttributedString(
                string: date,
                attributes: [
                    .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)!,
                    .foregroundColor: UIColor.telaGray7
                ]
            )
        }
 */
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
        
        
        guard let message = message as? UserMessage else {
            #if !RELEASE
            print("Unresolved Error: Failed to cast Message Type as UserMessage")
            #endif
            return nil
        }
        
        let time = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.hmma)
        
        /*
        let singleTickAttachment = NSTextAttachment()
        let singleTickImage = #imageLiteral(resourceName: "tick.single.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaGray6)
        singleTickAttachment.image = singleTickImage
        singleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: singleTickAttachment.image!.size.width, height: singleTickAttachment.image!.size.height)
        let singleTick = NSAttributedString(attachment: singleTickAttachment)
        
        let doubleTickAttachment = NSTextAttachment()
        let doubleTickImage = #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaBlue)
        doubleTickAttachment.image = doubleTickImage
        doubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: doubleTickAttachment.image!.size.width, height: doubleTickAttachment.image!.size.height)
        let doubleTick = NSAttributedString(attachment: doubleTickAttachment)
        
        let blueDoubleTickAttachment = NSTextAttachment()
        let blueDoubleTickImage = #imageLiteral(resourceName: "tick.double.glyph").image(scaledTo: .init(width: 15, height: 15))!.withTintColor(.telaGray6)
        blueDoubleTickAttachment.image = blueDoubleTickImage
        blueDoubleTickAttachment.bounds = CGRect(x: 0, y: -4.0, width: blueDoubleTickAttachment.image!.size.width, height: blueDoubleTickAttachment.image!.size.height)
        let blueDoubleTick = NSAttributedString(attachment: blueDoubleTickAttachment)
        */
        
        let attributedText = NSMutableAttributedString(string: "")
        let prefix = NSAttributedString(
            string: time + " ",
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
open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    open lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    
    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        // Append any of your custom `MessageSizeCalculator` if you wish for the convenience
        // functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
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
