//
//  HandleBlockingHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
extension SMSDetailViewController {
    
    //MARK: BLOCKING HERPERS
    
    internal func initiateBlockNumberSequence(indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        UIAlertController.showModalSpinner(controller: self)
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    completion(false)
                    self.showAlert(title: "Error", message: err.localizedDescription)
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    self.blockNumber(token: token, indexPath: indexPath, completion: completion)
                }
            }
        }
    }
    fileprivate func blockNumber(token:String, indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        let companyId = UserDefaults.standard.getCompanyId()
        if let conversation = self.fetchedResultsController.object(at: indexPath) as? ExternalConversation {
            let conversationId = conversation.externalConversationId
            guard let number = conversation.customerPhoneNumber else {
                print("Customer Phone Number => nil")
                return
            }
            ExternalConversationsAPI.shared.blockNumber(token: token, companyId: String(companyId), conversationId: String(conversationId), number: number) { (responseStatus, data, serviceError, error) in
                if let err = error {
                    DispatchQueue.main.async { UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error handling Blocking****\n\(err.localizedDescription)")
                        self.showAlert(title: "Error", message: err.localizedDescription)
                        completion(false)
                    }
                } else if let serviceErr = serviceError {
                    DispatchQueue.main.async { UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error handling Blocking****\n\(serviceErr.localizedDescription)")
                        self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                        completion(false)
                    }
                } else if let status = responseStatus {
                    guard status == .Created else {
                        DispatchQueue.main.async {    UIAlertController.dismissModalSpinner(controller: self)
                            print("***Error Blocking Chat****\nInvalid Response: \(status)")
                            self.showAlert(title: "\(status)", message: "Unable to Archive Chat. Please try again")
                            completion(false)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.deleteConversationFromCoreData(id: conversationId, completion: completion)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                UIAlertController.dismissModalSpinner(controller: self)
                print("***Error Handling Blocking****\nConversation not found")
                self.showAlert(title: "Error", message: "Conversation not found. Unable to handle Blocking. Please try again")
                completion(false)
            }
        }
        
    }
    fileprivate func deleteConversationFromCoreData(id:Int16, completion: @escaping (Bool) -> ()) {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: ExternalConversation.self), in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExternalConversation")
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "externalConversationId = %d", id)
        do {
            let result = try managedObjectContext.fetch(request)
            if result.count > 0 {
                let managedObject = result.first as! NSManagedObject
                managedObjectContext.delete(managedObject)
                try managedObjectContext.save()
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        completion(true)
                    })
                }
            }
        } catch let error {
            DispatchQueue.main.async {
                UIAlertController.dismissModalSpinner(controller: self)
                print(error.localizedDescription)
                completion(false)
            }
        }
    }

}


extension BlockedUsersViewController {
    
    //MARK: FETCH BLACKLIST HERPERS
    internal func initiateFetchBlacklistSequence() {
        UIAlertController.showModalSpinner(controller: self)
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
                    self.fetchBlacklist(token:token)
                }
            }
        }
    }
    fileprivate func fetchBlacklist(token:String) {
        let companyId = UserDefaults.standard.getCompanyId()
        ExternalConversationsAPI.shared.fetchBlacklist(token: token, companyId: String(companyId)) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Fetching Blacklist****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Fetching Blacklist****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            print("***No Blocked Users(Empty Response)****Response Status: \(status)")
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.placeholderLabel.isHidden = false
                                self.placeholderLabel.text = "No Blocked Users"
                                self.tableView.isHidden = true
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("***Error Fetching Blacklist****\nInvalid Response: \(status)")
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
                        let result = try decoder.decode([BlacklistCodable].self, from: data)
                        DispatchQueue.main.async {
                            UIAlertController.dismissModalSpinner(controller: self, completion: {
                                self.blacklist = result
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
    
    
    
    //MARK: UNBLOCKING HERLPERS
    
    internal func initiateUnblockNumberSequence(at indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        UIAlertController.showModalSpinner(controller: self)
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
            } else if let token = token,
                let blacklistItem = self.blacklist?[indexPath.row],
                let number = blacklistItem.number,
                let id = blacklistItem.id {
                DispatchQueue.main.async {
                    self.unblockNumber(token:token, id:String(id), number:number, indexPath:indexPath, completion: completion)
                }
            } else {
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: "Failed to unwrap values", controller: self)
                        completion(false)
                    })
                }
            }
        }
    }
    fileprivate func unblockNumber(token:String, id:String, number:String, indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        let companyId = UserDefaults.standard.getCompanyId()
        ExternalConversationsAPI.shared.unblockNumber(token: token, companyId: String(companyId), id: id, number: number) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    print("***Error Unblocking Number****\n\(err.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                        completion(false)
                    })
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    print("***Error Unblocking Number****\n\(serviceErr.localizedDescription)")
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription, controller: self)
                        completion(false)
                    })
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    DispatchQueue.main.async {    UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error Unblocking Number****\nInvalid Response: \(status)")
                        UIAlertController.dismissModalSpinner(controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Response => \(status)", controller: self)
                            completion(false)
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self, completion: {
                        self.blacklist?.remove(at: indexPath.row)
                        completion(true)
                    })
                }
            }
        }
    }
}
