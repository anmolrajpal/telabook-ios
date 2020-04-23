//
//  ChatColorHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
extension SMSDetailViewController {
    
    internal func promptChatColor(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Set Chat Color", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let defaultAction = UIAlertAction(title: "Default", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Default, indexPath: indexPath)
        })
        
        let yellowAction = UIAlertAction(title: "Yellow", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Yellow, indexPath: indexPath)
        })
        let greenAction = UIAlertAction(title: "Green", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Green, indexPath: indexPath)
        })
        let blueAction = UIAlertAction(title: "Blue", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Blue, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil)
        alert.addAction(defaultAction)
        alert.addAction(yellowAction)
        alert.addAction(greenAction)
        alert.addAction(blueAction)
        alert.addAction(cancelAction)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        
        alert.view.tintColor = UIColor.telaBlue
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alert.view.subviews.first?.backgroundColor = .clear
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleChatColorSequence(color:ConversationColor, indexPath:IndexPath) {
        UIAlertController.showModalSpinner(controller: self)
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    self.showAlert(title: "Error", message: err.localizedDescription)
                }
            } else if let token = token {
                self.changeChatColor(token:token, color:color, indexPath: indexPath)
            }
        }
    }
    
    fileprivate func changeChatColor(token:String, color:ConversationColor, indexPath:IndexPath) {
        let companyId = AppData.companyId
        if let conversation = self.fetchedResultsController.object(at: indexPath) as? ExternalConversation {
            let conversationId = conversation.externalConversationId
            let colorCode = ConversationColor.getColorCodeBy(color: color)
            ExternalConversationsAPI.shared.setColor(token: token, companyId: String(companyId), conversationId: String(conversationId), colorCode: String(colorCode)) { (responseStatus, data, serviceError, error) in
                if let err = error {
                    UIAlertController.dismissModalSpinner(controller: self)
                    print("***Error Setting Color****\n\(err.localizedDescription)")
                    self.showAlert(title: "Error", message: err.localizedDescription)
                } else if let serviceErr = serviceError {
                    UIAlertController.dismissModalSpinner(controller: self)
                    print("***Error Setting Color****\n\(serviceErr.localizedDescription)")
                    self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                } else if let status = responseStatus {
                    guard status == .Created else {
                        UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error Setting Color****\nInvalid Response: \(status)")
                        self.showAlert(title: "\(status)", message: "Unable to change color. Please try again")
                        return
                    }
                    DispatchQueue.main.async {
                        print("External Convo Id => \(conversationId) - type of \(type(of: conversationId)) & color code=> \(colorCode)")
                        self.updateColorInCoreData(id: conversationId, color: Int16(colorCode))
                    }
                    if let data = data {
                        print("Data length => \(data.count)")
                        print("Data => \(data)")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                UIAlertController.dismissModalSpinner(controller: self)
                print("***Error Setting Color****\nCompany Id not found")
                self.showAlert(title: "Error", message: "Company ID not found. Unable to change color. Please try again")
            }
        }
        
    }
    
    fileprivate func updateColorInCoreData(id:Int16, color:Int16) {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: ExternalConversation.self), in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExternalConversation")
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "externalConversationId = %d", id)
        do {
            let result = try managedObjectContext.fetch(request)
            if result.count > 0 {
                let managedObject = result[0] as! NSManagedObject
                print(managedObject)
                managedObject.setValue(color, forKey: "colour")
                try managedObjectContext.save()
                UIAlertController.dismissModalSpinner(controller: self)
            }
        } catch let error {
            UIAlertController.dismissModalSpinner(controller: self)
            print(error.localizedDescription)
        }
    }

}
