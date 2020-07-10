//
//  MoreServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//


import UIKit
import os
import PINCache
extension MoreViewController {
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func dumpCoreData() {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = DeleteAllEntities_Operation(context: PersistentContainer.shared.newBackgroundContext())
        handleViewsStateForOperations(operations: [operation], onOperationQueue: queue)
        
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    func alertLogout() {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        let alertVC = UIAlertController.telaAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setTitleColor(color: .telaBlue)
        let logoutAction = UIAlertAction(title: "Log Out", style: .default) { _ in self.callSignOutSequence() }
        logoutAction.setTitleColor(color: .systemRed)
        
        alertVC.addAction(logoutAction)
        alertVC.addAction(cancelAction)
        alertVC.preferredAction = logoutAction
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func callSignOutSequence() {
        FirebaseAuthService.shared.signOut { (error) in
            guard error == nil else {
                UIAlertController.showTelaAlert(title: "Signout Failed", message: error?.localizedDescription ?? "Try again", controller: self)
                return
            }
            if AppData.isRememberMeChecked {
                DispatchQueue.main.async {
                    self.delegate?.presentLogin()
                }
            } else {
                self.dumpCoreData()
            }
        }
    }
    
    
    
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            switch operation {
                /* ------------------------------------------------------------------------------------------------------------ */
                //MARK: Delete All Entities Operation completion
                case let operation as DeleteAllEntities_Operation:
                    operation.completionBlock = {
                        if let error = operation.error {
                            self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                        } else {
                            DispatchQueue.main.async {
                                self.delegate?.presentLogin()
                            }
                        }
                }
                default: break
            }
        }
    }
    
    
    
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                if let completionHandler = completion { completionHandler() }
            }), controller: self, completion: {
                queue.cancelAllOperations()
            })
        }
    }
}
