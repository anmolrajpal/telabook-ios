//
//  AutoResponseHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AutoResponseViewController {
    
    
    internal func commonInit() {
        hideKeyboardWhenTappedAround()
        configureTargetActions()
        setupData()
        fetchAutoResponse()
    }
    internal func setupData() {
        guard let autoResponse = agent.autoResponse else {
            return
        }
        subview.autoReplyTextView.text = autoResponse.smsReply
    }
    private func configureTargetActions() {
        subview.cancelButton.addTarget(self, action: #selector(cancelButtonDidTapped(_:)), for: .touchUpInside)
        subview.saveButton.addTarget(self, action: #selector(saveButtonDidTap(_:)), for: .touchUpInside)
    }
    
    @objc private func cancelButtonDidTapped(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonDidTap(_ button: UIButton) {
        updateAutoResponse()
    }
    
    func startSpinner() {
        DispatchQueue.main.async {
            self.subview.spinner.startAnimating()
        }
    }
    
    func stopSpinner() {
        DispatchQueue.main.async {
            self.subview.spinner.stopAnimating()
        }
    }
    
    
    
    /*
    internal func fetchWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let firstObject = fetchedResultsController.fetchedObjects?.first,
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                
                if firstObject.synced == true {
                    let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(13)
                    let currentTime = Date()
                    currentTime > thresholdRefreshTime ? fetchAutoResponse() : ()
                    #if !RELEASE
                    print("\n\n\tLast Refreshed At: \(Date.getStringFromDate(date: lastRefreshedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Threshold Refresh Time: \(Date.getStringFromDate(date: thresholdRefreshTime, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Current time: \(Date.getStringFromDate(date: currentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")))\n\n")
                    #endif
                } else {
                    updateAutoResponse(forID: Int(firstObject.id))
                }
            }
        } else {
            fetchAutoResponse()
        }
    }
    */
}
