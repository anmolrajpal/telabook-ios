//
//  Login+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension LoginViewController {
    internal func commonInit() {
        hideKeyboardWhenTappedAround()
        observeKeyboardNotifications()
        setupCheckbox()
        setupTargetActions()
    }
    private func setupTargetActions() {
        subview.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        subview.forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
    }
    private func setupTextFields() {
        subview.emailTextField.addTarget(self, action: #selector(idFieldDidReturn(textField:)), for: UIControl.Event.editingDidEndOnExit)
//        textField.addTarget(self, action: #selector(idFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        subview.passwordTextField.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEyeButtton)))
        subview.passwordTextField.addTarget(self, action: #selector(passwordFieldDidReturn(textField:)), for: UIControl.Event.editingDidEndOnExit)
//        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    @objc private func handleEyeButtton() {
        subview.passwordTextField.isSecureTextEntry = subview.passwordTextField.isSecureTextEntry ? false : true
    }
    @objc private func idFieldDidReturn(textField: UITextField!) {
        self.subview.passwordTextField.becomeFirstResponder()
    }
    @objc private func passwordFieldDidReturn(textField: UITextField!) {
        textField.resignFirstResponder()
        self.login()
    }
    @objc private func idFieldDidChange(textField:UITextField!) {
        let emailId = textField.text
        isEmailValid = emailId?.isValidEmailAddress() ?? false
        handleValidationSequence(email: isEmailValid, password: isPasswordValid)
    }
    @objc private func passwordFieldDidChange(textField:UITextField!) {
        let password = textField.text
        isPasswordValid = password?.count ?? 0 > 4
        handleValidationSequence(email: isEmailValid, password: isPasswordValid)
    }
    private func handleValidationSequence(email:Bool, password:Bool) {
        subview.loginButton.isEnabled = email && password
        subview.loginButton.backgroundColor = subview.loginButton.isEnabled ? UIColor.telaBlue : UIColor.telaGray5
    }
    
    @objc private func handleLogin() {
        self.login()
    }
    
    
    
    private func setupCheckbox() {
        self.subview.checkBox.isChecked = AppData.isRememberMeChecked
        if AppData.isRememberMeChecked {
            self.subview.emailTextField.text = AppData.email
            self.subview.passwordTextField.text = AppData.password
            self.subview.loginButton.isEnabled = true
            self.subview.loginButton.backgroundColor = UIColor.telaBlue
        }
    }
    internal func startButtonSpinner() {
        
        DispatchQueue.main.async {
            self.subview.loginButton.isHidden = true
            self.subview.spinner.startAnimating()
            self.view.isUserInteractionEnabled = false
        }
    }
    internal func stopButtonSpinner() {
        DispatchQueue.main.async {
            self.subview.loginButton.isHidden = false
            self.subview.spinner.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func performValidations(completion: @escaping (Bool) -> Void) {
        guard let emailID = subview.emailTextField.text,
            !emailID.isBlank, emailID.isValidEmailAddress() else {
                self.subview.emailTextField.shake(withFeedbackTypeOf: .Heavy)
                completion(false)
                return
        }
        guard let password = subview.passwordTextField.text,
            !password.isBlank, password.count >= 1 else {
                self.subview.passwordTextField.shake(withFeedbackTypeOf: .Heavy)
                completion(false)
                return
        }
        completion(true)
    }
    final private func login() {
        self.performValidations { success in
            if success { self.initiateLoginSequence() }
        }
    }
    fileprivate func initiateLoginSequence() {
        view.endEditing(true)
        self.startButtonSpinner()
        let emailId = subview.emailTextField.text!
        let password = subview.passwordTextField.text!
        self.signInWithCredentials(email: emailId, password: password)
    }
    
    
    
    
    
    
    
    
    @objc private func handleForgotPassword() {
        showForgotPasswordDialogBox()
    }
    
    fileprivate func showForgotPasswordDialogBox() {
        let alertVC = UIAlertController(title: "", message: "\n", preferredStyle: UIAlertController.Style.alert)
        let attributedString = NSAttributedString(string: "FORGOT PASSWORD", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)!, //your font here
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
        ])
        alertVC.setValue(attributedString, forKey: "attributedTitle")
        alertVC.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        
        alertVC.view.tintColor = UIColor.telaBlue
        alertVC.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alertVC.view.subviews.first?.backgroundColor = .clear
        alertVC.addTextField { (textField) in
            textField.placeholder = "Enter Registered Email ID"
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
            //            textField.layer.borderColor = UIColor.telaGray5.cgColor
            //            textField.layer.borderWidth = 1
            //            textField.layer.cornerRadius = 5
            //            textField.clipsToBounds = true
            textField.keyboardType = UIKeyboardType.emailAddress
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.textContentType = UITextContentType.emailAddress
            textField.returnKeyType = UIReturnKeyType.go
            
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        }
        
        
        //        alertVC.textFields?[0].tintColor = .yellow
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
        let submitAction = UIAlertAction(title: "SUBMIT", style: UIAlertAction.Style.default) { (action) in
            let emailId = alertVC.textFields?[0].text
            print("Forgotten Email ID => \(emailId ?? "nil")")
            if let email = emailId,
                !email.isEmpty {
                self.initiateForgotPasswordSequence(for: email)
            }
        }
        submitAction.isEnabled = false
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
        self.present(alertVC, animated: true, completion: nil)
        alertVC.textFields?[0].superview?.backgroundColor = .telaGray5
    }
    @objc func alertTextFieldDidChange(textField: UITextField!) {
        let alertController = self.presentedViewController as? UIAlertController
        if let ac = alertController {
            let submitAction = ac.actions.last
            let textField = ac.textFields?.first
            submitAction?.isEnabled = textField?.text?.isValidEmailAddress() ?? false
        }
    }
    
    fileprivate func initiateForgotPasswordSequence(for email:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Requesting...", controller: self)
        }
        AuthenticationService.shared.forgotPassword(for: email) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Sending Forgot Password Request****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Sending Forgot Password Request****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    DispatchQueue.main.async {
                        print("***Error Sending Forgot Password Request****\nInvalid Response: \(status)")
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                                let message = json["message"] as? String ?? "Invalid Response\nStatus => \(status)"
                                UIAlertController.dismissModalSpinner(controller: self, completion: {
                                    UIAlertController.showTelaAlert(title: "Error", message: message, controller: self)
                                })
                            } catch let err {
                                fatalError("Error decoding JSON: \(err.localizedDescription)")
                            }
                        } else {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Error", message: "Invalid Response\nStatus => \(status)", controller: self)
                            })
                        }
                    }
                    return
                }
                DispatchQueue.main.async {
                    print("***Forgot Password Request Success***")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Success", message: "Request successfuly sent. Please check your mail & follow the instructions.", controller: self)
                    })
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                        let dict = json["data"] as! [String:Any]
                        let token = dict["token"] as? String ?? "token: nil"
                        //handle forgot password token
                        print("Forgot Password Token => \(token)")
                    } catch let err {
                        print(print("Error decoding JSON: \(err.localizedDescription)"))
                    }
                }
            }
        }
    }
    
    
    
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    @objc func keyboardShow() {
        let iPhoneKeyboardHeight:CGFloat = 100
        let iPadKeyboardHeight:CGFloat = 100
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -iPadKeyboardHeight : -iPhoneKeyboardHeight
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
