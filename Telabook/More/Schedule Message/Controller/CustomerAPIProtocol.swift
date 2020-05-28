//
//  CustomerAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol CustomerAPIProtocol: APIProtocol {
    func fetchCustomers(token:String, companyId:String, workerId:String, completion: @escaping APICompletion)
}
