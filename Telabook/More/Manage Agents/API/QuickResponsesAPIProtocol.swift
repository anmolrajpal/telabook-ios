//
//  QuickResponsesAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol QuickResponsesAPIProtocol : APIProtocol {
    func fetchQuickResponses(token:String, userId:String, completion: @escaping APICompletion)
    func addQuickResponse(token:String, userId:String, answer:String, completion: @escaping APICompletion)
    func updateQuickResponse(token:String, userId:String, answer:String, responseId:String, completion: @escaping APICompletion)
    func deleteQuickResponse(token:String, userId:String, responseId:String, completion: @escaping APICompletion)
}
