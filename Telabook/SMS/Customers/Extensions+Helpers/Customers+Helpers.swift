//
//  Customers+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import InteractiveModal

extension CustomersViewController: StartNewConversationDelegate {
    func conversation(didStartNewConversationWithID id: Int, node:String) {
        if let conversation = self.fetchedResultsController.fetchedObjects?.first(where: { $0.externalConversationID == id }),
            let indexPath = self.fetchedResultsController.indexPath(forObject: conversation) {
            self.subview.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            self.openChat(forSelectedCustomer: conversation, at: indexPath)
            print("selecting from fetched results controller as new firebase entry is loaded into core data store")
        } else {
            print("pushing view controller from delegate (with node) as new firebase entry not yet loaded into core data store")
            
        }
    }
}

extension CustomersViewController {
    internal func setupNavBarItems() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItems = [addButton]
    }
    @objc func addButtonTapped() {
//        let newContactVC = NewContactViewController()
//        newContactVC.modalPresentationStyle = .overFullScreen
//        newContactVC.view.backgroundColor = .telaGray1
//        newContactVC.delegate = self
        let vc = NewConversationController(senderID: Int(agent.workerID))
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    internal func setupTargetActions() {
        subview.segmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
//        subview.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func didChangeSegment(_ sender:UISegmentedControl) {
        switch subview.segmentedControl.selectedSegmentIndex {
        case 0: selectedSegment = .Inbox
        case 1: selectedSegment = .Archived
        default: fatalError("Invalid Segment")
        }
    }
    internal func handleEvents(for segment:Segment) {
//        self.stopRefreshers()
        setupFetchedResultsController()
//        switch segment {
//        case .Inbox:
//            print("Segment: Inbox")
//            synchronizeWithTimeLogic()
//        case .Archived:
//            print("Segment: Archived")
//            synchronizeWithTimeLogic()
//        }
    }
    
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        switch selectedSegment {
            case .Inbox:
                if !isFetchedResultsAvailable {
                    DispatchQueue.main.async {
                        self.subview.inboxPlaceholderLabel.text = "No Customer"
                        self.subview.archivedPlaceholderLabel.isHidden = true
                        self.subview.inboxPlaceholderLabel.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.subview.archivedPlaceholderLabel.isHidden = true
                        self.subview.inboxPlaceholderLabel.isHidden = true
                    }
                }
            case .Archived:
                if !isFetchedResultsAvailable {
                    self.subview.archivedPlaceholderLabel.text = "No Archived Conversation"
                    DispatchQueue.main.async {
                        self.subview.inboxPlaceholderLabel.isHidden = true
                        self.subview.archivedPlaceholderLabel.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.subview.inboxPlaceholderLabel.isHidden = true
                        self.subview.archivedPlaceholderLabel.isHidden = true
                    }
                }
        }
        
    }
    internal func stopRefreshers() {
        DispatchQueue.main.async {
            self.subview.inboxSpinner.stopAnimating()
            self.subview.archivedSpinner.stopAnimating()
            self.subview.tableView.refreshControl?.endRefreshing()
        }
    }
    @objc private func refreshData(_ sender: Any) {
//        fetchAgents()
    }
    internal func startInboxSpinner() {
        DispatchQueue.main.async {
            self.subview.inboxSpinner.startAnimating()
        }
    }
    internal func startArchivedSpinner() {
        DispatchQueue.main.async {
            self.subview.archivedSpinner.startAnimating()
        }
    }
    
    internal func synchronizeWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let customer = fetchedResultsController.fetchedObjects?.first,
                let lastRefreshedAt = customer.lastRefreshedAt {
                let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(20)
                let currentTime = Date()
                currentTime > thresholdRefreshTime ? initiateFetchCustomersSequence(withRefreshMode: .refreshControl) : ()
                #if DEBUG
                print("\n\n\tLast Refreshed At: \(Date.getStringFromDate(date: lastRefreshedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Threshold Refresh Time: \(Date.getStringFromDate(date: thresholdRefreshTime, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Current time: \(Date.getStringFromDate(date: currentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")))\n\n")
                #endif
            }
        } else {
            initiateFetchCustomersSequence(withRefreshMode: .spinner)
        }
    }
    internal func initiateFetchCustomersSequence(withRefreshMode refreshMode: RefreshMode) {
        showLoadingPlaceholers()
        if refreshMode == .spinner {
            selectedSegment == .Inbox ? startInboxSpinner() : startArchivedSpinner()
            // fetching remaing
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.subview.tableView.refreshControl?.beginExplicitRefreshing()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.stopRefreshers()
            self.handleState()
        }
    }
    internal func showLoadingPlaceholers() {
        subview.inboxPlaceholderLabel.text = "Loading Conversations"
        subview.archivedPlaceholderLabel.text = "Loading"
        if self.selectedSegment == .Inbox {
            DispatchQueue.main.async {
                self.subview.archivedPlaceholderLabel.isHidden = true
                self.subview.inboxPlaceholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.subview.inboxPlaceholderLabel.isHidden = true
                self.subview.archivedPlaceholderLabel.isHidden = false
            }
        }
    }
    
    
    
    
    
    
    internal func promptChatColor(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Set Chat Color", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        let yellowAction = UIAlertAction(title: CustomerConversationColor.Yellow.colorName, style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Yellow, indexPath: indexPath)
        })
        let blueAction = UIAlertAction(title: CustomerConversationColor.Blue.colorName, style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Blue, indexPath: indexPath)
        })
        let greenAction = UIAlertAction(title: CustomerConversationColor.Green.colorName, style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Green, indexPath: indexPath)
        })
        let whiteAction = UIAlertAction(title: CustomerConversationColor.White.colorName, style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .White, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(yellowAction)
        alert.addAction(blueAction)
        alert.addAction(greenAction)
        alert.addAction(whiteAction)
        alert.addAction(cancelAction)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        
        alert.view.tintColor = UIColor.telaBlue
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alert.view.subviews.first?.backgroundColor = .clear
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleChatColorSequence(color:CustomerConversationColor, indexPath:IndexPath) {
        guard let customers = fetchedResultsController.fetchedObjects else { return }
        let customer = customers[indexPath.row]
        guard let conversation = firebaseCustomers.first(where: { $0.conversationID == customer.externalConversationID }) else { return }
        updateColorOnFirebase(forConversation: conversation, color: color)
    }
    internal func updateColorOnFirebase(forConversation conversation: FirebaseCustomer, color:CustomerConversationColor) {
        conversation.ref?.updateChildValues([
            "colour" : color.code
            ], withCompletionBlock: { (error, reference) in
                if let error = error {
                    print("Error: unable to update color on Firebase: \(error)")
                }
        })
    }
    
    
    
    
    
    
    
    internal func promptBlockingReasonAlert(for customer:Customer) {
        let alertVC = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let attributedString = NSAttributedString(string: "BLOCKING REASON", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)!,
            .foregroundColor : UIColor.telaBlue
            ])
        alertVC.setValue(attributedString, forKey: "attributedTitle")
        alertVC.view.autoresizesSubviews = true
        alertVC.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        alertVC.view.tintColor = UIColor.telaBlue
        alertVC.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alertVC.view.subviews.first?.backgroundColor = .clear
        
        alertVC.view.addSubview(subview.reasonTextView)
        subview.reasonTextView.delegate = self
        subview.reasonTextView.anchor(top: alertVC.view.topAnchor, left: alertVC.view.leftAnchor, bottom: nil, right: alertVC.view.rightAnchor, topConstant: 54, leftConstant: 10, bottomConstant: 54, rightConstant: 10, heightConstant: 60)
        alertVC.view.addSubview(subview.characterCountLabel)
        subview.characterCountLabel.anchor(top: subview.reasonTextView.bottomAnchor, left: subview.reasonTextView.leftAnchor, bottom: alertVC.view.bottomAnchor, right: subview.reasonTextView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 50, rightConstant: 3)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
        let submitAction = UIAlertAction(title: "SUBMIT", style: UIAlertAction.Style.default) { (action) in
            let reason = self.subview.reasonTextView.text
            if let reason = reason, !reason.isEmpty {
                self.blockConversation(for: customer, blockingReason: reason, completion: {_ in})
            }
        }
        submitAction.isEnabled = false
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
        self.present(alertVC, animated: true, completion: {
            self.subview.reasonTextView.becomeFirstResponder()
        })
    }
}


extension CustomersViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let alertController = self.presentedViewController as? UIAlertController,
            let submitAction = alertController.actions.last else { return }
        let textCount = textView.text.count
        submitAction.isEnabled = textCount > 0
        subview.characterCountLabel.text = "Charaters left: \(70 - textCount)"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return textView.resignFirstResponder()
        } else {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars <= 70
        }
    }
}
