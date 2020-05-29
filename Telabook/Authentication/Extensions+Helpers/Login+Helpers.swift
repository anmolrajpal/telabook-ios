//
//  Login+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension LoginViewController {
    internal func commonInit() {
        hideKeyboardWhenTappedAround()
        observeKeyboardNotifications()
        setupCheckbox()
        setupTargetActions()
        configureForgotPasswordAlertController()
    }
    private func setupTargetActions() {
        subview.loginButton.addTarget(self, action: #selector(loginButtonDidTap), for: .touchUpInside)
        subview.forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonDidTap), for: .touchUpInside)
        setupTextFields()
    }
    @objc private func loginButtonDidTap() {
        self.login()
    }
    
    
    
    // MARK: - Configure Textfilds
    private func setupTextFields() {
        subview.emailTextField.addTarget(self, action: #selector(emailTextFieldFieldDidReturn(_:)), for: UIControl.Event.editingDidEndOnExit)
        subview.emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        subview.passwordTextField.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEyeButtton)))
        subview.passwordTextField.addTarget(self, action: #selector(passwordFieldDidReturn(_:)), for: UIControl.Event.editingDidEndOnExit)
        subview.passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    @objc private func handleEyeButtton() {
        subview.passwordTextField.isSecureTextEntry = subview.passwordTextField.isSecureTextEntry ? false : true
    }
    @objc private func emailTextFieldFieldDidReturn(_ textField: UITextField!) {
        self.subview.passwordTextField.becomeFirstResponder()
    }
    @objc private func passwordFieldDidReturn(_ textField: UITextField!) {
        textField.resignFirstResponder()
        self.login()
    }
    @objc private func emailTextFieldDidChange(_ textField:UITextField!) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        /*
        let emailId = textField.text
        isEmailValid = emailId?.isValidEmailAddress() ?? false
        handleValidationSequence(email: isEmailValid, password: isPasswordValid)
        */
    }
    @objc private func passwordFieldDidChange(_ textField:UITextField!) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        /*
        let password = textField.text
        isPasswordValid = password?.count ?? 0 > 4
        handleValidationSequence(email: isEmailValid, password: isPasswordValid)
         */
    }
    private func handleValidationSequence(email:Bool, password:Bool) {
        subview.loginButton.isEnabled = email && password
        subview.loginButton.backgroundColor = subview.loginButton.isEnabled ? UIColor.telaBlue : UIColor.telaGray5
    }
    
    
    
    
    
    
    // MARK: - Configure Checkbox
    private func setupCheckbox() {
        self.subview.checkBox.isChecked = AppData.isRememberMeChecked
        if AppData.isRememberMeChecked {
            self.subview.emailTextField.text = AppData.email
            self.subview.passwordTextField.text = AppData.password
            self.subview.loginButton.isEnabled = true
            self.subview.loginButton.backgroundColor = UIColor.telaBlue
        }
    }
    
    
    
    
    
    
    // MARK: - Handle Login Tap Actions
    private func login() {
        self.performValidations { success in
            if success { self.initiateLoginSequence() }
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
    private func initiateLoginSequence() {
        view.endEditing(true)
        self.startButtonSpinner()
        let emailId = subview.emailTextField.text!
        let password = subview.passwordTextField.text!
        self.signInWithCredentials(email: emailId, password: password)
    }
    private func startButtonSpinner() {
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
    
    

    
    // MARK: - Keyboard Notifications
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
}




