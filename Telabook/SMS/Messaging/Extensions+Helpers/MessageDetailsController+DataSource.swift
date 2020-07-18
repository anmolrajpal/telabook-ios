//
//  MessageDetailsController+DataSource.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit

extension MessageDetailsViewController: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        let sections = collectionView.messagesDataSource?.numberOfSections(in: collectionView) ?? 0
        return collectionView.isTypingIndicatorHidden ? sections : sections + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        return collectionView.messagesDataSource?.numberOfItems(inSection: section, in: collectionView) ?? 0
    }

    /// Notes:
    /// - If you override this method, remember to call MessagesDataSource's customCell(for:at:in:)
    /// for MessageKind.custom messages, if necessary.
    ///
    /// - If you are using the typing indicator you will need to ensure that the section is not
    /// reserved for it with `isSectionReservedForTypingIndicator` defined in
    /// `MessagesCollectionViewFlowLayout`
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }

        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }


        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(MMSMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            cell.imageView.image = (message as! UserMessage).getImage()
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .audio:
            let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .contact:
            let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return displayDelegate.messageHeaderView(for: indexPath, in: messagesCollectionView)
        case UICollectionView.elementKindSectionFooter:
            return displayDelegate.messageFooterView(for: indexPath, in: messagesCollectionView)
        default:
            fatalError(MessageKitError.unrecognizedSectionKind)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
        return messagesFlowLayout.sizeForItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        
        return layoutDelegate.headerViewSize(for: section, in: messagesCollectionView)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TypingIndicatorCell else { return }
        cell.typingBubble.startAnimating()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        
        return layoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
    }
}


extension MessageDetailsViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return thisSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.chatHeaderDate)
        return NSAttributedString(string: date, attributes: [
            .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)!,
            .foregroundColor: UIColor.telaGray7
            ]
        )
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let message = message as! UserMessage
        
        let time = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.hmma)
        
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
}
