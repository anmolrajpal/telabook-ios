//
//  FirebaseAuthService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
import Firebase
import UIKit
final class FirebaseAuthService:NSObject {
    static let shared = FirebaseAuthService()
    
    var authenticationStateListener:AuthStateDidChangeListenerHandle?
    var tokenStateListener:IDTokenDidChangeListenerHandle?
    
    typealias FirebaseTokenFetchCompletion = (Result<String, FirebaseError>) -> Void
    enum FirebaseError:Error, LocalizedError {
        static let commonErrorDescription = "Something went wrong. Please try again in a while."
        
        case cancelled
        case noCurrentUser
        case referenceError
        case authenticationError(Error)
        case noIDToken(Error)
        case unknown
        case databaseSetValueError(Error)
        case databaseUpdateValueError(Error)
        case databaseRemoveValueError(Error)
        case storageDeleteObjectError(Error)
        
        var localizedDescription: String {
            switch self {
                case .cancelled: return "Firebase Error: Operation Cancelled"
                case .noCurrentUser: return "Firebase User Error: Invalid User or Session Expired. Please Login again."
                case .referenceError: return "Firebase Internal Error"
                case let .authenticationError(error): return "Firebase Authentication Error: \(error.localizedDescription)"
                case let .noIDToken(error): return "Firebase Token Error: \(error.localizedDescription)"
                case let .databaseSetValueError(error): return "Error setting value in Firebase Database: \(error.localizedDescription)"
                case let .databaseUpdateValueError(error): return "Error updating value in Firebase Database: \(error.localizedDescription)"
                case let .databaseRemoveValueError(error): return "Error removing value from Firebase Database: \(error.localizedDescription)"
                case let .storageDeleteObjectError(error): return "Error deleting object from Firebase Storage: \(error.localizedDescription)"
                case .unknown: return "Firebase Error (Reason: Unknown). Please try signin in again."
            }
        }
        
        var publicDescription: String {
            switch self {
            case .cancelled, .referenceError, .authenticationError, .noIDToken: return FirebaseError.commonErrorDescription
            case .noCurrentUser, .unknown: return "Session expired. Please login again."
            default: return "Application error. Please report this bug."
            }
        }
    }
    typealias TokenFetchCompletion = (String?, FirebaseError?) -> ()
    func authenticateAndFetchToken(email:String, password:String, completion: @escaping TokenFetchCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard self != nil else {
                DispatchQueue.main.async {
                    print(FirebaseError.referenceError.localizedDescription)
                    completion(nil, .referenceError)
                }
                return
            }
            if let err = error {
                DispatchQueue.main.async {
                    print(FirebaseError.authenticationError(err))
                    completion(nil, .authenticationError(err))
                }
            } else if let userData = user {
                userData.user.getIDToken(completion: { (token, err) in
                    if let e = err {
                        print(FirebaseError.noIDToken(e))
                        DispatchQueue.main.async {
                            completion(nil, .noIDToken(e))
                        }
                    } else if let t = token {
                        DispatchQueue.main.async {
                            completion(t, nil)
                        }
                    }
                })
            }
        }
    }
    
    func addObservers() {
        observeAuthenticationState()
        observeTokenState()
    }
    func handleUserState(_ user:User?) {
        guard user != nil else {
            print("Calling signout sequence")
//            AuthenticationService.shared.callSignOutSequence()
            return
        }
        print("Firebase User exists:\(String(describing: user))")
    }
    func observeAuthenticationState() {
        authenticationStateListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("AUTH STATE LISTENER")
            self.handleUserState(user)
        }
    }
    func removeAuthenticationStateObserver() {
        if let listener = authenticationStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
            authenticationStateListener = nil
        }
    }
    func observeTokenState() {
        tokenStateListener = Auth.auth().addIDTokenDidChangeListener { (auth, user) in
            if user == nil {
                print("Token Did Change")
            } else {
                print("Token Stable")
            }
        }
    }
    func removeTokenStateObserver() {
        if let listener = tokenStateListener {
            Auth.auth().removeIDTokenDidChangeListener(listener)
            tokenStateListener = nil
        }
    }
    /*
    func getCurrentToken(completion: @escaping (String?, Error?) -> ()) {
        let user = Auth.auth().currentUser
        handleUserState(user)
        user?.getIDToken(completion: { (token, error) in
            if let token = token {
                DispatchQueue.main.async {
                    completion(token, nil)
                }
            } else if let err = error {
                print("Error fetching token: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, err)
                }
            }
                /*
            else {
                print("getCurrentToken: Failed to unwrap optional")
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
            */
        })
    }
    */
    func getCurrentToken(completion: @escaping (String?, FirebaseError?) -> Void) {
        let user = Auth.auth().currentUser
        handleUserState(user)
        user?.getIDToken(completion: { (token, error) in
            if let token = token {
                DispatchQueue.main.async {
                    completion(token, nil)
                }
            } else if let err = error {
                print("Error fetching token: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, .noIDToken(err))
                }
            }
        })
    }
    func getCurrentToken(completion: @escaping FirebaseTokenFetchCompletion) {
        if let user = Auth.auth().currentUser {
            user.getIDToken(completion: { (token, error) in
                if let token = token {
                    
                    DispatchQueue.main.async {
                        completion(.success(token))
                    }
                } else if let err = error {
                    #if !RELEASE
                    print("Error fetching token: \(err.localizedDescription)")
                    #endif
                    DispatchQueue.main.async {
                        completion(.failure(.noIDToken(err)))
                    }
                } else {
                    #if !RELEASE
                    print("Error fetching token: Unknown Error")
                    #endif
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                }
            })
        } else {
            #if !RELEASE
            print("Failed to unwrap Firebase Current User. Error: \(FirebaseError.noCurrentUser.localizedDescription)")
            #endif
         
            defer {
//                AuthenticationService.shared.callSignOutSequence()
            }
            DispatchQueue.main.async {
               if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
                  let tabBarController = window.rootViewController as? TabBarController {
                  tabBarController.presentLogin()
               }
                completion(.failure(.noCurrentUser))
            }
        }
    }
    func getCurrentToken() -> String? {
        let user = Auth.auth().currentUser
        handleUserState(user)
        var firebaseAuthToken:String?
        user?.getIDToken(completion: { (token, _ ) in
            if let token = token {
                firebaseAuthToken = token
                print("Token exists")
            }
        })
        print("Token check: \(String(describing: firebaseAuthToken))")
        return firebaseAuthToken
    }
    /*
    func monitorAndSaveToken() {
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            if let err = error {
                print("Error fetching token: \(err)")
            } else if let token = token {
                print("Current Token: \(token)")
                UserDefaults.standard.updateToken(token: token)
            }
        })
    }
    */
    /*
    func monitorAndSaveRemoteToken() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID: \(result.instanceID)")
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.setToken(token: result.token)
            }
        }
    }
    */
    func removeObservers() {
        removeAuthenticationStateObserver()
        removeTokenStateObserver()
    }
    //MARK: SIGNOUT
    typealias SignoutCompletion = (Error?) -> ()
    func signOut(completion: @escaping SignoutCompletion) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            removeObservers()
            DispatchQueue.main.async {
                completion(nil)
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            DispatchQueue.main.async {
                completion(signOutError)
            }
        }
    }
}
