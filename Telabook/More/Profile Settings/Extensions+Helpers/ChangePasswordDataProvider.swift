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
    
    
    
    
    
}
