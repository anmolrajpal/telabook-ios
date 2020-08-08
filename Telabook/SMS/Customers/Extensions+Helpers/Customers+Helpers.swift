//
//  Customers+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import InteractiveModal
import CoreData

extension CustomersViewController: StartNewConversationDelegate {
    func conversation(didStartNewConversationWithID id: Int, node:String) {
        if let conversation = customers.first(where: { $0.externalConversationID == id }),
            let indexPath = self.fetchedResultsController.indexPath(forObject: conversation) {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            self.openChat(forSelectedCustomer: conversation, at: indexPath)
        } else {
            print("pushing view controller from delegate (with node) as new firebase entry not yet loaded into core data store")
            let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Customer.agent)) == %@ AND \(#keyPath(Customer.externalConversationID)) = %d", agent, id)
            fetchRequest.fetchLimit = 1
            context.performAndWait {
                if let conversation = try? fetchRequest.execute().first {
                    let vc = MessagesController(customer: conversation)
                    DispatchQueue.main.async { [weak self] in
                        self?.navigationController?.pushViewController(vc, animated: true)
                        self?.viewDidAppear = false
                    }
                }
            }
        }
    }
}

extension CustomersViewController {
    
    // MARK: - Common init
    internal func commonInit() {
        title = agent.personName ?? agent.phoneNumber ?? "Customers"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        configureHierarchy()
        configureTableView()
        configureDataSource()
        configureFetchedResultsController()
        configureNavigationBarItems()
        configureTargetActions()
    }
    
    
    private func configureHierarchy() {
        view.addSubview(inboxSpinner)
        view.addSubview(archivedSpinner)
        view.addSubview(inboxPlaceholderLabel)
        view.addSubview(archivedPlaceholderLabel)
        view.addSubview(refreshButton)
        layoutConstraints()
    }
    private func layoutConstraints() {
        inboxSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        inboxSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
        archivedSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        archivedSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
        
        inboxPlaceholderLabel.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        inboxPlaceholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).activate()
        
        archivedPlaceholderLabel.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        archivedPlaceholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).activate()
        
        refreshButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).activate()
        refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
    }
    
    
    func removeFirebaseObservers() {
        if handle != nil { reference.removeObserver(withHandle: handle) }
    }
    
    internal func configureNavigationBarItems() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonTapped))
        sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: sendButton)

        switch true {
            case pickerDelegate != nil:
                navigationItem.rightBarButtonItems = []
            case messageForwardingDelegate != nil:
                navigationItem.rightBarButtonItems = [rightBarButton]
                updateNavigationBarItems()
            default:
                navigationItem.rightBarButtonItems = [addButton]
        }
    }
    func updateNavigationBarItems() {
        let count = selectedConversationsToForwardMessage.count
        let isEnabled = count > 0
        title = isEnabled ? "\(count) Selected" : agent.personName ?? agent.phoneNumber ?? "Customers"
        sendButton.isEnabled = isEnabled
    }
    
    @objc
    private func addButtonTapped() {
        let vc = NewConversationController(senderID: Int(agent.workerID))
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @objc
    private func sendButtonDidTap() {
        messageForwardingDelegate?.forwardMessage(to: selectedConversationsToForwardMessage, controller: self)
    }
    internal func configureTargetActions() {
        segmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
//        subview.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func didChangeSegment(_ sender:UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: selectedSegment = .Inbox
        case 1: selectedSegment = .Archived
        default: fatalError("Invalid Segment")
        }
    }
    internal func handleEvents(for segment:Segment) {
        configureFetchedResultsController()
    }
    
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        switch selectedSegment {
            case .Inbox:
                if !isFetchedResultsAvailable {
                    DispatchQueue.main.async {
                        self.inboxPlaceholderLabel.text = "No Customer"
                        self.archivedPlaceholderLabel.isHidden = true
                        self.inboxPlaceholderLabel.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.archivedPlaceholderLabel.isHidden = true
                        self.inboxPlaceholderLabel.isHidden = true
                    }
                }
            case .Archived:
                if !isFetchedResultsAvailable {
                    self.archivedPlaceholderLabel.text = "No Archived Conversation"
                    DispatchQueue.main.async {
                        self.inboxPlaceholderLabel.isHidden = true
                        self.archivedPlaceholderLabel.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.inboxPlaceholderLabel.isHidden = true
                        self.archivedPlaceholderLabel.isHidden = true
                    }
                }
        }
        
    }
    internal func stopRefreshers() {
        DispatchQueue.main.async {
            self.inboxSpinner.stopAnimating()
            self.archivedSpinner.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    @objc private func refreshData(_ sender: Any) {
//        fetchAgents()
    }
    internal func startInboxSpinner() {
        DispatchQueue.main.async {
            self.inboxSpinner.startAnimating()
        }
    }
    internal func startArchivedSpinner() {
        DispatchQueue.main.async {
            self.archivedSpinner.startAnimating()
        }
    }
    
    internal func showLoadingPlaceholers() {
        inboxPlaceholderLabel.text = "Loading Conversations"
        archivedPlaceholderLabel.text = "Loading"
        if self.selectedSegment == .Inbox {
            DispatchQueue.main.async {
                self.archivedPlaceholderLabel.isHidden = true
                self.inboxPlaceholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.inboxPlaceholderLabel.isHidden = true
                self.archivedPlaceholderLabel.isHidden = false
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
        
        alertVC.view.addSubview(reasonTextView)
        reasonTextView.delegate = self
        reasonTextView.anchor(top: alertVC.view.topAnchor, left: alertVC.view.leftAnchor, bottom: nil, right: alertVC.view.rightAnchor, topConstant: 54, leftConstant: 10, bottomConstant: 54, rightConstant: 10, heightConstant: 60)
        alertVC.view.addSubview(characterCountLabel)
        characterCountLabel.anchor(top: reasonTextView.bottomAnchor, left: reasonTextView.leftAnchor, bottom: alertVC.view.bottomAnchor, right: reasonTextView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 50, rightConstant: 3)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
        let submitAction = UIAlertAction(title: "SUBMIT", style: UIAlertAction.Style.default) { (action) in
            let reason = self.reasonTextView.text
            if let reason = reason, !reason.isEmpty {
                self.blockConversation(for: customer, blockingReason: reason, completion: {_ in})
            }
        }
        submitAction.isEnabled = false
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
        self.present(alertVC, animated: true, completion: {
            self.reasonTextView.becomeFirstResponder()
        })
    }
}


extension CustomersViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let alertController = self.presentedViewController as? UIAlertController,
            let submitAction = alertController.actions.last else { return }
        let textCount = textView.text.count
        submitAction.isEnabled = textCount > 0
        characterCountLabel.text = "Charaters left: \(70 - textCount)"
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
