//
//  UserMessage+MessageType.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import MessageKit


struct MessageSender: SenderType, Equatable {
    let senderId: String
    let displayName: String
    init(senderId:String, displayName:String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}

extension UserMessage: MessageType {
    public var sender: SenderType { self.messageSender }
    
    public var messageId: String { self.firebaseKey! }
    
    public var sentDate: Date { self.date! }
    
    public var kind: MessageKind { self.messageKind() }
    
    var worker:MessageSender {
        let workerName = self.conversation?.agent?.personName ?? ""
        let workerID = String(self.conversation?.agent?.workerID ?? 0)
        let worker = MessageSender(senderId: workerID, displayName: workerName)
        return worker
    }
    var customer:MessageSender {
        let customerName = self.conversation?.addressBookName ?? ""
        let customerID = String(self.conversation?.customerID ?? 0)
        let customer = MessageSender(senderId: customerID, displayName: customerName)
        return customer
    }
    var messageSender: MessageSender {
        return self.isSentByWorker ? worker : customer
    }
    private func deletedMessageText() -> String {
        return isSentByWorker ? " You deleted this message." : " This Message was deleted."
    }
    private func deletedMessageAttributedText() -> NSAttributedString {
        let message = deletedMessageText()
        let attachment = NSTextAttachment()
        let image = SFSymbol.messageDeleted.image(withSymbolConfiguration: .init(textStyle: .footnote))
        attachment.image = isSentByWorker ? image.withTintColor(.telaGray5) : image.withTintColor(.telaGray6)
        attachment.bounds = CGRect(x: 0, y: -2.0, width: attachment.image!.size.width, height: attachment.image!.size.height)
        let icon = NSAttributedString(attachment: attachment)
        let messageString = NSMutableAttributedString(string: message, attributes: [
            .font: UIFont.italicSystemFont(ofSize: 13),
            .foregroundColor: isSentByWorker ? UIColor.telaGray5 : UIColor.telaGray6
        ])
        let attributedText = NSMutableAttributedString()
        attributedText.append(icon)
        attributedText.append(messageString)
        return attributedText
    }
    private func getSystemMessageText() -> String {
        return textMessage?.replacingOccurrences(of: "_", with: " ").capitalized ?? ""
    }
    private func getSystemMessageAttributedText() -> NSAttributedString {
        let messageAttributedString = NSAttributedString(string: getSystemMessageText(), attributes: [
            .font : UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.telaYellow
        ])
        let dateAttributedString = NSAttributedString(string: "\nTelabook 🤖 @ \(Date.getStringFromDate(date: self.date!, dateFormat: .MMddyyyy·hmma))", attributes: [
            .font : UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: UIColor.telaYellow
        ])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        let attributedText = NSMutableAttributedString()
        attributedText.append(messageAttributedString)
        attributedText.append(dateAttributedString)
        attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
        return attributedText
    }
    private func getScheduledMessageAttributedText() -> NSAttributedString {
        let messageAttributedString = NSAttributedString(string: textMessage ?? "", attributes: [
            .font : UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.telaWhite
        ])
        let dateAttributedString = NSAttributedString(string: "\nTelabook 🤖 @ \(Date.getStringFromDate(date: self.date!, dateFormat: .MMddyyyy·hmma))", attributes: [
            .font : UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.telaGray5
        ])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributedText = NSMutableAttributedString()
        attributedText.append(messageAttributedString)
        attributedText.append(dateAttributedString)
        attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
        return attributedText
    }
    private func getTextMessageAttributedText(textMessage: String) -> NSAttributedString {
        return NSAttributedString(string: textMessage, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white
        ])
    }
    func multimediaFormattedMessage() -> MessageKind {
        if let url = imageURL {
            let width = UIScreen.main.bounds.width * 0.7
            let size = CGSize(width: width, height: width)
            if let imageText = textMessage?.trimmingCharacters(in: .whitespacesAndNewlines), !imageText.isEmpty {
                return .photo(ImageItem(imageUrl: url, attributedText: getTextMessageAttributedText(textMessage: imageText), size: size))
            } else {
                return .photo(ImageItem(imageUrl: url, size: size))
            }
        } else {
            return .attributedText(getTextMessageAttributedText(textMessage: "Media Unavailable"))
        }
    }
    func textFormattedMessage() -> MessageKind {
        let text = textMessage ?? ""
        if text.containsOnlyEmoji {
            return .emoji(text)
        } else {
            return .attributedText(getTextMessageAttributedText(textMessage: text))
        }
    }
    private func messageKind() -> MessageKind {
        switch messageType {
            case .text:
                return isMessageDeleted && !shouldRevealDeletedMessage ? .attributedText(deletedMessageAttributedText()) : textFormattedMessage()
                
            case .multimedia:
                return isMessageDeleted && !shouldRevealDeletedMessage ? .attributedText(deletedMessageAttributedText()) : multimediaFormattedMessage()
                
            
            case .scheduled:
                return isMessageDeleted && !shouldRevealDeletedMessage ? .attributedText(deletedMessageAttributedText()) : .attributedText(getScheduledMessageAttributedText())
            
            case .system:
                return .custom(getSystemMessageAttributedText())
        }
    }
}
