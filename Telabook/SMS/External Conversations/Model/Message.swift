//
//  Message.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

private struct ImageMediaItem: MediaItem {
    
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
    init(imageUrl: URL) {
        self.url = imageUrl
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = #imageLiteral(resourceName: "save_img")
    }
    init(imageUrl: URL, imageText:String) {
        self.url = imageUrl
        self.imageText = imageText
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = #imageLiteral(resourceName: "save_img")
    }
    init(imageUrl:URL, image:UIImage) {
        self.url = imageUrl
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}
//struct ChatSender {
//    let 
//}
struct ChatMessage: MessageType {
    
    let messageId: String
    //    let content: String
    let sentDate: Date
    let sender: Sender
    var kind: MessageKind
    //    var user:User
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        //        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.sender = sender
    }
    
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(imageUrl: URL, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageUrl: imageUrl)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(imageUrl:URL, image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageUrl: imageUrl, image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    //    var messageId: String {
    //        return id ?? UUID().uuidString
    //    }
    
    //    var image: UIImage? = nil
    //    var downloadURL: URL? = nil
    //
    //    init(user: User, content: String) {
    //        sender = Sender(id: user.uid, displayName: AppSettings.displayName)
    //        self.content = content
    //        sentDate = Date()
    //        id = nil
    //    }
    //
    //    init(user: User, image: UIImage) {
    //        sender = Sender(id: user.uid, displayName: AppSettings.displayName)
    //        self.image = image
    //        content = ""
    //        sentDate = Date()
    //        id = nil
    //    }
    
}


struct Message: MessageType {
    
    let messageId: String
//    let content: String
    let sentDate: Date
    let sender: Sender
    var kind: MessageKind
    var imageURL:URL? = nil
    var imageTEXT:String? = nil
    var text:String? = nil
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
//        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.sender = sender
    }
    
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
        self.text = text
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(imageUrl: URL, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageUrl: imageUrl)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
        self.imageURL = imageUrl
    }
    init(imageUrl: URL, text:String, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageUrl: imageUrl, imageText: text)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
        self.text = text
        self.imageURL = imageUrl
        self.imageTEXT = text
    }
    init(imageUrl:URL, image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageUrl: imageUrl, image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }
//    var messageId: String {
//        return id ?? UUID().uuidString
//    }
    
//    var image: UIImage? = nil
//    var downloadURL: URL? = nil
//
//    init(user: User, content: String) {
//        sender = Sender(id: user.uid, displayName: AppSettings.displayName)
//        self.content = content
//        sentDate = Date()
//        id = nil
//    }
//
//    init(user: User, image: UIImage) {
//        sender = Sender(id: user.uid, displayName: AppSettings.displayName)
//        self.image = image
//        content = ""
//        sentDate = Date()
//        id = nil
//    }
    
}
extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate == rhs.sentDate
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
