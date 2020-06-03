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
        case cancelled
        case invalidURL
        case noFirebaseToken(error: FirebaseAuthService.FirebaseError?)
        case noResponse
        case unexptectedResponse(response:ResponseStatus)
        case noData(response:ResponseStatus)
        case jsonDecodingError(error: Error)
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
            case let .unexptectedResponse(response): return "\(response) | Code: \(ResponseStatus.getStatusCode(by: response))"
            case let .noData(response): return "No Data: \(response) | Code: \(ResponseStatus.getStatusCode(by: response))"
            case let .networkError(error): return "Network Error: \(error.localizedDescription)"
            case let .jsonDecodingError(error): return "Failed to Decode data. Error: \(error.localizedDescription)"
            case let .noFirebaseToken(error): return error?.localizedDescription ?? "Firebase Error(Unknown Reason): Unable to get Firebase Auth Token."
            case let .resultError(message): return message
        }
    }
}
