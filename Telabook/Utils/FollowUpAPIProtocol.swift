//
//  FollowUpAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol FollowUpAPIProtocol : APIProtocol {
    func fetchFollowUpsIndex(token:String, companyId:String, completion: @escaping APICompletion)
}
