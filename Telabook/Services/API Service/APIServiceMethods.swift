//
//  APIServiceMethods.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation

extension APIService {
    
    func loginWithCredentials<T: Codable>(endpoint: Endpoint = .SignIn, email: String, password: String, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.authenticateAndFetchToken(email: email, password: password) { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.POST.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func hit<T: Codable>(endpoint: Endpoint, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = httpMethod.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            
        
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func hit<T: Codable>(endpoint: Endpoint, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = httpMethod.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            
        
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                
                if expectData {
                    guard let data = data else {
                        DispatchQueue.main.async {
                            completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                        }
                        return
                    }
                    #if DEBUG
                    let jsonString = String(data: data, encoding: .utf8)!
                    print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                    #endif
                    do {
                        let object = try self.decoder.decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(object))
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            #if DEBUG
                            print("JSON Decoding Error: \(error.localizedDescription)")
                            #endif
                            completion(.failure(.jsonDecodingError(error: error)))
                        }
                    }
                } else {
                    let customObjectString = "{\"result\":\"success\",\"message\":\"Success. Empty Data or Data not required.\",\"data\":{}}"
                    let customObject = try! self.decoder.decode(T.self, from: customObjectString.data(using: .utf8)!)
                    DispatchQueue.main.async {
                        completion(.success(customObject))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func GET<T: Codable>(endpoint: Endpoint, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.GET.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
    }
    
    func POST<T: Codable>(endpoint: Endpoint, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.POST.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            
        
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func PUT<T: Codable>(endpoint: Endpoint, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.PUT.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func DELETE<T: Codable>(endpoint: Endpoint, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            guard let bearerToken = token else {
                DispatchQueue.main.async {
                    completion(.failure(.noFirebaseToken(error: error!)))
                }
                return
            }
            #if DEBUG
            print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
            #endif
            guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
                print("Error Log: Unable to Construct URL")
                completion(.failure(.invalidURL))
                return
            }
            #if DEBUG
            print("Endpoint URL= \(url)")
            #endif
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
            request.httpMethod = HTTPMethod.DELETE.rawValue
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
            if let headers = headers { headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
            if let httpBody = httpBody { request.httpBody = httpBody }
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error: error!)))
                    }
                    return
                }
                guard let response = response else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
                let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
                #if DEBUG
                print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
                #endif
                if let expectedResponse = guardResponse {
                    guard responseStatus == expectedResponse else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                } else {
                    guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexptectedResponse(response: responseStatus)))
                        }
                        return
                    }
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            }
            task.resume()
        }
        
    }
    
}





extension APIService {
    
    
    @discardableResult
    func hitEndpoint<T: Codable>(endpoint: Endpoint, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, completion: @escaping APICompletion<T>) -> URLSessionDataTask? {
        
        guard let bearerToken = FirebaseAuthService.shared.getCurrentToken() else {
            DispatchQueue.main.async {
                completion(.failure(.noFirebaseToken(error: nil)))
            }
            return nil
        }
        #if DEBUG
        print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
        #endif
        guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
            print("Error Log: Unable to Construct URL")
            completion(.failure(.invalidURL))
            return nil
        }
        #if DEBUG
        print("Endpoint URL= \(url)")
        #endif
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
        request.httpMethod = httpMethod.rawValue
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
        if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
        if let httpBody = httpBody { request.httpBody = httpBody }
        
        
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error: error!)))
                }
                return
            }
            guard let response = response else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
            let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
            #if DEBUG
            print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
            #endif
            if let expectedResponse = guardResponse {
                guard responseStatus == expectedResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.unexptectedResponse(response: responseStatus)))
                    }
                    return
                }
            } else {
                guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                    DispatchQueue.main.async {
                        completion(.failure(.unexptectedResponse(response: responseStatus)))
                    }
                    return
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                }
                return
            }
            #if DEBUG
            let jsonString = String(data: data, encoding: .utf8)!
            print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
            #endif
            do {
                let object = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch let error {
                DispatchQueue.main.async {
                    #if DEBUG
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    #endif
                    completion(.failure(.jsonDecodingError(error: error)))
                }
            }
        }
        //            return task
        
        
    }
    
    @discardableResult
    func hitEndpoint<T: Codable>(endpoint: Endpoint, httpMethod:HTTPMethod, params: [String: String]? = nil, httpBody: Data? = nil, headers: [HTTPHeader]? = nil, guardResponse: ResponseStatus? = nil, expectData:Bool = true, completion: @escaping APICompletion<T>) -> URLSessionDataTask? {
        guard let bearerToken = FirebaseAuthService.shared.getCurrentToken() else {
            DispatchQueue.main.async {
                completion(.failure(.noFirebaseToken(error: nil)))
            }
            return nil
        }
        #if DEBUG
        print("\n\n------------------------------------------------ Firebase Token: BEGIN ------------------------------------------------\n\nFirebase Bearer Token: \(bearerToken)\n\n--------------------------------------------------- Firebase Token: END ------------------------------------------------\n\n")
        #endif
        guard let url = self.constructURL(forEndpoint: endpoint, parameters: params) else {
            print("Error Log: Unable to Construct URL")
            completion(.failure(.invalidURL))
            return nil
        }
        #if DEBUG
        print("Endpoint URL= \(url)")
        #endif
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Configuration.timeOutInterval)
        request.httpMethod = httpMethod.rawValue
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
        if let headers = headers { headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }) }
        if let httpBody = httpBody { request.httpBody = httpBody }
        
        
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error: error!)))
                }
                return
            }
            guard let response = response else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            let responseCode = (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)
            let responseStatus = ResponseStatus.getResponseStatusBy(statusCode: responseCode)
            #if DEBUG
            print("\n\n------------------------------------------------ Response: BEGIN ------------------------------------------------\n\nResponse Status => \(responseStatus)\nResponse Code => \(responseCode)\n\n--------------------------------------------------- Response: END ------------------------------------------------\n\n")
            #endif
            if let expectedResponse = guardResponse {
                guard responseStatus == expectedResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.unexptectedResponse(response: responseStatus)))
                    }
                    return
                }
            } else {
                guard responseStatus == .OK || responseStatus == .Created || responseStatus == .Accepted || responseStatus == .NoContent else {
                    DispatchQueue.main.async {
                        completion(.failure(.unexptectedResponse(response: responseStatus)))
                    }
                    return
                }
            }
            
            if expectData {
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(response: ResponseStatus.getResponseStatusBy(statusCode: (response as? HTTPURLResponse)?.statusCode ?? ResponseStatus.getStatusCode(by: .UnknownResponse)))))
                    }
                    return
                }
                #if DEBUG
                let jsonString = String(data: data, encoding: .utf8)!
                print("\n\n------------------------------------------------ Raw JSON Object: BEGIN ------------------------------------------------\n\n"+jsonString+"\n\n--------------------------------------------------- Raw JSON Object: END ------------------------------------------------\n\n")
                #endif
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("JSON Decoding Error: \(error.localizedDescription)")
                        #endif
                        completion(.failure(.jsonDecodingError(error: error)))
                    }
                }
            } else {
                let customObjectString = "{\"result\":\"success\",\"message\":\"Success. Empty Data or Data not required.\",\"data\":{}}"
                let customObject = try! self.decoder.decode(T.self, from: customObjectString.data(using: .utf8)!)
                DispatchQueue.main.async {
                    completion(.success(customObject))
                }
            }
        }
    }
}
