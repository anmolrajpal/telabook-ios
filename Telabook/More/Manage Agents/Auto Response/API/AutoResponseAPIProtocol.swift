//
//  AutoResponseAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol AutoResponseAPIProtocol : APIProtocol {
    func fetchAutoResponseSettings(token:String, userId:String, completion: @escaping APICompletion)
    func saveAutoResponseSettings(token:String, userId:String, callForwardStatus:Bool, voiceMailAutoReplyStatus:Bool, smsAutoReplyStatus:Bool, voiceMailAutoReply:String, smsAutoReply:String, completion: @escaping APICompletion)
}
