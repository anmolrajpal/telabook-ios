//
//  APIServiceURLConstructor.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation

extension APIService {
    internal func constructURL(scheme:String = Configuration.apiURLScheme, host:String = Configuration.apiHost, port:Int? = Configuration.port, forEndpoint endpoint:Endpoint, urlPrefix:String = Configuration.apiCommonPath, withConcatenatingPath pathToJoin:String? = nil, parameters:[String:String]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let port = port {
            components.port = port
        }
        if let concatenatingPath = pathToJoin {
            components.path = urlPrefix + endpoint.path() + "/\(concatenatingPath)"
        } else {
            components.path = urlPrefix + endpoint.path()
        }
        if let parameters = parameters {
            components.setQueryItems(with: parameters)
        }
        return components.url
    }
}
