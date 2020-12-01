//
//  UserProfileDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 11/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
extension SettingsViewController {
    
    
    // MARK: New API Implementation Standard
    
    internal func updateUserProfile() {
        DispatchQueue.main.async {
            self.updateButton.isHidden = true
            self.spinner.startAnimating()
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
    
        guard let first_name = self.firstNameTextField.text,
            let last_name = self.lastNameTextField.text,
            let user_email = self.emailTextField.text,
            let phone_number = self.phoneNumberTextField.text,
            let backup_email = self.contactEmailTextField.text,
            let user_address = self.addressTextField.text,
            !first_name.isBlank,
            !last_name.isBlank,
            phone_number.extractNumbers.isPhoneNumberLengthValid(),
            backup_email.isValidEmailAddress(),
            !user_address.isBlank else {
                DispatchQueue.main.async {
                    self.updateButton.isHidden = false
                    self.spinner.stopAnimating()
                    TapticEngine.generateFeedback(ofType: .Error)
                    UIAlertController.showTelaAlert(title: "Error", message: "Missing Data", controller: self)
                }
                return
        }
        let purePhoneNumber = "+1\(phone_number.extractNumbers)"
        let profile_image = self.profileImage ?? ""
        let profile_image_url = self.profileImageUrl ?? ""
        
        let operation = UpdateUserProfileOnServer_Operation(address: user_address,
                                                            backupEmail: backup_email,
                                                            email: user_email,
                                                            firstName: first_name,
                                                            lastName: last_name,
                                                            phoneNumber: purePhoneNumber,
                                                            profileImage: profile_image,
                                                            profileImageUrl: profile_image_url)
        
        operation.completionBlock = { [weak self] in
            switch operation.result {
                case .success:
                    self?.handleUserProfileUpdationWithSuccess()
                case let .failure(error):
                    self?.handleUpdateUserProfileFaliure(error: error)
                case .none:
                    fatalError("Update User Profile Operation Result Invalid case. This needs to be handled.")
            }
        }
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        
        /*
        struct Body:Codable {
            let company_id:String
            let address:String
            let backup_email:String
            let email:String
            let name:String
            let last_name:String
            let phone_number:String
            let profile_image:String
            let profile_image_url:String
        }
        let body = Body(company_id: String(companyId), address: user_address, backup_email: backup_email, email: user_email, name: first_name, last_name: last_name, phone_number: phone_number, profile_image: profile_image, profile_image_url: profile_image_url)
        let httpBody = try! JSONEncoder().encode(body)
        let params:[String:String] = ["company_id":String(companyId)]
        let headers = [
            HTTPHeader(key: .contentType, value: "application/json"),
            HTTPHeader(key: .xRequestedWith, value: "XMLHttpRequest")
        ]
        */
    }
    
    private func handleUserProfileUpdationWithSuccess() {
        DispatchQueue.main.async {
            self.updateButton.isHidden = false
            self.spinner.stopAnimating()
            self.fetchUserProfile()
            TapticEngine.generateFeedback(ofType: .Success)
            AssertionModalController(title: "Updated").show()
        }
    }
    private func handleUpdateUserProfileFaliure(error: APIService.APIError) {
        #if !RELEASE
        print("***Error Updating User Profile****\n\(error.localizedDescription)")
        #endif
        DispatchQueue.main.async {
            TapticEngine.generateFeedback(ofType: .Error)
            self.updateButton.isHidden = false
            self.spinner.stopAnimating()
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, controller: self)
        }
    }
    
    
    
    
    
    
    
    internal func fetchUserProfile() {
        DispatchQueue.main.async {
            self.updateButton.isHidden = true
            self.spinner.startAnimating()
        }
        let companyId = AppData.companyId
        let params:[String:String] = ["company_id":String(companyId)]
        APIServer<UserJSON>(apiVersion: .v2).hitEndpoint(endpoint: .SignIn, httpMethod: .POST, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: userProfileFetchCompletion)
//        APIService.shared.hit(endpoint: .SignIn, httpMethod: .POST, params: params, guardResponse: .OK) { (result: Result<UserJSON, APIService.APIError>) in
//            switch result {
//                case let .success(data): self.handleFetchUserProfileWithSuccess(userData: data)
//                case let .failure(error): self.handleFetchUserProfileFaliure(error: error)
//            }
//        }
    }
    
    private func userProfileFetchCompletion(result: Result<UserJSON, APIService.APIError>) {
        switch result {
            case let .success(data): self.handleFetchUserProfileWithSuccess(userData: data)
            case let .failure(error): self.handleFetchUserProfileFaliure(error: error)
        }
    }
    
    private func handleFetchUserProfileWithSuccess(userData: UserJSON) {
       guard let userObject = userData.userDetails,
            let userId = userObject.id,
            let userRole = userObject.role,
            let roleId = userRole.id,
            let companyId = userObject.company,
            let workerId = userObject.workerId else {
                print("Company ID and worker Id - nil")
                DispatchQueue.main.async {
                    self.updateButton.isHidden = false
                    self.spinner.stopAnimating()
                    UIAlertController.showTelaAlert(title: "Error", message: "Response Data does not have necessary data. Please try again or contact support.", controller: self)
                }
                return
        }
        self.setAppPreferences(userId, companyId, workerId, roleId, userObject)
        
        DispatchQueue.main.async { [self] in
            userProfile = userData.userDetails
            updateButton.isHidden = false
            spinner.stopAnimating()
        }
    }
    private func handleFetchUserProfileFaliure(error: APIService.APIError) {
        #if !RELEASE
        print("***Error Updating Password****\n\(error.localizedDescription)")
        #endif
        DispatchQueue.main.async {
            self.updateButton.isHidden = false
            self.spinner.stopAnimating()
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, controller: self)
        }
    }
    
    
    
    
    fileprivate func setAppPreferences(_ userId:Int, _ companyId:Int, _ workerId:Int, _ roleId:Int, _ userInfo: UserProperties) {
        AppData.userId = userId
        AppData.companyId = companyId
        AppData.workerId = workerId
        AppData.roleId = roleId
        AppData.userInfo = userInfo
    }
}
