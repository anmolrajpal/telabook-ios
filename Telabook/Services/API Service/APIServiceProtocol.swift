//
//  APIServiceProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
protocol APIServiceProtocol {
    func loginWithCredentials<T: Codable>(endpoint: APIService.Endpoint, email: String, password: String, params: [String: String]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func GET<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func POST<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func PUT<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func DELETE<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func constructURL(scheme:String, host:String, port:Int?, forEndpoint endpoint:APIService.Endpoint, urlPrefix:String, withConcatenatingPath pathToJoin:String?, parameters:[String:String]?) -> URL?
}
