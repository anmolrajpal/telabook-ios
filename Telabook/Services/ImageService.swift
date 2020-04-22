//
//  ImageService.swift
//  matchbook
//
//  Created by Anmol Rajpal on 29/01/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UIKit
protocol ImageServiceProtocol {
    func fetchImage(path: String, quality: ImageService.ImageQuality) -> AnyPublisher<UIImage?, Never>
    func constructURL(scheme:String, host:String, port:Int?, withConcatenatingPath pathToJoin:String?, parameters:[String:String]?) -> URL?
}
final public class ImageService:ImageServiceProtocol {
    public static let shared = ImageService()
    struct Configuration {
        static let timeOutInterval:TimeInterval = 15.0
        static let apiURLScheme = URLScheme.http.rawValue
        static let baseURL = Config.APIConfig.baseURL
        static let apiHost = Config.APIConfig.apiHost
        static let port:Int? = Config.APIConfig.port
        static let apiCommonPath:String = Config.APIConfig.urlPrefix
    }
    public enum ImageQuality:String {
        case Low, Original
    }
    enum ImageError: Error {
        case decodingError
    }
    
    func fetchImage(path: String, quality: ImageQuality) -> AnyPublisher<UIImage?, Never> {
        let url = constructURL(withConcatenatingPath: path, parameters: ["quality":String(describing: quality)])!
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> UIImage? in
                return UIImage(data: data)
        }.catch { error in
            return Just(nil)
        }
        .eraseToAnyPublisher()
    }
    internal func constructURL(scheme:String = Configuration.apiURLScheme, host:String = Configuration.apiHost, port:Int? = Configuration.port, withConcatenatingPath pathToJoin:String? = nil, parameters:[String:String]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let port = port {
            components.port = port
        }
        if let concatenatingPath = pathToJoin {
            components.path = "/\(concatenatingPath)"
        }
        if let parameters = parameters {
            components.setQueryItems(with: parameters)
        }
        return components.url
    }
}
