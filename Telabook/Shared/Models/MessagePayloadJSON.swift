//
//  MessagePayloadJSON.swift
//  Telabook
//
//  Created by Anmol Rajpal on 31/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation


// MARK: - Decodable

/**
 A struct for decoding JSON with the following structure:

 {
   "worker_name" : "Christen Eaton",
   "recipient_did" : "+12536520616",
   "recipient_id" : "282",
   "node" : "282-626-Customer",
   "sender_name" : "Esther GLOBAL!!",
   "google.c.a.e" : "1",
   "aps" : {
     "mutable-content" : 1,
     "alert" : {
       "title" : "Message for Christen Eaton",
       "body" : "Noti..."
     },
     "badge" : 1,
     "sound" : "default"
   },
   "color" : "#90CAF9",
   "worker_id" : "282",
   "notify" : "1",
   "body" : "Noti...",
   "gcm.message_id" : "1596216297208667",
   "external_conversation_id" : "1116",
   "id" : "1116",
   "groupSummary" : "Message for Christen Eaton",
   "group" : "282-626-Customer",
   "sound" : "default",
   "sender_number" : "+17162411222",
   "lines" : "[{\"date\":1596216295027,\"message\":\"Noti\"}]",
   "title" : "Message for Christen Eaton"
 }

*/

struct MessagePayloadJSON: Decodable {
    let externalConversationId : String?
    let gcmMessageId : String? // TODO: - Error here
    let lines : String?
    let node : String?
    let recipientDid : String?
    let senderName : String?
    let senderNumber : String?
    let workerId : String?
    let workerName : String?
}
