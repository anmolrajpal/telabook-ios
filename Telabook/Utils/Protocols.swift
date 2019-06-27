//
//  Protocols.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
protocol APIProtocol {
    typealias APICompletion = (ResponseStatus?, Data?, ServiceError?, Error?) -> ()
    func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APICompletion)
}
extension APIProtocol {
    func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APICompletion) {
        if let error = error {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil, nil, .FailedRequest, error)
            }
        } else if let data = data,
            let response = response as? HTTPURLResponse {
            print("Status Code => \(response.statusCode)")
            let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: response.statusCode)
            completion(responseStatus, data, nil, nil)
        } else {
            DispatchQueue.main.async {
                completion(nil, nil, .Unknown, nil)
            }
        }
    }
}
