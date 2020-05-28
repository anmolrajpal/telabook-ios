//
//  AutoResponseHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AutoResponseViewController {
    
    internal func setupTargetActions() {
        subview.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        subview.saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSaveButton() {
        guard isFetchedResultsAvailable else { return }
        guard let responseID = fetchedResultsController.fetchedObjects?.first?.id,
            responseID != 0 else {
            print("AutoResponse Object not exist or Failed to unwrap Response ID")
            return
        }
        DispatchQueue.main.async {
            self.subview.spinner.startAnimating()
        }
        self.updateAutoResponse(forID: Int(responseID))
    }
    
    
    internal func stopRefreshers() {
        DispatchQueue.main.async {
            self.subview.spinner.stopAnimating()
        }
    }
    
    
    
    
    internal func fetchWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let firstObject = fetchedResultsController.fetchedObjects?.first,
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                
                if firstObject.synced == true {
                    let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(13)
                    let currentTime = Date()
                    currentTime > thresholdRefreshTime ? fetchAutoResponse() : ()
                    #if DEBUG
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
}
