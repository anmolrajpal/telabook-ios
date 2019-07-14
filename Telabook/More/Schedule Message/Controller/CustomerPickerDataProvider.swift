//
//  CustomerPickerDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension CustomerPickerViewController {
    internal func initiateFetchAgentsSequence(workerId:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Fetching Customers...", controller: self)
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
                    self.fetchCustomers(token:token, workerId: workerId)
                }
            }
        }
    }
    fileprivate func fetchCustomers(token:String, workerId:String) {
        let companyId = UserDefaults.standard.getCompanyId()
        CustomerAPI.shared.fetchCustomers(token: token, companyId: String(companyId), workerId: workerId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Customers****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Customers****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            print("***No Customers(Empty Response)****Response Status: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.placeholderLabel.isHidden = false
                                self.placeholderLabel.text = "No Customers"
                                self.tableView.isHidden = true
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("***Error Fetching Customers****\nInvalid Response: \(status)")
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
                        let result = try decoder.decode([ExternalConversationsCodable].self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.customers = result
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
