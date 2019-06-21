//
//  NewContactViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class NewContactViewController: UIViewController {
    var delegate:NewConversationDelegate?
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(cancelButton)
        view.addSubview(headingLabel)
        view.addSubview(numberTextField)
        view.addSubview(messageButton)
    }
    fileprivate func setupConstraints() {
        cancelButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        headingLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 60, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        numberTextField.anchor(top: nil, left: view.leftAnchor, bottom: view.centerYAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 60, bottomConstant: 20, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        messageButton.anchor(top: view.centerYAnchor, left: numberTextField.leftAnchor, bottom: nil, right: numberTextField.rightAnchor, topConstant: 20, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 35)
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
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [
            .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 15.0)!,
            .foregroundColor: UIColor.telaBlue
            ]), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    let headingLabel:UILabel = {
        let label = UILabel()
        label.text = "New Message"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 35)
        label.textColor = .telaBlue
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let numberTextField:UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.telaGray7])
        textField.textColor = UIColor.telaWhite
        textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 20)
        textField.setDefault(string: "+1", at: .Left)
        textField.layer.borderColor = UIColor.telaGray5.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 15
        textField.keyboardType = UIKeyboardType.numberPad
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.textContentType = UITextContentType.telephoneNumber
        textField.translatesAutoresizingMaskIntoConstraints = false
        //        textField.addTarget(self, action: #selector(numberFieldDidReturn(textField:)), for: UIControl.Event.editingDidEndOnExit)
        textField.addTarget(self, action: #selector(numberFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        return textField
    }()
    
    @objc func numberFieldDidChange(textField:UITextField) {
        let isPhoneNumberValid = textField.text?.isPhoneNumberLengthValid() ?? false
        handleValidationSequence(isValidPhoneNumber: isPhoneNumberValid)
    }
    internal func handleValidationSequence(isValidPhoneNumber:Bool) {
        messageButton.isEnabled = isValidPhoneNumber
        messageButton.backgroundColor = messageButton.isEnabled ? UIColor.telaBlue : UIColor.telaGray5
    }
    
    lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.telaGray5
        button.setTitle("Start Conversation", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)
        button.layer.borderColor = UIColor.telaBlue.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 15
        button.setTitleColor(.telaWhite, for: .normal)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    @objc func handleButtonTapped() {
        self.initiateNewConversationSequence()
    }
    
    fileprivate func initiateNewConversationSequence() {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(controller: self)
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    UIAlertController.showTelaAlert(title: "Authentication Error", message: err.localizedDescription, controller: self)
                }
            } else if let token = token {
                let phoneNumber = self.numberTextField.text!
                guard !phoneNumber.isEmpty else {
                    print("Empty")
                    DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                         UIAlertController.showTelaAlert(title: "Empty", message: "Please enter a valid Phone Number", controller: self)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.startNewConversation(token: token, phoneNumber: "%2b1\(phoneNumber)")
                }
            }
        }
    }
    
    
    fileprivate func startNewConversation(token:String, phoneNumber:String) {
        let companyId = String(UserDefaults.standard.getCompanyId())
        let senderId = UserDefaults.standard.currentSender.id
        print("Sender Id => \(senderId)")
        ExternalConversationsAPI.shared.startNewConversation(token: token, companyId: companyId, phoneNumber: phoneNumber, senderId: senderId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                print("***Error Starting Conversations****\n\(err.localizedDescription)")
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                }
            } else if let serviceErr = serviceError {
                print("***Error Starting Conversations****\n\(serviceErr.localizedDescription)")
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    UIAlertController.showTelaAlert(title: "Service Error", message: serviceErr.localizedDescription, controller: self)
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    print("***Invalid Response****\nResponse Status => \(status)")
                    DispatchQueue.main.async {
                        UIAlertController.dismissModalSpinner(controller: self)
                        UIAlertController.showTelaAlert(title: "Error", message: "Unable to start new conversation. Invalid Response: \(status)", controller: self)
                    }
                    return
                }
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let response = try decoder.decode(NewConversationCodable.self, from: data)
                        print(response)
                        
                        if let id = response.externalConversationId,
                            id != 0,
                            let _ = response.node {
                            
                            DispatchQueue.main.async {

                            UIAlertController.dismissModalSpinner(controller: self)
                                print("STATUS: GOOD")
                                self.delegate?.startConversation(dismiss: self, result: response)
                            }
                            
                        }
                    } catch let error {
                        print("Error decoding data: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
    }
}
protocol NewConversationDelegate {
    func startConversation(dismiss vc:UIViewController, result newConversation:NewConversationCodable)
}


