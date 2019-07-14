//
//  ScheduleMessageDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
extension ScheduleMessageViewController {
    internal func initiateFetchScheduledMessagesSequence() {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Loading...", controller: self)
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
                let userId = UserDefaults.standard.currentSender.id
                DispatchQueue.main.async {
                    self.fetchScheduledMessages(token:token, userId: userId)
                }
            }
        }
    }
    fileprivate func fetchScheduledMessages(token:String, userId:String) {
        ScheduleMessageAPI.shared.fetchScheduledMessages(token: token, userId: userId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Scheduled Messages****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Scheduled Messages****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            print("***No Scheduled Messages(Empty Response)****Response Status: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.placeholderLabel.isHidden = false
                                self.placeholderLabel.text = "No Scheduled Messages"
                                self.tableView.isHidden = true
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("***Error Fetching Scheduled Messages****\nInvalid Response: \(status)")
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
                        let result = try decoder.decode(ScheduleMessagesCodable.self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.scheduledMessages = result.scheduleMessages
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
