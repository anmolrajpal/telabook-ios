//
//  QuickResponsesDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit



/*

extension QuickResponsesViewController {
    internal func initiateFetchQuickResponsesSequence(userId:String) {
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
                DispatchQueue.main.async {
                    self.fetchQuickResponses(token:token, userId: userId)
                }
            }
        }
    }
    fileprivate func fetchQuickResponses(token:String, userId:String) {
        QuickResponsesAPI.shared.fetchQuickResponses(token: token, userId: userId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Quick Responses****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Quick Responses****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            print("***No Quick Responses(Empty Response)****Response Status: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.placeholderLabel.isHidden = false
                                self.placeholderLabel.text = "No Saved Responses"
                                self.tableView.isHidden = true
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("***Error Fetching Quick Responses****\nInvalid Response: \(status)")
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
                        let result = try decoder.decode(QuickResponsesCodable.self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.quickResponses = result.answers
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
    
    
    
    
    
    internal func initiateAddQuickResponseSequence(userId:String, answer:String) {
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
                    self.addQuickResponse(token:token, userId: userId, answer: answer)
                }
            }
        }
    }
    fileprivate func addQuickResponse(token:String, userId:String, answer:String) {
        QuickResponsesAPI.shared.addQuickResponse(token: token, userId: userId, answer: answer) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Saving Quick Response****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Saving Quick Response****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Unable to add quick response(Invalid Response)****Response Status: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            print("Bla bla bla")
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.fetchQuickResponses(token: token, userId: userId)
                    self.responseTextView.text.removeAll()
                    self.characterCountLabel.text = "Max Characters: 70"
                    self.saveResponseButton.isEnabled = false
                    self.saveResponseButton.backgroundColor = UIColor.telaGray6
                }
            }
        }
    }
    
    
    
    internal func initiateUpdateQuickResponseSequence(userId:String, answer:String, responseId:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Updating...", controller: self)
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
                    self.updateQuickResponse(token:token, userId: userId, answer: answer, responseId: responseId)
                }
            }
        }
    }
    fileprivate func updateQuickResponse(token:String, userId:String, answer:String, responseId:String) {
        QuickResponsesAPI.shared.updateQuickResponse(token: token, userId: userId, answer: answer, responseId: responseId) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Updating Quick Response****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Updating Quick Response****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Unable to update quick response(Invalid Response)****Response Status: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.fetchQuickResponses(token: token, userId: userId)
                }
            }
        }
    }
    
    
    
    
    internal func initiateDeleteQuickResponseSequence(at indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Deleting...", controller: self)
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                        completion(false)
                    })
                    
                }
            } else if let token = token {
                
                DispatchQueue.main.async {
                    self.deleteQuickResponse(token:token, userId: self.userId, indexPath: indexPath, completion: completion)
                }
            }
        }
    }
    fileprivate func deleteQuickResponse(token:String, userId:String,  indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        guard let responseId = quickResponses?[indexPath.row].id,
            responseId != 0 else {
                DispatchQueue.main.async {
                    print("***Error Deleting Quick Response****\nResponse ID = 0")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: "Invalid Response ID", controller: self)
                        completion(false)
                    })
                }
                return
        }
        QuickResponsesAPI.shared.deleteQuickResponse(token: token, userId: userId, responseId: String(responseId)) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Deleting Quick Response****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                        completion(false)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Deleting Quick Response****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                        completion(false)
                    })
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Unable to delete quick response(Invalid Response)****Response Status: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                            completion(false)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        self.quickResponses?.remove(at: indexPath.row)
                        completion(true)
                    })
                }
            }
        }
    }
    
    
    
    
    
}





*/
