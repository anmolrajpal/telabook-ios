//
//  CallGroupsAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol CallGroupsAPIProtocol: APIProtocol {
    var fetchCallGroupsDataTask:URLSessionDataTask? { get }
    var toggleCallGroupDataTask:URLSessionDataTask? { get }
    
    func fetchCallGroups(token:String, completion: @escaping APICompletion)
    func toggleCallGroupStatus(token:String, groupId:String, completion: @escaping APICompletion)
}
