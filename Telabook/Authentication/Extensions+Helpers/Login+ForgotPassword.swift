//
//  Login+ForgotPassword.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension LoginViewController {
    @objc internal func forgotPasswordButtonDidTap() {
        showForgotPasswordDialogBox()
    }
    fileprivate func showForgotPasswordDialogBox() {
        //        if alertController == nil { configureForgotPasswordAlertController() }
        self.present(alertController, animated: true, completion: nil)
    }
    /*
     fileprivate func showForgotPasswordDialogBox() {
     let alertVC = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
     let attributedString = NSAttributedString(string: "FORGOT PASSWORD", attributes: [
     NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!, //your font here
     NSAttributedString.Key.foregroundColor : UIColor.telaBlue
     ])
     alertVC.setValue(attributedString, forKey: "attributedTitle")
     alertVC.view.subviews[0].subviews[0].subviews[0].backgroundColor = UIColor.telaGray5
     alertVC.view.tintColor = UIColor.telaBlue
     
     alertVC.addTextField { (textField) in
     textField.attributedPlaceholder = NSAttributedString(string: "Your Email Address", attributes: [
     .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
     .foregroundColor: UIColor.telaGray6
     ])
     textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
     textField.backgroundColor = UIColor.telaGray4
     textField.textColor = UIColor.telaWhite
     textField.clearButtonMode = .whileEditing
     textField.borderStyle = .roundedRect
     textField.layer.borderColor = UIColor.systemRed.cgColor
     textField.layer.borderWidth = 0
     textField.layer.cornerRadius = 7
     textField.clipsToBounds = true
     textField.keyboardType = UIKeyboardType.emailAddress
     textField.keyboardAppearance = UIKeyboardAppearance.dark
     textField.textContentType = UITextContentType.emailAddress
     textField.returnKeyType = UIReturnKeyType.go
     textField.addTarget(self, action: #selector(self.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
     //            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
     }
     let textField = alertVC.textFields![0]
     textField.superview!.backgroundColor = .telaGray5
     textField.superview!.superview!.subviews[0].removeFromSuperview()
     
     let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
     let submitAction = UIAlertAction(title: "SUBMIT", style: UIAlertAction.Style.default) { (action) in
     let text = textField.text
     guard let email = text, !email.isBlank, email.isValidEmailAddress() else {
     textField.shake(withFeedbackTypeOf: .Heavy)
     UIView.animate(withDuration: 0.3) {
     textField.layer.borderWidth = 1
     }
     return
     }
     print("Safe")
     self.initiateForgotPasswordSequence(for: email)
     }
     //        submitAction.isEnabled = false
     alertVC.addAction(cancelAction)
     alertVC.addAction(submitAction)
     self.present(alertVC, animated: true, completion: nil)
     }
     */
    func configureForgotPasswordAlertController() {
        alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let attributedString = NSAttributedString(string: "FORGOT PASSWORD", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!, //your font here
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
        ])
        alertController.setValue(attributedString, forKey: "attributedTitle")
        alertController.view.subviews[0].subviews[0].subviews[0].backgroundColor = UIColor.telaGray5
        alertController.view.tintColor = UIColor.telaBlue
        
        alertController.addTextField { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: "Your Email Address", attributes: [
                .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
                .foregroundColor: UIColor.telaGray6
            ])
            textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
            textField.backgroundColor = UIColor.telaGray4
            textField.textColor = UIColor.telaWhite
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
            textField.layer.borderColor = UIColor.systemRed.cgColor
            textField.layer.borderWidth = 0
            textField.layer.cornerRadius = 7
            textField.clipsToBounds = true
            textField.keyboardType = UIKeyboardType.emailAddress
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.textContentType = UITextContentType.emailAddress
            textField.returnKeyType = UIReturnKeyType.go
            textField.addTarget(self, action: #selector(self.forgotPasswordEmailTextFieldDidBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(self.forgotPasswordEmailTextFieldDidChange(_:)), for: .editingChanged)
        }
        let textField = alertController.textFields![0]
        textField.superview!.backgroundColor = .telaGray5
        textField.superview!.superview!.subviews[0].removeFromSuperview()
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
        alertController.addAction(cancelAction)
        configureSubmitAction()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.submitButtonDidPress(sender:)))
        gestureRecognizer.minimumPressDuration = 0.0
        gestureRecognizer.delegate = self
        
        
        let actionsStackView = alertController.view.subviews.first?.subviews.first?.subviews.first?.subviews.second?.subviews.first?.subviews.first
        if let actionsStackView = actionsStackView as? UIStackView {
            actionsStackView.addGestureRecognizer(gestureRecognizer)
        } else {
            alertController.view.addGestureRecognizer(gestureRecognizer)
        }
    }
    func configureSubmitAction() {
        submitAction = UIAlertAction(title: "SUBMIT", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(submitAction)
    }
    @objc func submitButtonDidPress(sender: UILongPressGestureRecognizer) {
        guard
            let textField = alertController.textFields?.first else { return }
        if sender.state == .began {
            submitAction.isEnabled = false
        } else if sender.state == .ended {
            let text = textField.text
            guard let email = text, !email.isBlank, email.isValidEmailAddress() else {
                textField.shake(withFeedbackTypeOf: .Heavy)
                UIView.animate(withDuration: 0.3) {
                    textField.layer.borderWidth = 1
                }
                submitAction.isEnabled = true
                return
            }
            submitAction.isEnabled = true
            DispatchQueue.main.async {
                self.alertController.dismiss(animated: true) {
                    self.initiateForgotPasswordSequence(forEmail: email)
                }
            }
        }
    }
    @objc private func forgotPasswordEmailTextFieldDidBeginEditing(_ textField:UITextField) {
        textField.layer.borderWidth = 0
    }
    @objc func forgotPasswordEmailTextFieldDidChange(_ textField: UITextField!) {
        textField.layer.borderWidth = 0
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func initiateForgotPasswordSequence(forEmail email:String) {
        DispatchQueue.global(qos: .userInteractive).async {
            TapticEngine.generateFeedback(ofType: .Medium)
            DispatchQueue.main.async {
                UIAlertController.showModalSpinner(with: "Requesting...", controller: self)
            }
            sleep(1)
            APIServer<APIService.RecurrentResult>(apiVersion: .v2).hitEndpoint(endpoint: .ForgotPassword, requiresBearerToken: false, httpMethod: .POST, params: ["email":email]) { (result: Result<APIService.RecurrentResult, APIService.APIError>) in
                switch result {
                    case .failure(let error):
                        TapticEngine.generateFeedback(ofType: .Error)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Error", message: error.publicDescription, action: UIAlertAction(title: "Ok", style: .destructive, handler: { _ in
                                    self.showForgotPasswordDialogBox()
                                }), controller: self)
                            })
                        }
                    case .success:
                        TapticEngine.generateFeedback(ofType: .Success)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Check Email", message: "Please check your email & follow the instructions to reset your password", controller: self)
                            })
                        }
                }
            }
        }
    }
    
    
    

}
extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let stackView = alertController.view.subviews.first?.subviews.first?.subviews.second?.subviews.last?.subviews.first?.subviews.first as? UIStackView else {
            #if !RELEASE
            print("Apple changed its Alert Controller Hierarchy.")
            #endif
            return false
        }
        let point = touch.location(in: stackView)
        if let submitActionView = stackView.arrangedSubviews.last?.subviews.first {
            guard point.x >= stackView.frame.width - submitActionView.frame.width  else { return false }
        } else {
            guard point.x >= stackView.frame.width / 2  else { return false }
        }
        return true
    }
}
