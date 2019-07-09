//
//  ManageAgentsAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol ManageAgentsAPIProtocol : APIProtocol {
    func fetchAgents(token:String, companyId:String, completion: @escaping APICompletion)
}
