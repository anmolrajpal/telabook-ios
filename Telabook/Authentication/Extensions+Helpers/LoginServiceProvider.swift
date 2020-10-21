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
        APIService.shared.loginWithCredentials(email: email, password: password, params: nil, decoder: .apiServiceDecoder) { (result: Result<UserJSON, APIService.APIError>) in
            switch result {
            case let .success(data): self.handleLoginWithSuccess(userInfo: data)
            case let .failure(error): self.handleLoginFailure(error: error)
            }
        }
    }
    func handleLoginWithSuccess(userInfo: UserJSON) {
        guard userInfo.result == .success else {
            let message = userInfo.message ?? "Service Error. Please try again in a while."
            printAndLog(message: "Login Result Failure with message: \(message)", log: .network, logType: .error)
            showMessage(message: message)
            return
        }
        
        guard let userObject = userInfo.userDetails else {
            printAndLog(message: "Failed to decode UserDetails where object: \(userInfo)", log: .network, logType: .error)
            showMessage(message: "Data corrupted. Please report this bug.")
            return
        }
        printAndLog(message: "Successfully Decode User Details from USER JSON. =>>\n\n\(userObject)", log: .network, logType: .info, isPrivate: true)
        guard let userId = userObject.id else {
            printAndLog(message: "Failed to decode user id from UserInfoCodable object while logging in.", log: .network, logType: .error)
            showMessage(message: "Error while saving login info. Please try again.")
            return
        }
        guard let userRole = userObject.role else {
            printAndLog(message: "Failed to decode userRole from UserInfoCodable object while logging in.", log: .network, logType: .error)
            showMessage(message: "Error while saving login info. Please try again.")
            return
        }
        guard let roleId = userRole.id else {
            printAndLog(message: "Failed to decode Role ID from Role object while logging in.", log: .network, logType: .error)
            showMessage(message: "Error while saving login info. Please try again.")
            return
        }
        guard let companyId = userObject.company else {
            printAndLog(message: "Failed to decode company ID from UserInfoCodable object while logging in.", log: .network, logType: .error)
            showMessage(message: "Error while saving login info. Please try again.")
            return
        }
        guard let workerId = userObject.workerId else {
            printAndLog(message: "Failed to decode worker Id from UserInfoCodable object while logging in.", log: .network, logType: .error)
            showMessage(message: "Error while saving login info. Please try again.")
            return
        }
        
        self.setAppPreferences(userId, companyId, workerId, roleId, userObject)
        
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
    func showMessage(message: String) {
        DispatchQueue.main.async {
            self.stopButtonSpinner()
            UIAlertController.showTelaAlert(title: "Error", message: message, controller: self)
        }
    }
    func handleLoginFailure(error: APIService.APIError) {
        TapticEngine.generateFeedback(ofType: .Error)
        DispatchQueue.main.async {
            self.stopButtonSpinner()
            UIAlertController.showTelaAlert(title: "Error", message: error.publicDescription, controller: self)
        }
    }
    
    
    
    fileprivate func setAppPreferences(_ userId:Int, _ companyId:Int, _ workerId:Int, _ roleId:Int, _ userInfo: UserProperties) {
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
