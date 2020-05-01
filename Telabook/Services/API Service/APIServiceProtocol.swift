//
//  APIServiceProtocol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
protocol APIServiceProtocol {
    func hit<T: Codable>(endpoint: APIService.Endpoint, httpMethod:HTTPMethod, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func hit<T: Codable>(endpoint: APIService.Endpoint, httpMethod:HTTPMethod, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, expectData:Bool, completion: @escaping APIService.APICompletion<T>)
    
    @discardableResult
    func hitEndpoint<T: Codable>(endpoint: APIService.Endpoint, httpMethod:HTTPMethod, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>) -> URLSessionDataTask?
    
    @discardableResult
    func hitEndpoint<T: Codable>(endpoint: APIService.Endpoint, httpMethod:HTTPMethod, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, expectData:Bool, completion: @escaping APIService.APICompletion<T>) -> URLSessionDataTask?
    
    
    func loginWithCredentials<T: Codable>(endpoint: APIService.Endpoint, email: String, password: String, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func GET<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func POST<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func PUT<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func DELETE<T: Codable>(endpoint: APIService.Endpoint, params: [String: String]?, httpBody: Data?, headers: [HTTPHeader]?, guardResponse: ResponseStatus?, completion: @escaping APIService.APICompletion<T>)
    func constructURL(scheme:String, host:String, port:Int?, forEndpoint endpoint:APIService.Endpoint, urlPrefix:String, withConcatenatingPath pathToJoin:String?, parameters:[String:String]?) -> URL?
}
