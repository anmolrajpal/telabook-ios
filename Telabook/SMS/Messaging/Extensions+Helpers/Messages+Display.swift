//
//  Messages+Display.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import PINRemoteImage
extension MessagesController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .photo:
            return UIColor.telaGray7.withAlphaComponent(0.4)
        case .custom:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? .telaBlue : .telaGray7
        }
        
    }
//    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
////        guard let message = message as? UserMessage else { return }
////        if message.isMessageDeleted { return .black }
//        return .telaWhite
//    }
    
//    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
//        return indexPath.section == 3
//    }
    
    
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.lightGray]
            }
            case .date:
                return isFromCurrentSender(message: message) ? [
                    .foregroundColor: UIColor.telaGray7,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.telaGray7 ] : [
                        .foregroundColor: UIColor.telaGray5,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: UIColor.telaGray5 ]
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//        return .bubbleTail(corner, .curved)
        
//        var corners: UIRectCorner = []
        
        
        
        
//        if isFromCurrentSender(message: message) {
//            if !isNextMessageSenderSame(for: message as! UserMessage, at: indexPath) {
//                return .bubbleTail(.bottomRight, .curved)
//            } else {
//                return .bubble
//            }
//        } else {
//            if !isNextMessageSenderSame(for: message as! UserMessage, at: indexPath) {
//                return .bubbleTail(.bottomLeft, .curved)
//            } else {
//                return .bubble
//            }
//        }
        
        
        
        
        
        
        if isFromCurrentSender(message: message) {
            if !isNextMessageSameSender(at: indexPath) {
                return .bubbleTail(.bottomRight, .curved)
            } else {
                return .bubble
            }
        } else {
            if !isNextMessageSameSender(at: indexPath) {
                return .bubbleTail(.bottomLeft, .curved)
            } else {
                return .bubble
            }
        }
        
        
        
        
        
    
        
        /*
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
 */
//        return .custom { view in
//            let radius: CGFloat = 16
//            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            view.layer.mask = mask
//        }
        
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        
        guard let message = message as? UserMessage,
            isFromCurrentSender(message: message) else { return }
        
        if !message.errorSending || !message.hasError { return }
        
        print("Should show error button")
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(SFSymbol.errorSendingBadge.image(withSymbolConfiguration: .init(textStyle: .title3)), for: .normal)
        button.tintColor = .systemRed
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let msg = message as? UserMessage,
            let url = msg.imageURL else { return }
        if let text = msg.textMessage,
            !text.isBlank {
            #if !RELEASE
            print("Image Text for image with URL: \(url) is => \(text)")
            #endif            
            let textView = UITextView(frame: CGRect.zero)
            textView.text = text
            textView.isEditable = false
            textView.textAlignment = .left
            textView.isSelectable = false
            textView.backgroundColor = isFromCurrentSender(message: message) ? .telaBlue : .telaGray7
            textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
            textView.textColor = UIColor.telaWhite
            textView.sizeToFit()
            textView.isScrollEnabled = false
            textView.textContainerInset = UIEdgeInsets(top: 6, left: 7, bottom: 6, right: 7)
//            textView.clipsToBounds = false
            /*
            textView.layer.shadowColor = UIColor.gray.cgColor
            textView.layer.shadowRadius = 5
            textView.layer.shadowOpacity = 1
            textView.layer.shadowOffset = .zero
            textView.layer.shadowPath = UIBezierPath(rect: textView.bounds).cgPath
            textView.layer.masksToBounds = false
             */
            imageView.addSubview(textView)
            textView.anchor(top: nil, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        }
//        imageView.loadImageUsingCache(with: url.absoluteString)
        imageView.pin_updateWithProgress = true
        imageView.pin_setImage(from: url) { result in
            // should save image to file directory
        }
    }
}

