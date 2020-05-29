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

extension MessagesController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = !trimmedText.isEmpty
        guard isEnabled else {
            print("Should present quick responses")
            return
        }
        
        guard let key = reference.childByAutoId().key else {
            print("Failed to create Firebase new key")
            return
        }
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
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
}
