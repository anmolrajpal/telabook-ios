//
//  QuickResponsesHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension QuickResponsesViewController {
    
    internal func setupTargetActions() {
        subview.doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        subview.saveResponseButton.addTarget(self, action: #selector(didTapSaveResponseButton), for: .touchUpInside)
    }
    @objc private func didTapDoneButton() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func didTapSaveResponseButton() {
        self.subview.responseTextView.resignFirstResponder()
        self.subview.responseTextView.endEditing(true)
        self.saveResponse()
    }
    private func saveResponse() {
        if let response = self.subview.responseTextView.text,
            !response.isEmpty {
            self.createQuickResponse(answer: response)
//            self.initiateAddQuickResponseSequence(userId: userId, answer: response)
        } else {
            fatalError("Unhandled case for Response text view")
        }
    }
    
    
    internal func startRefreshers() {
        self.subview.spinner.startAnimating()
        self.subview.saveResponseButton.isHidden = true
    }
    internal func stopRefreshers() {
        self.subview.spinner.stopAnimating()
        self.subview.saveResponseButton.isHidden = false
    }
    
    
     func showEditResponseDialogBox(quickResponse:QuickResponse) {
        let alertVC = UIAlertController(title: "", message: "\n", preferredStyle: UIAlertController.Style.alert)
        let attributedTitle = NSAttributedString(string: "Update Response", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)!, //your font here
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
        ])
        let attributedMessage = NSAttributedString(string: "Max Characters: 70", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!, //your font here
            NSAttributedString.Key.foregroundColor : UIColor.telaGray7
        ])
        alertVC.setValue(attributedTitle, forKey: "attributedTitle")
        alertVC.setValue(attributedMessage, forKey: "attributedMessage")
        alertVC.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        
        alertVC.view.tintColor = UIColor.telaBlue
        alertVC.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alertVC.view.subviews.first?.backgroundColor = .clear
        alertVC.addTextField { (textField) in
            textField.placeholder = "Add Quick Response"
            textField.text = quickResponse.answer
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
            // textField.layer.borderColor = UIColor.telaGray5.cgColor
            // textField.layer.borderWidth = 1
            // textField.layer.cornerRadius = 5
            // textField.clipsToBounds = true
            // textField.keyboardType = UIKeyboardType.emailAddress
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.returnKeyType = UIReturnKeyType.go
            
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        }
        
        
        //        alertVC.textFields?[0].tintColor = .yellow
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
        let submitAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) { (action) in
            let text = alertVC.textFields?[0].text
            if let answer = text,
                !answer.isEmpty {
                self.updateQuickResponse(forSelectedResponse: quickResponse, answer: answer)
//                self.initiateUpdateQuickResponseSequence(userId: self.userId, answer: answer, responseId: responseId)
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
            submitAction?.isEnabled = textField?.text?.count ?? 0 <= 70 && !(textField?.text?.isEmpty ?? true)
        }
    }
    
    
    
    
    
    internal func fetchWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let firstObject = fetchedResultsController.fetchedObjects?.first,
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                
                if firstObject.synced == true {
                    let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(13)
                    let currentTime = Date()
                    currentTime > thresholdRefreshTime ? fetchQuickResponses() : ()
                    #if DEBUG
                    print("\n\n\tLast Refreshed At: \(Date.getStringFromDate(date: lastRefreshedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Threshold Refresh Time: \(Date.getStringFromDate(date: thresholdRefreshTime, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Current time: \(Date.getStringFromDate(date: currentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")))\n\n")
                    #endif
                } else {
//                    updateAutoResponse(forID: Int(firstObject.id))
                }
            }
        } else {
            fetchQuickResponses()
        }
    }
}
