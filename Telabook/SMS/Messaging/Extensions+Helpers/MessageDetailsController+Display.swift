//
//  MessageDetailsController+Display.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit

extension MessageDetailsViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
            case .custom, .emoji:
                return .clear
            default:
                return isFromCurrentSender(message: message) ? .telaBlue : .tertiarySystemBackground
        }
        
    }
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
            case .hashtag, .mention:
                if isFromCurrentSender(message: message) {
                    return [.foregroundColor: UIColor.white]
                } else {
                    return [.foregroundColor: UIColor.lightGray]
            }
            case .url, .phoneNumber:
                return [
                    .foregroundColor: UIColor.link,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.link
            ]
            case .date:
                return isFromCurrentSender(message: message) ? [
                    .foregroundColor: UIColor.systemGray2,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.systemGray2 ] : [
                        .foregroundColor: UIColor.tertiaryLabel,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: UIColor.tertiaryLabel ]
            default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber, .mention]
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return isFromCurrentSender(message: message) ? .bubbleTail(.bottomRight, .curved) : .bubbleTail(.bottomLeft, .curved)
    }
    
    func messageFooterView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let view = messagesCollectionView.dequeueReusableFooterView(MessageReusableView.self, for: indexPath)
        view.addSubview(tableView)
        tableView.fillSuperview()
        return view
    }
}
