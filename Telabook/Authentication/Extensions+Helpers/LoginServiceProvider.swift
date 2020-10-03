//
//  LoginServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/04/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension LoginViewController {
    func signInWithCredentials(email:String, password:String) {
        TapticEngine.generateFeedback(ofType: .Medium)
        APIService.shared.loginWithCredentials(email: email, password: password, params: nil) { (result: Result<UserInfoCodable?, APIService.APIError>) in
            switch result {
                case let .success(data): self.handleLoginWithSuccess(userInfo: data)
                case let .failure(error): self.handleLoginFailure(error: error)
            }
        }
    }
    func handleLoginWithSuccess(userInfo: UserInfoCodable?) {
        if let userInfo = userInfo {
            guard let userObject = userInfo.user,
                let userId = userObject.id,
                let userRole = userObject.role,
                let roleId = userRole.id,
                let companyId = userObject.company,
                let workerId = userObject.workerId else {
                    print("Company ID and worker Id - nil")
                    DispatchQueue.main.async {
                        self.stopButtonSpinner()
                        UIAlertController.showTelaAlert(title: "Error", message: "Error while saving login info. Please try logging in again", controller: self)
                    }
                    return
            }
            
            self.setAppPreferences(userId, companyId, workerId, roleId, userInfo)
            
            let appUserRole:AppUserRole = AppUserRole.getUserRole(byRoleCode: roleId)
            
            if appUserRole == .Developer {
                #if !RELEASE
                print("User is able to select company because the role is \(appUserRole)")
                #endif
                let vc = SelectCompanyViewController()
                vc.isModalInPresentation = true
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            } else {
                #if !RELEASE
                print("User Does not need to select company, proceeding with login with the user of role: \(appUserRole)")
                #endif
                TapticEngine.generateFeedback(ofType: .Success)
                DispatchQueue.main.async {
                    self.stopButtonSpinner()
                    self.delegate?.didLoginIWithSuccess()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    func handleLoginFailure(error: APIService.APIError) {
        TapticEngine.generateFeedback(ofType: .Error)
        DispatchQueue.main.async {
            self.stopButtonSpinner()
            UIAlertController.showTelaAlert(title: "Error", message: error.publicDescription, controller: self)
        }
    }
    
    
    
    fileprivate func setAppPreferences(_ userId:Int, _ companyId:Int, _ workerId:Int, _ roleId:Int, _ userInfo: UserInfoCodable) {
        let emailId = subview.emailTextField.text!, password = subview.passwordTextField.text!
        AppData.isRememberMeChecked = self.subview.checkBox.isChecked
        AppData.userId = userId
        AppData.email = emailId
        AppData.password = password
        AppData.companyId = companyId
        AppData.workerId = workerId
        AppData.roleId = roleId
        AppData.userInfo = userInfo
        AppData.isLoggedIn = true
    }
}


extension LoginViewController: SelectCompanyDelegate {
    func didSelectCompany() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            TapticEngine.generateFeedback(ofType: .Success)
            self.stopButtonSpinner()
            self.delegate?.didLoginIWithSuccess()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
