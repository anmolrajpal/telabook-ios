//
//  UserMessage.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData
import MessageKit

extension UserMessage {
    
    
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
        
        self.conversation = conversation
    }
    var messageType:MessageCategory {
        MessageCategory(stringValue: self.type!)
    }
}


extension UserMessage: MessageType {
    public var sender: SenderType { self.messageSender }
    
    public var messageId: String { self.firebaseKey! }
    
    public var sentDate: Date { self.date! }
    
    public var kind: MessageKind { self.messageKind() }
    
    
    var messageSender: MessageSender {
        let customerName = self.conversation?.addressBookName ?? ""
        let workerName = self.conversation?.agent?.personName ?? ""
        let customerID = String(self.conversation?.customerID ?? 0)
        let workerID = String(self.conversation?.agent?.workerID ?? 0)
        let customer = MessageSender(senderId: customerID, displayName: customerName)
        let worker = MessageSender(senderId: workerID, displayName: workerName)
        return self.isSentByWorker ? worker : customer
    }
    private func messageKind() -> MessageKind {
        switch messageType {
            case .text:
                return .text(self.textMessage!)
            case .multimedia:
                if let url = self.imageURL {
                    if let imageText = self.textMessage {
                        return .photo(ImageItem(imageUrl: url, imageText: imageText))
                    } else {
                        return .photo(ImageItem(imageUrl: url))
                    }
                } else {
                    return .text(self.textMessage ?? "")
            }
            case .scheduled:
                return .attributedText(NSAttributedString(string: self.textMessage ?? "", attributes: [
                    .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 15)!
                ]))
            
            case .system:
                return .attributedText(NSAttributedString(string: self.textMessage ?? "", attributes: [
                    .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 15)!,
                    .foregroundColor: UIColor.telaGray6
                ]))
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
private struct ImageItem: MediaItem {
    
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
