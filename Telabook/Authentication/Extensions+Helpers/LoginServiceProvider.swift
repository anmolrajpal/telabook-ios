//
//  LoginServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension LoginViewController {
    func signInWithCredentials(email:String, password:String) {
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
                DispatchQueue.main.async {
                    self.stopButtonSpinner()
                    self.delegate?.didLoginIWithSuccess()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    func handleLoginFailure(error: APIService.APIError) {
        DispatchQueue.main.async {
            self.stopButtonSpinner()
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, controller: self)
        }
    }
    
    
    

    
    internal func fetchTokenAndLogin(_ emailId:String, _ password:String) {
        FirebaseAuthService.shared.authenticateAndFetchToken(email: emailId, password: password) { (token, error) in
            if let err = error {
                print("Error Catched at Firebase Token Completion => \(err.localizedDescription)")
                DispatchQueue.main.async {
                    self.stopButtonSpinner()
                    UIAlertController.showTelaAlert(title: "Error", message: error?.localizedDescription ?? "Authentication Error. Please try again ", controller: self)
                }
            }
            if let t = token {
                guard t != "" else {
                    print("Error: Empty token String")
                    DispatchQueue.main.async {
                        self.stopButtonSpinner()
                        UIAlertController.showTelaAlert(title: "Service Error", message: "Service Authentication error occured. Please try again", controller: self)
                    }
                    return
                }
                print("Token => \(t)")
                self.token = t
                self.loginAndFetchUser(token: t)
            }
        }
    }
    
    
    
    

    internal func loginAndFetchUser(token:String) {
        AuthenticationService.shared.authenticateViaToken(token: token) { (data, serviceError, error) in
            guard serviceError == nil else {
                if let err = serviceError {
                    print(err)
                    switch err {
                    
                    case .FailedRequest:
                        DispatchQueue.main.async {
                            self.stopButtonSpinner()
                            UIAlertController.showTelaAlert(title: "Request Timed Out", message: error?.localizedDescription ?? "Please try again later", controller: self)
                        }
                    case .InvalidResponse:
                        DispatchQueue.main.async {
                            self.stopButtonSpinner()
                            UIAlertController.showTelaAlert(title: "Invalid Response", message: error?.localizedDescription ?? "Please try again", controller: self)
                        }
                    case .Unknown:
                        DispatchQueue.main.async {
                            self.stopButtonSpinner()
                            UIAlertController.showTelaAlert(title: "Some Error Occured", message: error?.localizedDescription ?? "An unknown error occured. Please try again later.", controller: self)
                        }
                    case .Internal:
                        DispatchQueue.main.async {
                            self.stopButtonSpinner()
                            UIAlertController.showTelaAlert(title: "Internal Error Occured", message: error?.localizedDescription ?? "An internal error occured. Please try again later.", controller: self)
                        }
                    }
                }
                return
            }
            if let userData = data {
                self.userInfo = userData
                guard let userObject = userData.user,
                    let userId = userObject.id,
                    let userRole = userData.roles,
                    let roleId = userRole.first?.id,
                    let companyId = userObject.company,
                    let workerId = userObject.workerId else {
                        print("Company ID and worker Id - nil")
                        DispatchQueue.main.async {
                            self.stopButtonSpinner()
                            UIAlertController.showTelaAlert(title: "Error", message: "Error while saving login info. Please try logging in again", controller: self)
                        }
                        return
                }
                print(userObject)
                print("Signing in - USER: \(userObject.name ?? "") \(userObject.lastName ?? "") \nRole ID => \(roleId)")
                self.setAppPreferences(userId, companyId, workerId, roleId, userData)
                DispatchQueue.main.async {
                    self.stopButtonSpinner()
                    self.delegate?.didLoginIWithSuccess()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    fileprivate func setAppPreferences(_ userId:Int, _ companyId:Int, _ workerId:Int, _ roleId:Int, _ userInfo: UserInfoCodable) {
        let emailId = idTextField.text!, password = passwordTextField.text!
        AppData.isRememberMeChecked = self.checkBox.isChecked
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
            self.stopButtonSpinner()
            self.delegate?.didLoginIWithSuccess()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
