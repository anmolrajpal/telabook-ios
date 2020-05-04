//
//  ManageAgentsServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit


extension ManageAgentsViewController {
    internal func fetchAgents() {
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = AgentOperations.getOperationsToFetchLatestEntries(using: context)
        handleViewsStateForOperations(operations: operations, onOperationQueue: queue)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func handleViewsStateForOperations(operations:[Operation], onOperationQueue queue:OperationQueue) {
        operations.forEach { operation in
            if let operation = operation as? FetchMostRecentAgentsEntryOperation {
                operation.completionBlock = {
                    if case let .failure(error) = operation.result {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    } else {
                        DispatchQueue.main.async {
                            self.updateSnapshot()
                        }
                    }
                }
            } else if let operation = operation as? DownloadAgentsEntriesFromServerOperation {
                operation.completionBlock = {
                    guard case let .failure(error) = operation.result else { return }
                    print(error.localizedDescription)
                    self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                }
            } else if let operation = operation as? DeleteRedundantAgentEntriesOperation {
                operation.completionBlock = {
                    if let error = operation.error {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    }
                }
            } else if let operation = operation as? UpdateAgentEntriesOperation {
                operation.completionBlock = {
                    if let error = operation.error {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    }
                }
            } else if let operation = operation as? AddAgentEntriesToStoreOperation {
                operation.completionBlock = {
                    if let error = operation.error {
                        print(error.localizedDescription)
                        self.showAlert(withErrorMessage: error.localizedDescription, cancellingOperationQueue: queue)
                    } else {
                        DispatchQueue.main.async {
                            self.stopRefreshers()
                            self.updateSnapshot()
                        }
                    }
                }
            }
        }
    }
    
    
    private func showAlert(withErrorMessage message:String, cancellingOperationQueue queue:OperationQueue) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .destructive, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }), controller: self, completion: {
                queue.cancelAllOperations()
                self.stopRefreshers()
            })
        }
    }
}



/*
extension ManageAgentsViewController {
    internal func initiateFetchAgentsSequence() {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(controller: self)
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                    
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    self.fetchAgents(token:token)
                }
            }
        }
    }
    
    
    fileprivate func fetchAgents(token:String) {
        let companyId = AppData.companyId
        ManageAgentsAPI.shared.fetchAgents(token: token, companyId: String(companyId)) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Agents****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Agents****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            print("***No Agents(Empty Response)****Response Status: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.placeholderLabel.isHidden = false
                                self.placeholderLabel.text = "No Agents"
                                self.tableView.isHidden = true
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("***Error Fetching Agents****\nInvalid Response: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                            })
                        }
                    }
                    return
                }
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode([InternalConversationsCodable].self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.agents = result
                            })
                        }
                    } catch let err {
                        print("Error: Unable to decode data. => \(err.localizedDescription)")
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                            })
                        }
                    }
                }
            }
        }
    }
}
*/
