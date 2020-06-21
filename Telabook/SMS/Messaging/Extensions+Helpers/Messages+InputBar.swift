//
//  Messages+InputBar.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import InteractiveModal

extension MessagesController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = !trimmedText.isEmpty
        guard isEnabled else {
            showQuickResponsePicker()
            return
        }
        
        guard let key = reference.childByAutoId().key else {
            #if !RELEASE
            print("Failed to create Firebase new key")
            #endif
            return
        }
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        didSentNewMessage = true
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                self?.analyseMessage(fromComponents: components, key: key)
                self?.messageInputBar.inputTextView.placeholder = "Aa"
            }
        }
    }
    
    private func analyseMessage(fromComponents data: [Any], key:String) {
        for component in data {
            if let str = component as? String {
                let message = NewMessage(kind: .text(str), messageId: key, sender: thisSender, sentDate: Date())
                print(message)
                self.sendNewTextMessage(newMessage: message)
            } else if let _ = component as? UIImage {

            }
        }
    }
    
    
    private func showQuickResponsePicker() {
        
        guard let quickResponses = customer.agent?.quickResponses?.allObjects as? [QuickResponse] else {
            #if !RELEASE
            print("Failed to cast NSSet to quick responses")
            #endif
            return
        }
        let vc = QuickResponsePickerController(responses: quickResponses)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        let presenter = InteractiveModalViewController(controller: navController)
        self.present(presenter, animated: true, completion: nil)
    }
}

extension MessagesController: AgentGalleryImagePickerDelegate {
    func agentGalleryController(didPickImage image: UIImage, forGalleryItem item: AgentGalleryItem, at indexPath: IndexPath) {
        print("Should upload image")
    }
}

extension MessagesController: QuickResponsePickerDelegate {
    func quickResponseDidPick(at indexPath: IndexPath, response: QuickResponse) {
        guard let text = response.answer else { return }
        guard let key = reference.childByAutoId().key else {
            #if !RELEASE
            print("Failed to create Firebase new key")
            #endif
            return
        }
        let message = NewMessage(kind: .text(text), messageId: key, sender: thisSender, sentDate: Date())
        self.sendNewTextMessage(newMessage: message)
    }
    
    func manageButtonDidTap() {
        guard let worker = customer.agent else {
            #if !RELEASE
            print("Failed to get access agent from customer")
            #endif
            return
        }
        let objectID = worker.objectID
        let referenceAgent = viewContext.object(with: objectID) as! Agent
        let vc = QuickResponsesViewController(userID: Int(worker.userID), agent: referenceAgent)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}



// MARK: - Apple's new Background API Implementation
/*
// Guarding Important Tasks While App is Still in the Foreground
func send(_ message: Message) {
    let sendOperation = SendOperation(message: message)
    var identifier: UIBackgroundTaskIdentifier!
    identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        sendOperation.cancel()
        postUserNotification("Message not sent, please resend")
    })
    // Background task will be ended in the operation's completion block below
    sendOperation.completionBlock = {
    }
    UIApplication.shared.endBackgroundTask(identifier)
    operationQueue.addOperation(sendOperation)
}
*/
extension MessagesController: QuickResponsesModificationDelegate {
    func didExitQuickResponsesSettings() {
        self.reloadQuickResponses()
    }
}
