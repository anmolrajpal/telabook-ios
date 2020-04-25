//
//  FirebaseAuthService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import Firebase
import UIKit
final class FirebaseAuthService:NSObject {
    static let shared = FirebaseAuthService()
    var authenticationStateListener:AuthStateDidChangeListenerHandle?
    var tokenStateListener:IDTokenDidChangeListenerHandle?
    
    typealias TokenFetchCompletion = (String?, Error?) -> ()
    func authenticateAndFetchToken(email:String, password:String, completion: @escaping TokenFetchCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard self != nil else { return }
            if let err = error {
                print("Error Catched at Firebase Auth => \(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, err)
                }
            }
            if let data = user {
                data.user.getIDToken(completion: { (token, err) in
                    if let e = err {
                        print("Error Catched at Firebase Fetch Id => \(e.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(nil, e)
                        }
                    }
                    if let t = token {
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
            AuthenticationService.shared.callSignOutSequence()
            return
        }
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
