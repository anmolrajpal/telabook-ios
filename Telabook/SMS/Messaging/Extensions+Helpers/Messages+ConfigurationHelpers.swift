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
        messagesCollectionView.backgroundColor = .telaGray1
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.scrollToBottom(animated: false)
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 0)))
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
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
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        
//        guard let fetchedMessages = fetchedResultsController.fetchedObjects else {
//            print("No Fetched Messages")
//            return nil
//        }
       guard let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
            print("Failed to identify message when audio cell receive tap gesture")
            return nil
        }
        
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
        guard let messages = self.fetchedResultsController.fetchedObjects else { return nil }
        let totalMessages = messages.count
        guard let index = messages.firstIndex(where: { $0.firebaseKey == identifier }) else { return nil }
        let section = totalMessages - 1 - index
        
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
}

