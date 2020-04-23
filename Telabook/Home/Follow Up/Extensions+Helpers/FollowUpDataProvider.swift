//
//  FollowUpDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension FollowUpViewController {
    //MARK: FETCH FOLLOW UP INDEX HERPERS
    internal func initiateFetchFollowUpsIndexSequence() {
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
                    self.fetchFollowUpsIndex(token:token)
                }
            }
        }
    }
    fileprivate func fetchFollowUpsIndex(token:String) {
        let companyId = AppData.companyId
        FollowUpAPI.shared.fetchFollowUpsIndex(token: token, companyId: String(companyId)) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Follow Ups Index****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Follow Ups Index****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            print("***No Users to Follow Up(Empty Response)****Response Status: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.placeholderLabel.isHidden = false
                                self.placeholderLabel.text = "No Users to Follow Up"
                                self.tableView.isHidden = true
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("***Error Fetching Follow Ups****\nInvalid Response: \(status)")
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
                        let result = try decoder.decode([FollowUpsIndexCodable].self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.allPriorityFollowUps = result
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
