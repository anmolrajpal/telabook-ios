//
//  ChangePasswordDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 15/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension ChangePasswordViewController {
    internal func initiateChangePasswordSequence(currentPassword:String, newPassword:String, confirmationPassword:String) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            UIAlertController.showModalSpinner(with: "Updating...", controller: self)
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
                    self.changePassword(token, currentPassword, newPassword, confirmationPassword)
                }
            }
        }
    }
    fileprivate func changePassword(_ token:String, _ currentPassword:String, _ newPassword:String, _ confirmationPassword:String) {
        ChangePasswordAPI.shared.changePassword(token: token, currentPassword: currentPassword, newPassword: newPassword, confirmationPassword: confirmationPassword) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Updating Password****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Updating Password****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Error Updating Password****\nInvalid Response: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        AssertionModalController(title: "Updated").show(completion: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    })
                }
            }
        }
    }
}
