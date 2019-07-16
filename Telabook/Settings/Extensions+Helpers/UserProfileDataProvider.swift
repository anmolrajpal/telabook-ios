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
        UserProfileAPI.shared.fetchUserProfile(token: token, userId: userId) { (responseStatus, data, serviceError, error) in
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
    
    
    
    internal func initiateUpdateUserProfileSequence() {
        DispatchQueue.main.async {
            self.disableUpdateButton()
            UIAlertController.showModalSpinner(with: "Updating...", controller: self)
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                        self.enableUpdateButton()
                    })
                    
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    self.updateUserProfile(token)
                }
            }
        }
    }
    fileprivate func updateUserProfile(_ token:String) {
        let userId = UserDefaults.standard.currentSender.id
        guard let first_name = self.firstNameTextField.text,
            let last_name = self.lastNameTextField.text,
            let user_email = self.emailTextField.text,
            let phone_number = self.phoneNumberTextField.text,
            let backup_email = self.contactEmailTextField.text,
            let user_address = self.addressTextField.text,
            !first_name.isEmpty, !last_name.isEmpty, !user_email.isEmpty, !phone_number.isEmpty, !backup_email.isEmpty, !user_address.isEmpty else {
                print("Missing Data")
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: "Missing Data", controller: self)
                        self.enableUpdateButton()
                    })
                    
                }
                return
        }
        let profile_image = self.profileImage ?? ""
        let profile_image_url = self.profileImageUrl ?? ""
            
        
        UserProfileAPI.shared.updateUserProfile(token: token, userId: userId, email: user_email, firstName: first_name, lastName: last_name, phoneNumber: phone_number, backupEmail: backup_email, address: user_address, profileImage: profile_image, profileImageURL: profile_image_url) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Updating User Profile****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                        self.enableUpdateButton()
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Updating User Profile****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                        self.enableUpdateButton()
                    })
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Error Updating User Profile****\nInvalid Response: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                            self.enableUpdateButton()
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                }
                print("User Profile Updated Successfully")
            }
        }
    }
}
