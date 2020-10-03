//
//  APIService+Errors.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

extension APIService {
    enum APIError: Error {
        static let commonErrorDescription = "Something went wrong. Please try again later."
        
        case cancelled
        case invalidURL
        case noFirebaseToken(error: FirebaseAuthService.FirebaseError?)
        case noResponse
        case unexpectedResponse(response:ResponseStatus, data:Data?=nil)
        case noData(response:ResponseStatus)
        case jsonDecodingError(error: Error, data:Data)
        case networkError(error: Error)
        case resultError(message: String)
    }
}
extension APIService.APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .cancelled: return "Network operation cancelled by the user"
            case .invalidURL: return "Failed to create URL"
            case .noResponse: return "No Response from Server"
            case .unexpectedResponse(let response, _): return "\(response) | Code: \(ResponseStatus.getStatusCode(by: response))"
            case let .noData(response): return "No Data: \(response) | Code: \(ResponseStatus.getStatusCode(by: response))"
            case let .networkError(error): return "Network Error: \(error.localizedDescription)"
            case let .jsonDecodingError(error, _): return "Failed to Decode data. Error: \(error.localizedDescription)"
            case let .noFirebaseToken(error): return error?.localizedDescription ?? "Firebase Error(Unknown Reason): Unable to get Firebase Auth Token."
            case let .resultError(message): return message
        }
    }
    
    var publicDescription: String {
        switch self {
        case .cancelled, .noResponse, .noData(response: _), .networkError(error: _): return APIService.APIError.commonErrorDescription
        case .invalidURL: return "Application Error. Please report this."
        case .unexpectedResponse(response: _, data: let data):
            if let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let message = jsonObject["message"] as? String {
                return message
            } else {
                return APIService.APIError.commonErrorDescription
            }
        case .noFirebaseToken(_): return "Authentication Error. Please try again in a while."
        case .resultError(let message): return message
        case .jsonDecodingError(_, let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let message = jsonObject["message"] as? String {
                return message
            } else {
                return "Service Error. Please report this bug."
            }
        }
        
    }
}
