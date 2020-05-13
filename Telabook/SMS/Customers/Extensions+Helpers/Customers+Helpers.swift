//
//  Customers+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

extension CustomersViewController {
    internal func setupNavBarItems() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItems = [addButton]
    }
    @objc func addButtonTapped() {
        let newContactVC = NewContactViewController()
        newContactVC.modalPresentationStyle = .overFullScreen
        newContactVC.view.backgroundColor = .telaGray1
//        newContactVC.delegate = self
        self.present(newContactVC, animated: true, completion: nil)
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
                    self.subview.inboxPlaceholderLabel.text = "No Customer"
                    DispatchQueue.main.async {
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
        conversation.ref?.updateChildValues([
            "colour" : color.code
            ], withCompletionBlock: { (error, reference) in
                if let error = error {
                    print("Error: unable to update color on Firebase: \(error)")
                }
        })
    }
}
