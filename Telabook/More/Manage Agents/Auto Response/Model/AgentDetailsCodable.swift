//
//  AgentDetailsCodable.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
struct AgentDetailsCodable : Codable {
    
    let callForwardStatus : Bool?
    let groupName : String?
    let groupPhoneNumber : String?
    let smsAutoReply : String?
    let smsAutoReplyStatus : Bool?
    let userId : Int?
    let userName : String?
    let userPhoneNumber : String?
    let voicemailAutoReply : String?
    let voicemailAutoReplyStatus : Bool?
    
    enum CodingKeys: String, CodingKey {
        case callForwardStatus = "call_forward_status"
        case groupName = "group_name"
        case groupPhoneNumber = "group_phone_number"
        case smsAutoReply = "sms_auto_reply"
        case smsAutoReplyStatus = "sms_auto_reply_status"
        case userId = "user_id"
        case userName = "user_name"
        case userPhoneNumber = "user_phone_number"
        case voicemailAutoReply = "voicemail_auto_reply"
        case voicemailAutoReplyStatus = "voicemail_auto_reply_status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        callForwardStatus = try values.decodeIfPresent(Bool.self, forKey: .callForwardStatus)
        groupName = try values.decodeIfPresent(String.self, forKey: .groupName)
        groupPhoneNumber = try values.decodeIfPresent(String.self, forKey: .groupPhoneNumber)
        smsAutoReply = try values.decodeIfPresent(String.self, forKey: .smsAutoReply)
        smsAutoReplyStatus = try values.decodeIfPresent(Bool.self, forKey: .smsAutoReplyStatus)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        userPhoneNumber = try values.decodeIfPresent(String.self, forKey: .userPhoneNumber)
        voicemailAutoReply = try values.decodeIfPresent(String.self, forKey: .voicemailAutoReply)
        voicemailAutoReplyStatus = try values.decodeIfPresent(Bool.self, forKey: .voicemailAutoReplyStatus)
    }
    
}
