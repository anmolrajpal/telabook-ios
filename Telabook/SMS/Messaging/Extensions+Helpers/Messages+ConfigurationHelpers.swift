//
//  Messages+ConfigurationHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVFoundation
import os
extension MessagesController {
    internal func configureMessageCollectionView() {
        messagesCollectionView.register(BotMessageCell.self)
        messagesCollectionView.register(SpinnerReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        messagesCollectionView.register(NewMessagesCountReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        messagesCollectionView.backgroundColor = .telaGray1
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.scrollToBottom(animated: false)
        messagesCollectionView.delegate = self
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        
        
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)))
        
//        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 7, left: 26, bottom: 7, right: 16))
//        layout?.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 26))
        
        
        
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        
        
        scrollsToBottomOnKeyboardBeginsEditing = false
        maintainPositionOnKeyboardFrameChanged = true
    }
    func shouldCacheLayoutAttributes(for message: MessageType) -> Bool {
        return true
    }
    
    
    
    /*
     
     // Use: layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8) while configuring messagesCollectionView.
     
    // MARK: - Overriding super collection view because MessageKit framework has not provided delegates for this
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let indexPath = IndexPath(item: 0, section: section)
        let message = messageForItem(at: indexPath, in: collectionView as! MessagesCollectionView)
        if isFromCurrentSender(message: message) {
            if !isNextMessageSameSender(at: indexPath) {
                return UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 16)
            } else {
                return UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 26)
            }
        } else {
            if !isNextMessageSameSender(at: indexPath) {
                return UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 8)
            } else {
                return UIEdgeInsets(top: 1, left: 26, bottom: 1, right: 8)
            }
        }
    }
    */
    
    
    
    internal func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.shouldManageSendButtonEnabledState = false
        messageInputBar.inputTextView.textColor = .telaWhite
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "autoresponse_icon"), for: .normal)
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.isEnabled = true
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
        
        let cameraItem = InputBarButtonItem(type: .custom)
        cameraItem.image = #imageLiteral(resourceName: "camera_icon")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonDidTap),
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        
//        guard let fetchedMessages = fetchedResultsController.fetchedObjects else {
//            print("No Fetched Messages")
//            return nil
//        }
       guard let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
            print("Failed to identify message when audio cell receive tap gesture")
            return nil
        }
        guard !message.isMessageDeleted else { return nil }
        if case .custom = message.kind { return nil }
        let identifier = "\(message.firebaseKey!)" as NSString
        
       
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            var menuItems = [UIMenuElement]()
            
            
            let copyAction = UIAction(title: "Copy", image: SFSymbol.copy.image) { _ in
                UIPasteboard.general.string = message.textMessage
            }
            
            
            let detailsAction = UIAction(title: "Details", image: SFSymbol.info.image) { _ in
                
            }
            let forwardAction = UIAction(title: "Forward", image: SFSymbol.forward.image) { _ in
                
            }
            let replyAction = UIAction(title: "Reply", image: SFSymbol.reply.image) { _ in
                
            }
            let speakAction = UIAction(title: "Speak", image: SFSymbol.speak.image) { _ in
                if let text = message.textMessage {
                    let utterance = AVSpeechUtterance(string: text)
//                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
                }
            }
            let setTagsAction = UIAction(title: "Add Tags", image: SFSymbol.tag.image) { _ in
                
            }
            let deleteAction = UIAction(title: "Delete", image: SFSymbol.delete.image, attributes: .destructive) { _ in
//                self.deleteConversation(for: customer, completion: {_ in})
            }
            
            
            message.textMessage != nil ? menuItems.append(copyAction) : ()
            if case .photo(let item) = message.kind {
                let imageItem = item as! ImageItem
                if let image = imageItem.image {
                    let saveToCameraRollAction = UIAction(title: "Save Image", image: SFSymbol.download.image) { _ in
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                    menuItems.append(saveToCameraRollAction)
                }
            }
            menuItems.append(replyAction)
            menuItems.append(forwardAction)
            menuItems.append(setTagsAction)
            menuItems.append(detailsAction)
            menuItems.append(speakAction)
            menuItems.append(deleteAction)
            return UIMenu(title: "", children: menuItems)
        }
    }
        func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
            makeTargetedPreview(for: configuration)
        }
        func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
            makeTargetedPreview(for: configuration)
        }
//        func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//
//        }
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else { return nil }
        guard let messages = self.fetchedResults else { return nil }
//        let totalMessages = messages.count
        guard let section = messages.firstIndex(where: { $0.firebaseKey == identifier }) else { return nil }
//        guard let index = messages.firstIndex(where: { $0.firebaseKey == identifier }) else { return nil }
//        let section = fetchedResultsCount - 1 - index // This was used when results are fetched from sqlite ordered by date: descending
        
        //MARK: Execution Time Calculation
        /*
        let indexTime = CFAbsoluteTimeGetCurrent()
        let totalMessages = messages.count
        guard let firstIndex = messages.firstIndex(where: { $0.firebaseKey == identifier }) else { return nil }
        print("Section => \(totalMessages - 1 - firstIndex)")
        let indexDiff = CFAbsoluteTimeGetCurrent() - indexTime
        print("Execution time for getting Index Section by simple calculation: \(indexDiff)")
        
        
        let revStart = CFAbsoluteTimeGetCurrent()
        messages.reverse()
        guard let reversedIndex = messages.firstIndex(where: { $0.firebaseKey == identifier }) else { return nil }
        print("Section => \(reversedIndex)")
        let revDiff = CFAbsoluteTimeGetCurrent() - revStart
        print("Execution Time for getting Index Section After reversing the Array => \(revDiff)")

        print("The faster is : \(revDiff >= indexDiff ? "Simple Method" : "Reversing Array Method")")
        */
        
        let indexPath = IndexPath(item: 0, section: section)
        guard let cell = messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell else {
            let errorMessage = "Unresolved Error While making Target View for Context Menu: Unable to cast collectionViewCell as MessageContentCell"
            #if !RELEASE
            print(errorMessage)
            #endif
            os_log("%@", log: .ui, type: .error, errorMessage)
            return nil
        }

//        let visiblePath = UIBezierPath(roundedRect: cell.contentView.bounds, cornerRadius: 80)
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
//        parameters.visiblePath = visiblePath
        return UITargetedPreview(view: cell.messageContainerView, parameters: parameters)
    }
    
    
    
    
    
    
    
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        if downIndicatorBottomConstraint != nil { downIndicatorBottomConstraint.constant = -messagesCollectionView.adjustedContentInset.bottom }
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total = self.messagesCollectionView.contentSize.height - self.messagesCollectionView.frame.height
        let offset = self.messagesCollectionView.contentOffset.y - messagesCollectionView.adjustedContentInset.bottom
        if total > 700 {
            self.downIndicatorShouldShow = (total - offset) > 300 /* minimum distance */
        }
//        print("Total: \(total) & offset: \(offset) :Difference=> \(total - offset)")
        let now = Date()
        let offsetTime = Calendar.current.date(byAdding: .second, value: 2, to: screenEntryTime)!
        if offset < 100 && !isLoading && shouldFetchMore && now > offsetTime {
            self.fetchMoreMessages()
//            if let message = fetchedResults?.first {
//                loadMoreMessagesFromFirebase(offsetMessage: message)
//            }
        }
    }
   
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let total = self.messagesCollectionView.contentSize.height - self.messagesCollectionView.frame.height
//        let offset = self.messagesCollectionView.contentOffset.y - messagesCollectionView.adjustedContentInset.bottom
//        if offset < total * 0.2 {
//            print("Now")
//        }

    }
}

