//
//  UserMessage.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData
import MessageKit

struct NewMessage:MessageType {
    var sender: SenderType { messageSender }
    var messageSender:MessageSender
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(kind:MessageKind, messageId:String, sender:MessageSender, sentDate:Date) {
        self.messageSender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
}

extension UserMessage {
    
    convenience init(context: NSManagedObjectContext, newMessageEntryFromCurrentUser message:NewMessage, forConversationWithCustomer conversation:Customer) {
        self.init(context: context)
        self.firebaseKey = message.messageId
        self.conversationID = Int64(conversation.externalConversationID)
        self.conversation = conversation
        self.date = message.sentDate
        self.sentByAppAt = message.sentDate
        self.isSentByWorker = true
        switch message.kind {
            case .text(let text):
                self.textMessage = text
                self.type = MessageCategory.text.serverValue
            case .photo(let image):
                guard let image = image as? ImageItem else { return }
                if let text = image.imageText, !text.isBlank {
                    self.textMessage = text
                }
                self.imageURL = image.url
                self.type = MessageCategory.multimedia.serverValue
            default: break
        }
        self.isSending = true
    }
    convenience init(context: NSManagedObjectContext, messageEntryFromFirebase entry:FirebaseMessage, forConversationWithCustomer conversation:Customer) {
        self.init(context: context)
        self.accountSID = entry.accountSID
        self.conversationID = Int64(entry.conversationID)
        self.date = entry.timestamp
        self.deliveredByProviderAt = entry.deliveredByProviderTimestamp
        self.firebaseKey = entry.firebaseKey
        self.hasError = entry.hasError
        let messageImageURLString = entry.messageImageURL
        self.imageUrlString = messageImageURLString
        if let urlString = messageImageURLString,
            let url = URL(string: urlString) {
            self.imageURL = url
        }
        self.isMessageDeleted = entry.deleted
        self.isSentByWorker = entry.senderIsWorker
        self.messageSID = entry.messageSID
        self.type = entry.messageType.rawValue
        self.sentByApiAt = entry.sentByApiTimestamp
        self.sentByAppAt = entry.sentByAppTimestamp
        self.sentByProviderAt = entry.sentByProviderTimestamp
        self.tags = entry.tags
        self.textMessage = entry.messageText
        self.updatedAt = entry.updatedAt
        
        self.lastRefreshedAt = Date()
        
        self.conversation = conversation
    }
    var messageType:MessageCategory {
        MessageCategory(stringValue: self.type!)
    }
}
extension UserMessage {
    func toFirebaseObject() -> Any {
        var dictionary:[String:Any] = [
            "conversationId":NSNumber(value: self.conversationID),
            "type":self.type!,
            "sent_by_app":self.sentByAppAt!.milliSecondsSince1970,
            "date":self.date!.milliSecondsSince1970,
            "sender_is_worker":self.isSentByWorker
        ]
        if let textMessage = self.textMessage {
            dictionary["message"] = textMessage
        }
        if let imageUrlString = self.imageUrlString {
            dictionary["img"] = imageUrlString
        }
        return dictionary
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
    private func messageKind() -> MessageKind {
        switch messageType {
            case .text:
                if self.isMessageDeleted {
                    let message:String = isSentByWorker ? " You deleted this message." : " This Message was deleted."
                    let attachment = NSTextAttachment()
                    let image = SFSymbol.messageDeleted.image(withSymbolConfiguration: .init(textStyle: .footnote)).withTintColor(UIColor.telaGray5)
                    attachment.image = image
                    attachment.bounds = CGRect(x: 0, y: -2.0, width: attachment.image!.size.width, height: attachment.image!.size.height)
                    let icon = NSAttributedString(attachment: attachment)
                    let messageString = NSMutableAttributedString(string: message, attributes: [
                        .font: UIFont.italicSystemFont(ofSize: 13),
                        .foregroundColor: UIColor.telaGray5
                    ])
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(icon)
                    attributedText.append(messageString)
                    return .attributedText(attributedText)
                } else {
                    return .attributedText(NSAttributedString(string: self.textMessage ?? "", attributes: [
                        .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                        .foregroundColor: UIColor.telaWhite
                    ]))
            }
            case .multimedia:
                if let url = self.imageURL {
                    if let imageText = self.textMessage, !imageText.isBlank {
                        return .photo(ImageItem(imageUrl: url, imageText: imageText))
                    } else {
                        return .photo(ImageItem(imageUrl: url))
                    }
                } else {
                    return .text(self.textMessage ?? "")
            }
            case .scheduled:
                let messageAttributedString = NSAttributedString(string: self.textMessage ?? "", attributes: [
                    .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 15)!,
                    .foregroundColor: UIColor.telaWhite
                ])
                let typeAttributedString = NSAttributedString(string: "Scheduled Message: ", attributes: [
                    .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)!,
                    .foregroundColor: UIColor.telaGray6
                ])
                let dateAttributedString = NSAttributedString(string: "\nTelabook 🤖 @ \(Date.getStringFromDate(date: self.date!, dateFormat: .ddMMyyyy·hmma))", attributes: [
                    .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)!,
                    .foregroundColor: UIColor.telaGray5
                ])
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
//                paragraphStyle.alignment = .center
                let attributedText = NSMutableAttributedString()
                attributedText.append(typeAttributedString)
                attributedText.append(messageAttributedString)
                attributedText.append(dateAttributedString)
                attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
                return .attributedText(attributedText)
            
            case .system:
                let messageAttributedString = NSAttributedString(string: self.textMessage?.replacingOccurrences(of: "_", with: " ").capitalized ?? "", attributes: [
                    .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
                    .foregroundColor: UIColor.telaYellow
                ])
                let dateAttributedString = NSAttributedString(string: "\nTelabook 🤖 @ \(Date.getStringFromDate(date: self.date!, dateFormat: .ddMMyyyy·hmma))", attributes: [
                    .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)!,
                    .foregroundColor: UIColor.telaYellow
                ])
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                paragraphStyle.alignment = .center
                let attributedText = NSMutableAttributedString()
                attributedText.append(messageAttributedString)
                attributedText.append(dateAttributedString)
                attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
                return .custom(attributedText)
        }
    }
}


extension UserMessage: Comparable {
    public static func == (lhs: UserMessage, rhs: UserMessage) -> Bool {
        return lhs.sentDate == rhs.sentDate
    }
    
    public static func < (lhs: UserMessage, rhs: UserMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}






struct MessageSender: SenderType, Equatable {
    let senderId: String
    let displayName: String
    init(senderId:String, displayName:String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
struct ImageItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var imageText:String?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    init(imageUrl: URL, size:CGSize = .init(width: 240, height: 240)) {
        self.url = imageUrl
        self.size = size
        self.placeholderImage = size.width > size.height ? #imageLiteral(resourceName: "placeholder-image") : #imageLiteral(resourceName: "placeholder.png")
    }
    init(imageUrl: URL, imageText:String, size:CGSize = .init(width: 240, height: 240)) {
        self.url = imageUrl
        self.imageText = imageText
        self.size = size
        self.placeholderImage = size.width > size.height ? #imageLiteral(resourceName: "placeholder-image") : #imageLiteral(resourceName: "placeholder.png")
    }
    init(imageUrl:URL, image:UIImage, size:CGSize = .init(width: 240, height: 240)) {
        self.url = imageUrl
        self.image = image
        self.size = size
        self.placeholderImage = size.width > size.height ? #imageLiteral(resourceName: "placeholder-image") : #imageLiteral(resourceName: "placeholder.png")
    }
}
