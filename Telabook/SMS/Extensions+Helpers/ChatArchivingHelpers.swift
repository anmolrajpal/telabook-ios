//
//  ChatArchivingHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
extension SMSDetailViewController {
    internal func initiateChatArchivingSequence(markArchive:Bool, indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
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
                    self.handleChatArchiving(token: token, markArchive: markArchive, indexPath: indexPath, completion: completion)
                }
            }
        }
    }
    fileprivate func handleChatArchiving(token:String, markArchive:Bool, indexPath:IndexPath, completion: @escaping (Bool) -> ()) {
        let companyId = UserDefaults.standard.getCompanyId()
        if let conversation = self.fetchedResultsController.object(at: indexPath) as? ExternalConversation {
            let conversationId = conversation.externalConversationId
            ExternalConversationsAPI.shared.handleArchiving(token: token, companyId: String(companyId), conversationId: String(conversationId), markArchive: markArchive) { (responseStatus, data, serviceError, error) in
                if let err = error {
                       DispatchQueue.main.async { UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error handling Archiving****\n\(err.localizedDescription)")
                        self.showAlert(title: "Error", message: err.localizedDescription)
                        completion(false)
                    }
                } else if let serviceErr = serviceError {
                       DispatchQueue.main.async { UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error handling Archiving****\n\(serviceErr.localizedDescription)")
                        self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                        completion(false)
                    }
                } else if let status = responseStatus {
                    if markArchive {
                        guard status == .Created else {
                            DispatchQueue.main.async {    UIAlertController.dismissModalSpinner(controller: self)
                                print("***Error Archiving Chat****\nInvalid Response: \(status)")
                                self.showAlert(title: "\(status)", message: "Unable to Archive Chat. Please try again")
                                completion(false)
                            }
                            return
                        }
                        if let conversation = self.fetchedResultsController.object(at: indexPath) as? ExternalConversation {
                            let id = conversation.externalConversationId
                            guard id != 0 else {
                                   DispatchQueue.main.async { UIAlertController.dismissModalSpinner(controller: self)
                                    completion(false)
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.updateChatInCoreData(id: conversationId, markArchive: markArchive, completion: completion)
                            }
                        }
                    } else {
                        guard status == .OK else {
                               DispatchQueue.main.async { UIAlertController.dismissModalSpinner(controller: self)
                                print("***Error Unarchiving Chat****\nInvalid Response: \(status)")
                                self.showAlert(title: "\(status)", message: "Unable to Archive Chat. Please try again")
                                completion(false)
                            }
                            return
                        }
                        if let data = data {
                            print(data as Any)
                        }
                        DispatchQueue.main.async {
                            self.updateChatInCoreData(id: conversationId, markArchive: markArchive, completion: completion)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                UIAlertController.dismissModalSpinner(controller: self)
                print("***Error Handling Archiving****\nConversation not found")
                self.showAlert(title: "Error", message: "Conversation not found. Unable to handle Archiving. Please try again")
                completion(false)
            }
        }
        
    }
    fileprivate func updateChatInCoreData(id:Int16, markArchive:Bool, completion: @escaping (Bool) -> ()) {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: ExternalConversation.self), in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExternalConversation")
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "externalConversationId = %d", id)
        do {
            let result = try managedObjectContext.fetch(request)
            if result.count > 0 {
                let managedObject = result[0] as! NSManagedObject
                managedObject.setValue(markArchive, forKey: "isArchived")
                try managedObjectContext.save()
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    completion(true)
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
