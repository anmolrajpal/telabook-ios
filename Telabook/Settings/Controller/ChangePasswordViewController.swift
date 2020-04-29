//
//  ChangePasswordViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 15/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "CHANGE PASSWORD"
    }
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupNavBarItems()
        setupTextFields()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let saveButton:UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        button.isEnabled = false
        button.setTitleTextAttributes([
            .font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)!,
            .foregroundColor: UIColor.telaBlue
            ], for: .normal)
        button.setTitleTextAttributes([
            .font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)!,
            .foregroundColor: UIColor.telaGray6
            ], for: .disabled)
        return button
    }()
    fileprivate func setupNavBarItems() {
        navigationItem.rightBarButtonItems = [saveButton]
    }
    @objc func saveButtonTapped() {
        print("Updating Password")
        updatePassword()
    }
    fileprivate func enableSaveButton() {
        saveButton.isEnabled = true
    }
    fileprivate func disableSaveButton() {
        saveButton.isEnabled = false
    }
    fileprivate func updatePassword() {
        guard let currentPassword = self.currentPasswordTextField.text,
            let newPassword = self.newPasswordTextField.text,
            let confirmationPassword = self.confirmPasswordTextField.text,
            !currentPassword.isEmpty, !newPassword.isEmpty, !confirmationPassword.isEmpty else {
                fatalError("Failed to unwrap text or empty text")
        }
        guard newPassword != currentPassword else {
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Your new password and current password cannot be same", controller: self)
            }
            return
        }
        guard newPassword == confirmationPassword else {
            DispatchQueue.main.async {
                UIAlertController.showTelaAlert(title: "Error", message: "Passwords do not match", controller: self)
            }
            return
        }
//        self.initiateChangePasswordSequence(currentPassword: currentPassword, newPassword: newPassword, confirmationPassword: confirmationPassword)
        self.updatePassword(currentPassword: currentPassword, newPassword: newPassword, confirmationPassword: confirmationPassword)
    }
    
    func setupViews() {
        setupSubviews()
    }
    func setupConstraints() {
        setupSubviewsConstraints()
    }
    fileprivate func setupTextFields() {
        currentPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        currentPasswordTextField.addTarget(self, action: #selector(validateTextFields), for: .editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(validateTextFields), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(validateTextFields), for: .editingChanged)
    }
    @objc fileprivate func validateTextFields() {
        guard let currentPassword = self.currentPasswordTextField.text,
            let newPassword = self.newPasswordTextField.text,
            let confirmationPassword = self.confirmPasswordTextField.text,
            !currentPassword.isEmpty, !newPassword.isEmpty, !confirmationPassword.isEmpty else {
                self.disableSaveButton()
                return
        }
        self.enableSaveButton()
    }
    let currentPasswordTextField = createTextField(placeholder: "Current Password")
    let newPasswordTextField = createTextField(placeholder: "New Password")
    let confirmPasswordTextField = createTextField(placeholder: "Confirm Password")
    
    lazy var currentPasswordTextFieldContainerView = self.createTextFieldContainerView(self.currentPasswordTextField)
    lazy var newPasswordTextFieldContainerView = self.createTextFieldContainerView(self.newPasswordTextField)
    lazy var confirmPasswordTextFieldContainerView = self.createTextFieldContainerView(self.confirmPasswordTextField)
    
    fileprivate func setupSubviews() {
        view.addSubview(currentPasswordTextFieldContainerView)
        view.addSubview(newPasswordTextFieldContainerView)
        view.addSubview(confirmPasswordTextFieldContainerView)
    }
    fileprivate func setupSubviewsConstraints() {
        let height:CGFloat = 50
        currentPasswordTextFieldContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
        newPasswordTextFieldContainerView.anchor(top: currentPasswordTextFieldContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
        confirmPasswordTextFieldContainerView.anchor(top: newPasswordTextFieldContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    static func createTextField(placeholder:String? = nil) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        if let placeholderText = placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: UIColor.telaGray5])
        }
        textField.textColor = UIColor.telaGray7
        textField.textAlignment = .left
        textField.keyboardAppearance = .dark
        textField.borderStyle = .none
        return textField
    }
    
    
    func createTextFieldContainerView(_ textField:UITextField) -> UIView {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        
        let separator = Line()
        container.addSubview(textField)
        container.addSubview(separator)
        
        textField.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: separator.topAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        separator.anchor(top: nil, left: textField.leftAnchor, bottom: container.bottomAnchor, right: textField.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        return container
    }
}
