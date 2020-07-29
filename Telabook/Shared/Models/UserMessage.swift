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



extension UserMessage {
    
    convenience init(context: NSManagedObjectContext, newMessageEntryFromCurrentUser message: NewMessage, forConversationWithCustomer conversation: Customer) {
        self.init(context: context)
        self.firebaseKey = message.messageId
        self.conversationID = Int64(conversation.externalConversationID)
        self.conversation = conversation
        self.date = message.sentDate
        self.updatedAt = message.sentDate
        self.sentByAppAt = message.sentDate
        self.isSentByWorker = true
        switch message.kind {
            case .attributedText(let attributedText):
                self.textMessage = attributedText.string
                self.type = MessageCategory.text.serverValue
            case .text(let text), .emoji(let text):
                self.textMessage = text
                self.type = MessageCategory.text.serverValue
            case .photo(let mediaItem as ImageItem):
                if let text = mediaItem.imageText, !text.isBlank {
                    self.textMessage = text
                }
                self.imageURL = mediaItem.url
                self.imageUrlString = mediaItem.url?.absoluteString
                self.imageUUID = mediaItem.imageUUID
                self.mediaSize = Int64(mediaItem.mediaSizeInBytes ?? 0)
                self.type = MessageCategory.multimedia.serverValue
            default: break
        }
        self.forwardedFrom = message.forwardedFrom
        self.isSending = true
        self.lastRefreshedAt = Date()
    }
    
    
    
    convenience init(context: NSManagedObjectContext, messageEntryFromFirebase entry: FirebaseMessage, forConversationWithCustomer conversation:Customer, imageUUID: UUID?, isSeen:Bool, downloadState:MediaDownloadState, uploadState:MediaUploadState) {
        self.init(context: context)
        self.accountSID = entry.accountSID
        self.conversationID = Int64(entry.conversationID)
        self.date = entry.timestamp
        self.deliveredByProviderAt = entry.deliveredByProviderTimestamp
        self.firebaseKey = entry.firebaseKey
        self.hasError = entry.hasError
        self.forwardedFrom = entry.forwardedFromNode
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
    var messageType: MessageCategory {
        get {
            MessageCategory(stringValue: type ?? "text")
        }
        set {
            type = newValue.rawValue
        }
    }
}










