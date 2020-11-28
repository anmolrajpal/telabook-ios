//
//  CustomerDetails+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension CustomerDetailsController {
    
    
    internal func commonInit() {
        view.backgroundColor = .telaGray1
        title = "CUSTOMER"
        configureNavigationBarAppearance()
        configureNavigationBarItems()
        configureHierarchy()
        configureTargetActions()
        configureTableView()
        configureDataSource()
//        hideKeyboardWhenTappedAround()
        setupCustomerDetails()
        fetchCustomerDetails()
        fetchInitialConversationsHistory()
    }
    func setupCustomerDetails() {
        let phoneNumber = conversation.phoneNumber ?? ""
        let number:String = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
        /*
        if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
            number = formattedPhoneNumber
        } else {
            number = phoneNumber
        }
        */
        phoneNumberLabel.text = number
        
        agentOnlyNameTextField.text = conversation.customerDetails?.agentOnlyName
        
        globalNameTextField.text = conversation.customerDetails?.globalName
        
        /*
//        let context = PersistentContainer.shared.viewContext
        guard let context = conversation.agent?.managedObjectContext else {
            fatalError()
        }
        let conversationObjectID = conversation.objectID
        let conversation = context.object(with: conversationObjectID) as! Customer
        let fetchRequest: NSFetchRequest<CustomerDetails> = CustomerDetails.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(CustomerDetails.conversation)) == %@", conversation)
        
        context.perform { [weak self] in
            guard let self = self else { return }
            if let customerDetails = try? fetchRequest.execute().first {
                let phoneNumber = customerDetails.conversation?.phoneNumber ?? ""
                let number:String
                if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
                    number = formattedPhoneNumber
                } else {
                    number = phoneNumber
                }
                self.phoneNumberLabel.text = number
                
                self.agentOnlyNameTextField.text = customerDetails.agentOnlyName
                
                self.globalNameTextField.text = customerDetails.globalName
            }
        }
        */
        
    }
    private func configureNavigationBarItems() {
        let cancelButtonImage = SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)).image(scaledTo: .init(width: 28, height: 28))
        let cancelButton = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: self, action: #selector(cancelButtonDidTapped(_:)))
        cancelButton.tintColor = UIColor.white.withAlphaComponent(0.2)
        navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    @objc
    private func cancelButtonDidTapped(_ button: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func configureTargetActions() {
        updateButton.addTarget(self, action: #selector(updateButtonDidTapped(_:)), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
    }
    
    @objc
    private func updateButtonDidTapped(_ button: UIButton) {
        updateCustomerDetails()
    }
    
    @objc
    private func didChangeSegment(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: selectedSegment = .Details
        case 1: selectedSegment = .History
        default: fatalError("Invalid Segment")
        }
    }
    
    /// Manages the UI state
    internal func handleSegmentViewsState() {
        switch selectedSegment {
        case .Details:
            DispatchQueue.main.async {
                self.scrollView.isHidden = false
            }
        case .History:
            DispatchQueue.main.async {
                self.view.endEditing(true)
                self.scrollView.isHidden = true
            }
        }
    }
    
    
    func startDetailsSpinner() {
        DispatchQueue.main.async {
            self.detailsSpinner.startAnimating()
        }
    }
    func stopDetailsSpinner() {
        DispatchQueue.main.async {
            self.detailsSpinner.stopAnimating()
        }
    }
    func startHistorySpinner() {
        DispatchQueue.main.async {
            self.historySpinner.startAnimating()
        }
    }
    func stopHistorySpinner() {
        DispatchQueue.main.async {
            self.historySpinner.stopAnimating()
        }
    }
    
    
    
    private func configureHierarchy() {
        view.addSubview(segmentedControl)
        tableView.addSubview(historySpinner)
        tableView.addSubview(historyPlaceholderLabel)
        view.addSubview(tableView)
        configureScrollViewContentViewHierarchy()
        scrollView.backgroundColor = view.backgroundColor
        scrollView.addSubview(scrollViewContentView)
        view.addSubview(scrollView)
        layoutConstraints()
    }
    private func layoutConstraints() {
        let fontSize = (segmentedControl.titleTextAttributes(for: .normal)![.font] as! UIFont).pointSize
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: fontSize * 3.3)
        
        tableView.anchor(top: segmentedControl.bottomAnchor, left: segmentedControl.leftAnchor, bottom: view.bottomAnchor, right: segmentedControl.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        historySpinner.centerInSuperview()
        
        historyPlaceholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        historyPlaceholderLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -40).activate()
        
        scrollView.anchor(top: segmentedControl.bottomAnchor, left: segmentedControl.leftAnchor, bottom: view.bottomAnchor, right: segmentedControl.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        scrollViewContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        scrollViewContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).activate()
        
        layoutScrollViewContentViewConstraints()
    }
    
    private func configureScrollViewContentViewHierarchy() {
        scrollViewContentView.addSubview(phoneNumberLabel)
        scrollViewContentView.addSubview(agentOnlyNameHeaderLabel)
        scrollViewContentView.addSubview(agentOnlyNameTextField)
        scrollViewContentView.addSubview(agentOnlyNameFooterLabel)
        scrollViewContentView.addSubview(globalNameHeaderLabel)
        scrollViewContentView.addSubview(globalNameTextField)
        scrollViewContentView.addSubview(updateButton)
        scrollViewContentView.addSubview(detailsSpinner)
        scrollViewContentView.addSubview(detailsPlaceholderLabel)
    }
    private func layoutScrollViewContentViewConstraints() {
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        let textFieldHeight = agentOnlyNameTextField.font!.pointSize * 2.8
        
        phoneNumberLabel.anchor(top: scrollViewContentView.topAnchor, left: scrollViewContentView.leftAnchor, bottom: nil, right: scrollViewContentView.rightAnchor, topConstant: viewHeight / 12, leftConstant: viewWidth / 18, bottomConstant: 0, rightConstant: viewWidth / 18)
        
        agentOnlyNameHeaderLabel.anchor(top: phoneNumberLabel.bottomAnchor, left: scrollViewContentView.leftAnchor, bottom: nil, right: scrollViewContentView.rightAnchor, topConstant: viewHeight / 18, leftConstant: viewWidth / 11.5, bottomConstant: 0, rightConstant: viewWidth / 13)
        
        agentOnlyNameTextField.anchor(top: agentOnlyNameHeaderLabel.bottomAnchor, left: scrollViewContentView.leftAnchor, bottom: nil, right: scrollViewContentView.rightAnchor, topConstant: 5, leftConstant: viewWidth / 13, bottomConstant: 0, rightConstant: viewWidth / 13, heightConstant: textFieldHeight)
        
        agentOnlyNameFooterLabel.anchor(top: agentOnlyNameTextField.bottomAnchor, left: agentOnlyNameHeaderLabel.leftAnchor, bottom: nil, right: agentOnlyNameHeaderLabel.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        globalNameHeaderLabel.anchor(top: agentOnlyNameFooterLabel.bottomAnchor, left: agentOnlyNameHeaderLabel.leftAnchor, bottom: nil, right: agentOnlyNameHeaderLabel.rightAnchor, topConstant: 24, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        globalNameTextField.anchor(top: globalNameHeaderLabel.bottomAnchor, left: agentOnlyNameTextField.leftAnchor, bottom: nil, right: agentOnlyNameTextField.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: textFieldHeight)
        
        updateButton.topAnchor.constraint(equalTo: globalNameTextField.bottomAnchor, constant: 40).activate()
        updateButton.centerXAnchor.constraint(equalTo: scrollViewContentView.centerXAnchor).activate()
        
        detailsSpinner.centerXAnchor.constraint(equalTo: updateButton.centerXAnchor).activate()
        detailsSpinner.centerYAnchor.constraint(equalTo: updateButton.centerYAnchor).activate()
        
        detailsPlaceholderLabel.anchor(top: updateButton.bottomAnchor, left: scrollViewContentView.leftAnchor, bottom: scrollViewContentView.bottomAnchor, right: scrollViewContentView.rightAnchor, topConstant: 30, leftConstant: 22, bottomConstant: 22, rightConstant: 22)
    }
    
    
    
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardNotificationsObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc
    private func adjustForKeyboard(_ notification: NSNotification) {
        guard let keyboardValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            let activeTextField: UIView? = [agentOnlyNameTextField, globalNameTextField].first { $0.isFirstResponder }
            if activeTextField != nil {
                var contentInset = scrollView.contentInset
                contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
//                let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: view).maxY
//                if bottomOfTextField > keyboardScreenEndFrame.origin.y {
//                    scrollView.contentOffset = CGPoint.init(x: scrollView.contentOffset.x, y: activeTextField.frame.maxY)
//                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 100)
//                }
                
                if scrollView.contentInset.bottom == 0 {
                    var newInset = contentInset
                    newInset.bottom += 10
                    scrollView.contentInset = newInset
                    scrollView.scrollIndicatorInsets = contentInset
                }
            }
        }
    }
    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        
    }
}
