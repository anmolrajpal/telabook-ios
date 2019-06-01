//
//  FirebaseAuthService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import Foundation
import Firebase
final class FirebaseAuthService:NSObject {
    static let shared = FirebaseAuthService()
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
    typealias SignoutCompletion = (Error?) -> ()
    func signOut(completion: @escaping SignoutCompletion) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
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
