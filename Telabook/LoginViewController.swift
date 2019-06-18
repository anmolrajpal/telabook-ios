//
//  LoginViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import MessageKit
class LoginViewController: UIViewController {
    var token:String?
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .telaGray1
        hideKeyboardWhenTappedAround()
        observeKeyboardNotifications()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(loginHeadingLabel)
        view.addSubview(idTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loginButton)
        loginButton.addSubview(spinner)
    }
    private func setupConstraints() {
        logoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: view.frame.height / 6, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 0)
        loginHeadingLabel.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 60, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        idTextField.anchor(top: loginHeadingLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 60, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        passwordTextField.anchor(top: idTextField.bottomAnchor, left: idTextField.leftAnchor, bottom: nil, right: idTextField.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        forgotPasswordButton.anchor(top: passwordTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.anchor(top: forgotPasswordButton.bottomAnchor, left: passwordTextField.leftAnchor, bottom: nil, right: passwordTextField.rightAnchor, topConstant: 30, leftConstant: 25, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 40)
        spinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalTo: loginButton.widthAnchor).isActive = true
        spinner.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
    }
    fileprivate func startSpinner() {
        spinner.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    fileprivate func stopSpinner() {
        spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true
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
    
    let spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        spinner.backgroundColor = UIColor.telaBlue
        spinner.hidesWhenStopped = true
        spinner.clipsToBounds = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    let logoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "logo")
//        imageView.clipsToBounds = true
//        imageView.layer.masksToBounds = false
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }()
    let loginHeadingLabel:UILabel = {
        let label = UILabel()
        label.text = "LOGIN"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)
        label.textColor = UIColor.telaGray6
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let idTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Registered Email ID", attributes: [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7])
        textField.textColor = UIColor.telaWhite
        textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        textField.setIcon(#imageLiteral(resourceName: "email_icon"), position: .Left)
        textField.autocapitalizationType = .none
        textField.layer.borderColor = UIColor.telaGray5.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 15
        textField.keyboardType = UIKeyboardType.emailAddress
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.textContentType = UITextContentType.emailAddress
        textField.returnKeyType = UIReturnKeyType.next
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(idFieldDidReturn(textField:)), for: UIControl.Event.editingDidEndOnExit)
        textField.addTarget(self, action: #selector(idFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7])
        textField.textColor = UIColor.telaWhite
        textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        textField.setIcon(#imageLiteral(resourceName: "password_icon"), position: .Left)
        textField.setIcon(#imageLiteral(resourceName: "visible_icon"), position: .Right)
        textField.layer.borderColor = UIColor.telaGray5.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 15
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textContentType = UITextContentType.password
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.returnKeyType = UIReturnKeyType.go
        textField.addTarget(self, action: #selector(passwordFieldDidReturn(textField:)), for: UIControl.Event.editingDidEndOnExit)
        textField.addTarget(self, action: #selector(passwordFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        return textField
    }()
    @objc func idFieldDidReturn(textField: UITextField!) {
        self.passwordTextField.becomeFirstResponder()
    }
    @objc func passwordFieldDidReturn(textField: UITextField!) {
        textField.resignFirstResponder()
        self.login()
    }
    var isEmailValid = false
    var isPasswordValid = false
    @objc func idFieldDidChange(textField:UITextField!) {
        let emailId = textField.text
        isEmailValid = emailId?.isValidEmailAddress() ?? false
        handleValidationSequence(email: isEmailValid, password: isPasswordValid)
    }
    @objc func passwordFieldDidChange(textField:UITextField!) {
        let password = textField.text
        isPasswordValid = password?.count ?? 0 > 4
        handleValidationSequence(email: isEmailValid, password: isPasswordValid)
    }
    internal func handleValidationSequence(email:Bool, password:Bool) {
        loginButton.isEnabled = email && password
        loginButton.backgroundColor = loginButton.isEnabled ? UIColor.telaBlue : UIColor.telaGray5
    }
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("FORGOT PASSWORD?", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        button.setTitleColor(.telaGray7, for: .normal)
        //        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()
    @objc func handleForgotPassword() {
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
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.telaGray5
        button.setTitle("LOGIN", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)
        button.layer.borderColor = UIColor.telaBlue.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 15
        button.setTitleColor(.telaBlack, for: .normal)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    var userInfo:UserInfoCodable?
    @objc func handleLogin() {
        self.login()
    }
    
    final private func login() {
        view.endEditing(true)
        let emailId = idTextField.text!, password = passwordTextField.text!
        startSpinner()
        handleLoginSequence(emailId, password)
    }
    fileprivate func handleLoginSequence(_ emailId:String, _ password:String) {
        self.fetchTokenAndLogin(emailId, password)
    }
    fileprivate func fetchTokenAndLogin(_ emailId:String, _ password:String) {
        FirebaseAuthService.shared.authenticateAndFetchToken(email: emailId, password: password) { (token, error) in
            if let err = error {
                print("Error Catched at Firebase Token Completion => \(err.localizedDescription)")
                DispatchQueue.main.async {
                    self.stopSpinner()
                    UIAlertController.showTelaAlert(title: "Error", message: error?.localizedDescription ?? "Authentication Error. Please try again ", controller: self)
                }
            }
            if let t = token {
                guard t != "" else {
                    print("Error: Empty token String")
                    DispatchQueue.main.async {
                        self.stopSpinner()
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
    final private func loginAndFetchUser(token:String) {
        AuthenticationService.shared.authenticateViaToken(token: token) { (data, serviceError, error) in
            guard serviceError == nil else {
                if let err = serviceError {
                    print(err)
                    switch err {
                    
                    case .FailedRequest:
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            UIAlertController.showTelaAlert(title: "Request Timed Out", message: error?.localizedDescription ?? "Please try again later", controller: self)
                        }
                    case .InvalidResponse:
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            UIAlertController.showTelaAlert(title: "Invalid Response", message: error?.localizedDescription ?? "Please try again", controller: self)
                        }
                    case .Unknown:
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            UIAlertController.showTelaAlert(title: "Some Error Occured", message: error?.localizedDescription ?? "An unknown error occured. Please try again later.", controller: self)
                        }
                    case .Internal:
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            UIAlertController.showTelaAlert(title: "Internal Error Occured", message: error?.localizedDescription ?? "An internal error occured. Please try again later.", controller: self)
                        }
                    }
                }
                return
            }
            if let userData = data {
                self.userInfo = userData
                guard let userObject = userData.user,
                    let userRole = userData.roles,
                    let roleId = userRole.first?.id,
                    let companyId = userObject.company,
                    let workerId = userObject.workerId else {
                        print("Company ID and worker Id - nil")
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            UIAlertController.showTelaAlert(title: "Error", message: "Error while saving login info. Please try logging in again", controller: self)
                        }
                        return
                }
                print(userObject)
                let currentSender = Sender(id: String(userObject.id ?? 0), displayName: (!(userObject.lastName?.isEmpty ?? true)) ? "\(userObject.name ?? "nil") \(userObject.lastName ?? "nil")" : userObject.name ?? "nil")
                
                UserDefaults.standard.currentSender = currentSender

                
                print("Signing in - USER: \(userObject.name ?? "") \(userObject.lastName ?? "") \nRole ID => \(roleId)")
                self.setUserDefaults(token, companyId, workerId, roleId)
                DispatchQueue.main.async {
                    self.stopSpinner()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    fileprivate func setUserDefaults(_ token:String, _ companyId:Int, _ workerId:Int, _ roleId:Int) {
        let emailId = idTextField.text!, password = passwordTextField.text!
        UserDefaults.standard.setIsLoggedIn(value: true)
        UserDefaults.standard.setEmailId(emailId: emailId)
        UserDefaults.standard.setPassword(password: password)
        UserDefaults.standard.setToken(token: token)
        UserDefaults.standard.setCompanyId(companyId: companyId)
        UserDefaults.standard.setWorkerId(workerId: workerId)
        UserDefaults.standard.setRoleId(roleId: roleId)
    }
}

