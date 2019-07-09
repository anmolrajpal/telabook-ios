//
//  ExternalConversationsAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation


protocol ExternalConversationsAPIProtocol {
    typealias APITaskCompletion = (Data?, ServiceError?, Error?) -> ()
    typealias APICompletion = (ResponseStatus?, Data?, ServiceError?, Error?) -> ()
    //MARK: HANDLE RESPONSE DATA
    func handleResponseData(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APITaskCompletion)
    
    //MARK: EXTERNAL CONVERSATIONS FETCH START
    var apiURL:String { get }
    func getAPIUrlParamString(_ token:String, _ companyId:String, _ workerId:String, _ isArchived:Bool) -> String
    func fetch(token:String, companyId:String, workerId:String, isArchived:Bool, completion: @escaping APICompletion)
    //MARK: EXTERNAL CONVERSATIONS FETCH END
    
    //MARK: ARCHIVE EXTERNAL CONVERSATION START
    var archiveECApiURL:String { get }
    var unarchiveECApiURL:String { get }
    func handleArchivingParamString(_ token: String, _ companyId: String, _ conversationId:String) -> String
    func handleArchiving(token:String, companyId:String, conversationId:String, markArchive:Bool, completion: @escaping APICompletion)
    //MARK: ARCHIVE EXTERNAL CONVERSATION END
    
    
    //MARK: BLOCK NUMBER START
    func blockNumber(token:String, companyId:String, conversationId:String, number:String, completion: @escaping APICompletion)
    //MARK: BLOCK NUMBER END
    
    
    
    
}
