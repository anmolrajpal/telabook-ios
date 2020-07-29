//
//  NewMessage.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import MessageKit

struct NewMessage:MessageType {
    var sender: SenderType { messageSender }
    var messageSender:MessageSender
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var forwardedFrom: String?
    
    init(kind:MessageKind, messageId:String, sender:MessageSender, sentDate:Date) {
        self.messageSender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    init(kind:MessageKind, messageId:String, sender:MessageSender, sentDate:Date, forwardedFromNode: String) {
        self.init(kind: kind, messageId: messageId, sender: sender, sentDate: sentDate)
        self.forwardedFrom = forwardedFromNode
    }
}
