//
//  SMSDetailVC+CollectionView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import MessageKit
internal enum MessageKitError {
    internal static let avatarPositionUnresolved = "AvatarPosition Horizontal.natural needs to be resolved."
    internal static let nilMessagesDataSource = "MessagesDataSource has not been set."
    internal static let nilMessagesDisplayDelegate = "MessagesDisplayDelegate has not been set."
    internal static let nilMessagesLayoutDelegate = "MessagesLayoutDelegate has not been set."
    internal static let notMessagesCollectionView = "The collectionView is not a MessagesCollectionView."
    internal static let layoutUsedOnForeignType = "MessagesCollectionViewFlowLayout is being used on a foreign type."
    internal static let unrecognizedSectionKind = "Received unrecognized element kind:"
    internal static let unrecognizedCheckingResult = "Received an unrecognized NSTextCheckingResult.CheckingType"
    internal static let couldNotLoadAssetsBundle = "MessageKit: Could not load the assets bundle"
    internal static let couldNotCreateAssetsPath = "MessageKit: Could not create path to the assets bundle."
    internal static let customDataUnresolvedCell = "Did not return a cell for MessageKind.custom(Any)."
    internal static let customDataUnresolvedSize = "Did not return a size for MessageKind.custom(Any)."
}
extension SMSDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        return collectionView.messagesDataSource?.numberOfSections(in: collectionView) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        return collectionView.messagesDataSource?.numberOfItems(inSection: section, in: collectionView) ?? 0
    }
    
    /// Note:
    ///   If you override this method, remember to call MessagesDataSource's customCell(for:at:in:) for MessageKind.custom messages, if necessary
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
            let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        return layoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text, .attributedText, .emoji, .photo:
            selectedIndexPathForMenu = indexPath
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return (action == NSSelectorFromString("copy:"))
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        let pasteBoard = UIPasteboard.general
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text(let text), .emoji(let text):
            pasteBoard.string = text
        case .attributedText(let attributedText):
            pasteBoard.string = attributedText.string
        case .photo(let mediaItem):
            pasteBoard.image = mediaItem.image ?? mediaItem.placeholderImage
        default:
            break
        }
    }
    
    
}
