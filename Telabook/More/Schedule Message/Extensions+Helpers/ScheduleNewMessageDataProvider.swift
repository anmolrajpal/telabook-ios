//
//  ScheduleNewMessageDataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
extension ScheduleNewMessageViewController {
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func scheduleNewMessage(textMessage:String, deliveryTime:String, customerID:Int, workerID:Int) {
        startSpinner()
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let operation = ScheduleNewMessageOnServer_Operation(customerID: customerID, workerID: workerID, deliveryTime: deliveryTime, textMessage: textMessage)
        operation.completionBlock = {
            switch operation.result {
                case let .failure(error): self.handleFaliure(error: error)
                case .success: self.handleSuccess()
                default: break
            }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
   
    private func handleSuccess() {
        DispatchQueue.main.async {
            self.stopSpinner()
            TapticEngine.generateFeedback(ofType: .Success)
            self.delegate?.controllerDidScheduleNewMessage(controller: self)
        }
    }
    private func handleFaliure(error: APIService.APIError) {
        DispatchQueue.main.async {
            TapticEngine.generateFeedback(ofType: .Error)
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.stopSpinner()
            }), controller: self)
        }
    }
    
    
    
    
    
    
    internal func initiateScheduleNewMessageSequence(workerId:String, customerId:String, date:String, text:String) {
        DispatchQueue.main.async {
            UIAlertController.showModalSpinner(with: "Scheduling...", controller: self)
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
                    self.scheduleMessage(token: token, workerId: workerId, customerId: customerId, date: date, text: text)
                }
            }
        }
    }
    fileprivate func scheduleMessage(token:String, workerId:String, customerId:String, date:String, text:String) {
        ScheduleMessageAPI.shared.scheduleMessage(token: token, customerId: customerId, workerId: workerId, text: text, date: date) { (responseStatus, data, serviceError, error) in
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
                guard status == .Created else {
                    DispatchQueue.main.async {
                        print("***Error Fetching Scheduled Messages****\nInvalid Response: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Message Scheduled", message: "Your message has been scheduled successfully", action: UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        }), controller: self)
                    })
                }
            }
        }
    }
}
