//
//  ScheduleMessageAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol ScheduleMessageAPIProtocol : APIProtocol {
    func fetchScheduledMessages(token:String, userId:String, completion: @escaping APICompletion)
    func scheduleMessage(token:String, customerId:String, workerId:String, text:String, date:String, completion: @escaping APICompletion)
}
