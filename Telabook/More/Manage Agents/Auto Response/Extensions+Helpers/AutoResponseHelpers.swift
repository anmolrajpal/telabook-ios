//
//  AutoResponseHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
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
//        self.initiateSaveAutoResponseDetailsSequence(userId: userId)
    }
    
    
    
    
    
    internal func fetchWithTimeLogic() {
        if isFetchedResultsAvailable {
            if let firstObject = fetchedResultsController.fetchedObjects?.first,
                let lastRefreshedAt = firstObject.lastRefreshedAt {
                let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(5)
                let currentTime = Date()
                currentTime > thresholdRefreshTime ? fetchAutoResponse() : ()
                #if DEBUG
                print("\n\n\tLast Refreshed At: \(Date.getStringFromDate(date: lastRefreshedAt, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Threshold Refresh Time: \(Date.getStringFromDate(date: thresholdRefreshTime, dateFormat: "yyyy-MM-dd HH:mm:ss")) | Current time: \(Date.getStringFromDate(date: currentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")))\n\n")
                #endif
            }
        } else {
            fetchAutoResponse()
        }
    }
}
