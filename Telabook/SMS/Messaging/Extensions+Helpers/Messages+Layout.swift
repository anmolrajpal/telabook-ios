//
//  Messages+Layout.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit


extension MessagesController: MessagesLayoutDelegate {
    
   

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard !(message as! UserMessage).isFault else { return 0 }
        return isEarliest(message as! UserMessage) ? 30.0 : 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        if downIndicatorBottomConstraint != nil { downIndicatorBottomConstraint.constant = -messagesCollectionView.adjustedContentInset.bottom }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard !(message as! UserMessage).isFault else { return 0 }
        if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
            return 20
        } else {
            if let indexPathToShow = indexPathForMessageBottomLabelToShow, indexPathToShow == indexPath {
                return 20
            } else {
                return 0
            }
        }
//        return (!isNextMessageSameSender(at: indexPath)) ? 20 : 0
    }

    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        section == 0 ? .init(width: messagesCollectionView.frame.width, height: SpinnerReusableView.viewHeight) : .zero
    }
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        section == 10 ? .init(width: messagesCollectionView.frame.width, height: NewMessagesCountReusableView.viewHeight) : .zero
    }
    
    
    /*
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + 20) : 0
        }
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath)) ? 16 : 0
    }
    */
}
