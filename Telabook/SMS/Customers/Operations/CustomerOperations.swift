//
//  CustomerOperations.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import os

struct CustomerOperations {
    func huh() {
        APIServer<APIService.EmptyData>(apiVersion: .v1).hitEndpoint(endpoint: .AutoResponse, httpMethod: .DELETE) { (result: Result<APIService.EmptyData, APIService.APIError>) in

        }
    }
}
