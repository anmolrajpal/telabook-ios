//
//  NormalDialer+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension NormalDialerViewController {
    internal func commonInit() {
        configureTargetActions()
        subview.numberTextField.delegate = self
    }
    
    private func configureTargetActions() {
        subview.cancelButton.addTarget(self, action: #selector(cancelButtonDidTapped(_:)), for: .touchUpInside)
        subview.startButton.addTarget(self, action: #selector(startButtonDidTapped(_:)), for: .touchUpInside)
    }
    @objc private func cancelButtonDidTapped(_ button: UIButton) {
        dismiss(animated: true)
    }
    @objc private func startButtonDidTapped(_ sender: UIButton) {
        guard let formattedPhoneNumber = subview.numberTextField.text else { return }
        let purePhoneNumber = formattedPhoneNumber.extractNumbers
        let isPhoneNumberValid = purePhoneNumber.isPhoneNumberLengthValid()
        guard isPhoneNumberValid else {
            subview.numberTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        let phoneNumber = "+1\(purePhoneNumber)"
        delegate?.normalDialer(didEnteredNumberToDial: phoneNumber, controller: self)
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

extension NormalDialerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = newString.formatNumber()
        return false
    }
}

