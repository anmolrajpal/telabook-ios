//
//  LoginView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
    // MARK: - Init
    private func setupViews() {
        backgroundColor = .telaGray1
        addSubview(logoImageView)
        addSubview(loginHeadingLabel)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(checkBox)
        addSubview(rememberMeLabel)
        addSubview(forgotPasswordButton)
        addSubview(loginButton)
        addSubview(spinner)
        layoutConstraints()
    }
    private func layoutConstraints() {
        logoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: frame.height / 7, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 0)
        
        
        loginHeadingLabel.anchor(top: logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 40, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
        emailTextField.anchor(top: loginHeadingLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 40, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        
        
        checkBox.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 25)
        
        
        rememberMeLabel.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor).isActive = true
        rememberMeLabel.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10).isActive = true
        
        
        forgotPasswordButton.anchor(top: rememberMeLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        forgotPasswordButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        
        loginButton.anchor(top: forgotPasswordButton.bottomAnchor, left: passwordTextField.leftAnchor, bottom: nil, right: passwordTextField.rightAnchor, topConstant: 30, leftConstant: 25, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 40)
        
        
        spinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
    }
    
    
    
    // MARK: - Constructors
    
    lazy var spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinner.color = UIColor.telaGray7
        spinner.backgroundColor = UIColor.clear
        spinner.hidesWhenStopped = true
        spinner.clipsToBounds = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    lazy var logoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "logo")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }()
    lazy var loginHeadingLabel:UILabel = {
        let label = UILabel()
        label.text = "LOGIN"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)
        label.textColor = UIColor.telaGray6
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var emailTextField: UITextField = {
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

        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7])
        textField.textColor = UIColor.telaWhite
        textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        textField.setIcon(#imageLiteral(resourceName: "password_icon"), position: .Left)
        textField.setIcon(#imageLiteral(resourceName: "visible_icon"), position: .Right)
        
        textField.rightView?.isUserInteractionEnabled = true
        
        textField.layer.borderColor = UIColor.telaGray5.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 15
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textContentType = UITextContentType.password
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.keyboardType = UIKeyboardType.asciiCapable
        textField.returnKeyType = UIReturnKeyType.go
        return textField
    }()
    
    
    
    
    lazy var checkBox: Checkbox = {
        let checkbox = Checkbox(type: .custom)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.tintColor = UIColor.telaBlue
        return checkbox
    }()
    
    let rememberMeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Remember Me"
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)
        return label
    }()
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("FORGOT PASSWORD?", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        button.setTitleColor(.telaGray7, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.telaBlack, for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = UIColor.telaBlue
        return button
    }()
    
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
