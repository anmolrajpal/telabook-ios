//
//  BlacklistAPIProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
protocol BlacklistAPIProtocol : APIProtocol {
    func fetchBlacklist(token:String, companyId:String, completion: @escaping APICompletion)
    func unblockNumber(token:String, companyId:String, id:String, number:String, completion: @escaping APICompletion)
}
