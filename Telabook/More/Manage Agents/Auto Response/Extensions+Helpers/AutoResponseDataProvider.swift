//
//  AutoResponseDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit




/*
extension AutoResponseViewController {
    internal func initiateFetchAutoResponseDetailsSequence(userId:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Loading...", controller: self)
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, action: UIAlertAction(title: "Ok", style: .destructive, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }), controller: self)
                    })
                    
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    self.fetchAutoResponseDetails(token:token, userId: userId)
                }
            }
        }
    }
    fileprivate func fetchAutoResponseDetails(token:String, userId:String) {
        AutoResponseAPI.shared.fetchAutoResponseSettings(token: token, userId: userId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Auto Response Settings****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, action: UIAlertAction(title: "Ok", style: .destructive, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }), controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Auto Response Settings****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, action: UIAlertAction(title: "Ok", style: .destructive, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }), controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    DispatchQueue.main.async {
                        print("***Error Fetching Auto Response Details****\nInvalid Response: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Invalid Response: Status => \(status)", action: UIAlertAction(title: "Ok", style: .destructive, handler: { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }), controller: self)
                        })
                    }
                    return
                }
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(AgentDetailsCodable.self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                print(result)
                                self.autoResponseDetails = result
                            })
                        }
                    } catch let err {
                        print("Error: Unable to decode data. => \(err.localizedDescription)")
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, action: UIAlertAction(title: "Ok", style: .destructive, handler: { (action) in
                                    self.dismiss(animated: true, completion: nil)
                                }), controller: self)
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    internal func initiateSaveAutoResponseDetailsSequence(userId:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Saving...", controller: self)
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
                    self.saveAutoResponseDetails(token:token, userId: userId)
                }
            }
        }
    }
    fileprivate func saveAutoResponseDetails(token:String, userId:String) {
        
        let call_forward_status = self.callForwardingSwitch.isOn
        let sms_auto_reply_status = self.smsAutoReplySwitch.isOn
        let sms_auto_reply_text = self.autoReplyTextView.text ?? ""
        AutoResponseAPI.shared.saveAutoResponseSettings(token: token, userId: userId, callForwardStatus: call_forward_status, voiceMailAutoReplyStatus: false, smsAutoReplyStatus: sms_auto_reply_status, voiceMailAutoReply: "", smsAutoReply: sms_auto_reply_text) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Saving Auto Response Details****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Saving Auto Response Details****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Unable to save auto response details(Invalid Response)****Response Status: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Invalid Response: Status => \(status)", controller: self)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.fetchAutoResponseDetails(token: token, userId: userId)
                }
            }
        }
    }
}
*/
