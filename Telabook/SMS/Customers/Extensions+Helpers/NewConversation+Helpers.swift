//
//  NewConversation+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension NewConversationController {
    internal func commonInit() {
        setupTargetActions()
        subview.numberTextField.delegate = self
    }
    
    private func setupTargetActions() {
        subview.cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        subview.startButton.addTarget(self, action: #selector(startButtonDidTap(_:)), for: .touchUpInside)
    }
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func startButtonDidTap(_ sender: UIButton) {
        guard let formattedPhoneNumber = subview.numberTextField.text else { return }
        let purePhoneNumber = formattedPhoneNumber.extractNumbers
        let isPhoneNumberValid = purePhoneNumber.isPhoneNumberLengthValid()
        guard isPhoneNumberValid else {
            subview.numberTextField.shake(withFeedbackTypeOf: .Error)
            return
        }
        let phoneNumber = "+1\(purePhoneNumber)"
        self.startNewConversation(with: phoneNumber)
    }
    internal func conversationDidStart(withID id:Int, node:String) {
        self.stopRefreshers()
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.delegate?.conversation(didStartNewConversationWithID: id, node: node)
            }
        }
    }
    
    internal func startRefreshers() {
        DispatchQueue.main.async {
            self.subview.spinner.startAnimating()
            self.subview.startButton.isHidden = true
        }
    }
    internal func stopRefreshers() {
        DispatchQueue.main.async {
            self.subview.spinner.stopAnimating()
            self.subview.startButton.isHidden = false
        }
    }
}

extension NewConversationController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = newString.formatNumber()
        return false
    }
}









extension UIViewController {
    func startObservingKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func stopObservingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.frame.origin.y = 0
//            let contentInsets: UIEdgeInsets = .zero
//            self.view.frame.inset(by: contentInsets)
            
//            self.scrollView.contentInset = contentInsets
//            self.subview.scrollView.scrollIndicatorInsets = contentInsets
        }, completion: nil)
    }
    @objc private func keyboardWillShow(notification:NSNotification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight:CGFloat = keyboardSize?.height ?? 280.0
        
        print(keyboardHeight)
        print(self.view.frame.origin.y)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.frame.origin.y = -keyboardHeight
//            self.view.frame = CGRect(x: 0, y: keyboardHeight, width: self.view.frame.width, height: self.view.frame.height)
//            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + 50.0, right: 0.0)
//            self.view.frame.inset(by: contentInsets)
//            self.subview.scrollView.contentInset = contentInsets
//            self.subview.scrollView.scrollIndicatorInsets = contentInsets
        }, completion: nil)
    }
}
