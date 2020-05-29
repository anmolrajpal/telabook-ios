//
//  ChangePasswordDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 15/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
extension ChangePasswordViewController {
    
    // MARK: Using new API standard implementation
    internal func updatePassword(currentPassword:String, newPassword:String, confirmationPassword:String) {
        let companyId = String(AppData.companyId)
        DispatchQueue.main.async {
            self.view.endEditing(true)
            UIAlertController.showModalSpinner(with: "Updating...", controller: self)
        }
        struct Body:Codable {
            let company_id:String
            let current_password:String
            let password:String
            let password_confirmation:String
        }
        let body = Body(company_id: companyId, current_password: currentPassword, password: newPassword, password_confirmation: confirmationPassword)
        let httpBody = try! JSONEncoder().encode(body)
        let params:[String:String] = ["company_id":companyId]
        let headers = [
            HTTPHeader(key: .contentType, value: "application/json"),
            HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
        ]
        APIService.shared.hit(endpoint: .UpdatePassword, httpMethod: .POST, params: params, httpBody: httpBody, headers: headers, guardResponse: .Created, expectData: false) { (result: Result<APIService.EmptyData, APIService.APIError>) in
            switch result {
                case .success: self.handlePasswordUpdationWithSuccess()
                case let .failure(error): self.handleUpdatePasswordFaliure(error: error)
            }
        }
    }
    internal func handlePasswordUpdationWithSuccess() {
        DispatchQueue.main.async {
            UIAlertController.dismissModalSpinner(controller: self, completion: {
                AssertionModalController(title: "Updated").show(completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            })
        }
    }
    internal func handleUpdatePasswordFaliure(error: APIService.APIError) {
        DispatchQueue.main.async {
            #if !RELEASE
            print("***Error Updating Password****\n\(error.localizedDescription)")
            #endif
            UIAlertController.dismissModalSpinner(controller: self, completion: {
                UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, controller: self)
            })
        }
    }
    
    
    
    
    // MARK: Old API implementation
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
