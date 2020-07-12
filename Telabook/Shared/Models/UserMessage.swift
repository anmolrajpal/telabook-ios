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
        self.updatedAt = message.sentDate
        self.sentByAppAt = message.sentDate
        self.isSentByWorker = true
        switch message.kind {
            case .text(let text), .emoji(let text):
                self.textMessage = text
                self.type = MessageCategory.text.serverValue
            case .photo(let image):
                guard let image = image as? ImageItem else { return }
                if let text = image.imageText, !text.isBlank {
                    self.textMessage = text
                }
                self.imageURL = image.url
                self.imageUUID = image.imageUUID
                self.type = MessageCategory.multimedia.serverValue
            default: break
        }
        self.isSending = true
        self.lastRefreshedAt = Date()
    }
    convenience init(context: NSManagedObjectContext, messageEntryFromFirebase entry:FirebaseMessage, forConversationWithCustomer conversation:Customer, imageUUID: UUID?, isSeen:Bool, downloadState:MediaDownloadState, uploadState:MediaUploadState) {
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
        //        self.type = entry.messageType.rawValue
        self.messageType = entry.messageType
        self.sentByApiAt = entry.sentByApiTimestamp
        self.sentByAppAt = entry.sentByAppTimestamp
        self.sentByProviderAt = entry.sentByProviderTimestamp
        self.tags = entry.tags
        self.textMessage = entry.messageText
        self.updatedAt = entry.updatedAt
        self.conversation = conversation
        
        // - Local stored properties
        self.imageUUID = imageUUID
        self.downloadState = downloadState
        self.uploadState = uploadState
        self.isSeen = isSeen
        self.lastRefreshedAt = Date()
    }
    var messageType:MessageCategory {
        get {
            MessageCategory(stringValue: type ?? "text")
        }
        set {
            type = newValue.rawValue
        }
    }
}
extension UserMessage {
    func toFirebaseObject() -> Any {
        let time = self.sentByAppAt!.milliSecondsSince1970
        var dictionary:[String:Any] = [
            "conversationId":NSNumber(value: self.conversationID),
            "type":self.messageType.serverValue,
            "sent_by_app":time,
            "updated_at":time,
            "date":time,
            "sender_is_worker":self.isSentByWorker
        ]
        if let textMessage = self.textMessage {
            dictionary["message"] = textMessage
        }
        if let imageUrlString = self.imageUrlString {
            dictionary["img"] = imageUrlString
            let size = NSNumber(value: self.mediaSize)
            dictionary["size"] = size
        }
        return dictionary
    }
    
    
    func getDeletedFirebaseObject(updatedAt:Date) -> [AnyHashable:Any] {
        return  [
            "deleted":1,
            "updated_at":updatedAt.milliSecondsSince1970
        ]
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
        let dateAttributedString = NSAttributedString(string: "\nTelabook 🤖 @ \(Date.getStringFromDate(date: self.date!, dateFormat: .ddMMyyyy·hmma))", attributes: [
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
        let messageAttributedString = NSAttributedString(string: self.textMessage ?? "", attributes: [
            .font : UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.telaWhite
        ])
        let dateAttributedString = NSAttributedString(string: "\nTelabook 🤖 @ \(Date.getStringFromDate(date: self.date!, dateFormat: .ddMMyyyy·hmma))", attributes: [
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
    private func messageKind() -> MessageKind {
        switch messageType {
            case .text:
                if isMessageDeleted {
                    let attributedText = deletedMessageAttributedText()
                    return .attributedText(attributedText)
                } else {
                    let text = self.textMessage ?? ""
                    if text.containsOnlyEmoji {
                        return .emoji(text)
                    } else {
                        return .attributedText(getTextMessageAttributedText(textMessage: text))
                    }
            }
            case .multimedia:
                if isMessageDeleted {
                    let attributedText = deletedMessageAttributedText()
                    return .attributedText(attributedText)
                } else {
                    if let url = self.imageURL {
                        let width = UIScreen.main.bounds.width * 0.7
                        let size = CGSize(width: width, height: width)
                        if let imageText = self.textMessage, !imageText.isBlank {
                            return .photo(ImageItem(imageUrl: url, attributedText: getTextMessageAttributedText(textMessage: imageText), size: size))
                        } else {
                            return .photo(ImageItem(imageUrl: url, size: size))
                        }
                    } else {
                        return .attributedText(getTextMessageAttributedText(textMessage: "Media Unavailable"))
                    }
                }
            
            case .scheduled:
                if isMessageDeleted {
                    let attributedText = deletedMessageAttributedText()
                    return .attributedText(attributedText)
                } else {
                    let attributedText = getScheduledMessageAttributedText()
                    return .attributedText(attributedText)
                }
            
            case .system:
                let attributedText = getSystemMessageAttributedText()
                return .custom(attributedText)
        }
    }
}


//extension UserMessage: Comparable {
//    public static func == (lhs: UserMessage, rhs: UserMessage) -> Bool {
//        return lhs.sentDate == rhs.sentDate
//    }
//
//    public static func < (lhs: UserMessage, rhs: UserMessage) -> Bool {
//        return lhs.sentDate < rhs.sentDate
//    }
//}






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
    var imageUUID:UUID?
    var imageText:String?
    var attributedText:NSAttributedString?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 270, height: 270)
        self.placeholderImage = UIImage()
    }
    init(imageUrl: URL, size:CGSize = .init(width: 270, height: 270)) {
        self.url = imageUrl
        self.size = size
        self.placeholderImage = UIImage()
    }
    init(imageUrl: URL, imageText:String, size:CGSize = .init(width: 270, height: 270)) {
        self.init(imageUrl: imageUrl, size: size)
        self.imageText = imageText
    }
    init(imageUrl: URL, attributedText:NSAttributedString, size:CGSize = .init(width: 270, height: 270)) {
        self.init(imageUrl: imageUrl, imageText: attributedText.string, size: size)
        self.attributedText = attributedText
    }
    init(imageUrl:URL, image:UIImage?, attributedText:NSAttributedString, size:CGSize = .init(width: 270, height: 270)) {
        self.init(imageUrl: imageUrl, attributedText: attributedText, size: size)
        self.image = image
    }
    init(imageUrl:URL, image:UIImage?, size:CGSize = .init(width: 270, height: 270)) {
        self.url = imageUrl
        self.image = image
        self.size = size
        self.placeholderImage = UIImage()
        //        self.placeholderImage = size.width > size.height ? #imageLiteral(resourceName: "placeholder-image") : #imageLiteral(resourceName: "placeholder.png")
    }
    
    
    init(image:UIImage, imageUUID:UUID, uploadURL:URL?, imageText:String?, size:CGSize = .init(width: 270, height: 270)) {
        self.image = image
        self.imageText = imageText
        self.imageUUID = imageUUID
        self.url = uploadURL
        self.size = size
        self.placeholderImage = UIImage()
    }
    init(image:UIImage, imageUUID:UUID, uploadURL:URL?, attributedText:NSAttributedString, size:CGSize = .init(width: 270, height: 270)) {
        self.init(image: image, imageUUID: imageUUID, uploadURL: uploadURL, imageText: attributedText.string, size: size)
        self.attributedText = attributedText
    }
}




extension UserMessage {
    
    enum MediaDownloadState:Int {
        case new = 0, downloaded, failed
        
        init(_ rawValue:Int) {
            switch rawValue {
                case 0: self = .new
                case 1: self = .downloaded
                case 2: self = .failed
                default: fatalError("Invalid case")
            }
        }
    }
    var downloadState:MediaDownloadState {
        get {
            MediaDownloadState(Int(mediaDownloadState))
        }
        set {
            mediaDownloadState = Int64(newValue.rawValue)
        }
    }
    
    
    enum MediaUploadState:Int {
        case none = 0, pending, uploaded, failed
        
        init(_ rawValue:Int) {
            switch rawValue {
                case 0: self = .none
                case 1: self = .pending
                case 2: self = .uploaded
                case 3: self = .failed
                default: fatalError("Invalid case")
            }
        }
    }
    var uploadState:MediaUploadState {
        get {
            MediaUploadState(Int(mediaUploadState))
        }
        set {
            mediaUploadState = Int64(newValue.rawValue)
        }
    }
    
    func imageLocalURL() -> URL? {
        guard let uuid = imageUUID else { return nil }
        let fileName = uuid.uuidString + ".jpeg"
        guard let con = conversation else {
            print("Failed to unwrap conversation")
            return nil
        }
        let mediaFolder = con.mediaFolder()
        //        print("Media folder url: \(mediaFolder)")
        let url = mediaFolder.appendingPathComponent(fileName)
        return url
    }
    
    
    
    
    var uploadRequest: URLRequest? {
        guard let url = imageURL else { return nil }
        var request = URLRequest(url: url)
        request.setValue(Header.contentType.image·jpeg.rawValue, forHTTPHeaderField: Header.headerName.contentType.rawValue)
        request.httpMethod = HTTPMethod.POST.rawValue
        return request
    }
    
    
    /**
     Load the image from the cached file if it exists, otherwise from the attachment’s imageData.
     
     Attachments created by Core Data with CloudKit don’t have cached files.
     Provide a new task context to load the image data, and release it after the image finishes loading.
     */
    func getImage() -> UIImage? {
        // Load the image from the cached file if the file exists.
        guard let url = imageLocalURL() else { return nil }
        var image: UIImage?
        
        var nsError: NSError?
        NSFileCoordinator().coordinate(
            readingItemAt: url, options: .withoutChanges, error: &nsError,
            byAccessor: { (newURL: URL) -> Void in
                if let data = try? Data(contentsOf: newURL) {
                    image = UIImage(data: data, scale: UIScreen.main.scale)
                }
        })
        if let nsError = nsError {
            print("###\(#function): \(nsError.localizedDescription)")
        }
        return image
    }
}
