//
//  UserProfileDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 11/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension SettingsViewController {
    internal func initiateFetchUserProfileSequence(userId:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Loading...", controller: self)
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                    
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    self.fetchUserProfile(token:token, userId: userId)
                }
            }
        }
    }
    fileprivate func fetchUserProfile(token:String, userId:String) {
        AutoResponseAPI.shared.fetchAutoResponseSettings(token: token, userId: userId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching User Profile****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching User Profile****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    DispatchQueue.main.async {
                        print("***Error Fetching User Profile****\nInvalid Response: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Invalid Response: Status => \(status)", controller: self)
                        })
                    }
                    return
                }
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(UserProfileCodable.self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                print(result)
                                self.userProfile = result
                            })
                        }
                    } catch let err {
                        print("Error: Unable to decode data. => \(err.localizedDescription)")
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                            })
                        }
                    }
                }
            }
        }
    }
}
