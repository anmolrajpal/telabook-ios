//
//  APIService+Errors.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation

extension APIService {
    enum APIError: Error {
        case cancelled
        case invalidURL
        case noFirebaseToken(error: Error?)
        case noResponse
        case unexptectedResponse(response:ResponseStatus)
        case noData(response:ResponseStatus)
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
    }
}
extension APIService.APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .cancelled: return "Network operation cancelled by the user"
            case .invalidURL: return "Failed to create URL"
            case .noResponse: return "No Response from Server"
            case let .unexptectedResponse(response): return "Unexptected Response. Response Status: \(response) | Code- \(ResponseStatus.getStatusCode(by: response))"
            case let .noData(response): return "No Data from Server. Response Status - \(response)| Code- \(ResponseStatus.getStatusCode(by: response))"
            case let .networkError(error): return "Network Error: \(error.localizedDescription)"
            case let .jsonDecodingError(error): return "Failed to Decode data. Error: \(error.localizedDescription)"
            case let .noFirebaseToken(error): return "Firebase Error: \(error?.localizedDescription ?? "Unable to get Firebase Auth Token.")"
        }
    }
}
