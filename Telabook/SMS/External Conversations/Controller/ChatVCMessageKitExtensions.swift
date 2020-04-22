//
//  ChatVCMessageKitExtensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

extension ChatViewController : MessagesDataSource {
    func currentSender() -> SenderType {
        guard let userId = AppData.userId else {
            fatalError("currentSender(): UserID not found in UserDefaults")
        }
        return Sender(senderId: userId, displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages.sort(by: { $0.sentDate < $1.sentDate })
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func isEarliest(_ message:Message) -> Bool {
        let filteredMessages = self.messages.filter{( Date.isDateSame(date1: message.sentDate, date2: $0.sentDate) )}
        return message == filteredMessages.min() ? true : false
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isEarliest(message as! Message) {
            let date = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.chatHeaderDate)
            return NSAttributedString(
                string: date,
                attributes: [
                    .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)!,
                    .foregroundColor: UIColor.telaGray7
                ]
            )
        }
        return nil
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let time = Date.getStringFromDate(date: message.sentDate, dateFormat: CustomDateFormat.hmma)
        return NSAttributedString(
            string: time,
            attributes: [
                .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)!,
                .foregroundColor: UIColor.telaGray6
            ]
        )
    }
}
extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .photo:
            return UIColor.telaGray7.withAlphaComponent(0.4)
        default:
            return isFromCurrentSender(message: message) ? .telaBlue : .telaGray7
        }
        
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .telaWhite
    }
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let msg = message as? Message,
            let url = msg.imageURL else {
                print("Optional Message Item")
                return
        }
        if let text = msg.imageTEXT,
            !text.isEmpty {
            print("Image Text here is => \(text)")
            let textView = UIView(frame: CGRect.zero)
            textView.backgroundColor = isFromCurrentSender(message: message) ? .telaBlue : .telaGray7
            textView.clipsToBounds = true
            let label = UILabel()
            label.text = text
            label.numberOfLines = 2
            label.textColor = UIColor.telaWhite
            textView.addSubview(label)
            label.anchor(top: textView.topAnchor, left: textView.leftAnchor, bottom: textView.bottomAnchor, right: textView.rightAnchor, topConstant: 5, leftConstant: 15, bottomConstant: 5, rightConstant: 10, widthConstant: 0, heightConstant: 0)
            imageView.addSubview(textView)
            textView.anchor(top: nil, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        imageView.loadImageUsingCache(with: url.absoluteString)
    }
}



extension ChatViewController: MessagesLayoutDelegate {
    
    
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isEarliest(message as! Message) ? 30.0 : 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    
}



extension ChatViewController : InputBarAccessoryViewDelegate {
    
    func messageInputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        //        messageInputBar.inputTextView.text = String()
        //        messageInputBar.invalidatePlugins()
        // Send button activity animation
        //        inputBar.sendButton.isEnabled = false
        inputBar.inputTextView.text = ""
        //        self.messagesCollectionView.scrollToBottom(animated: true)
        //        self.messageInputBar.sendButton.isEnabled = true
        //        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            
            DispatchQueue.main.async { [weak self] in
                //                self?.messageInputBar.inputTextView.placeholder = "New Message"
                self?.insertMessages(components)
                
            }
        }
    }
    private func insertMessages(_ data: [Any]) {
        //        let sender = UserDefaults.standard.currentSender
        for component in data {
            if let str = component as? String {
                DispatchQueue.main.async {
                    //                    self.insertMessage(Message(text: str, sender: UserDefaults.standard.currentSender, messageId: UUID().uuidString, date: Date()))
                    
                    self.handleSendingMessageSequence(message: str, type: .SMS)
                }
            } else if let _ = component as? UIImage {
                
                //                self.handleSendingMessageSequence(message: , type: .MMS)
            }
        }
    }
    internal func handleSendingMessageSequence(message:String, type:ChatMessageType) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.messageInputBar.sendButton.isEnabled = true
                    if type == .MMS {
                        UIAlertController.dismissModalSpinner(animated: true, controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription)
                        })
                    }
                }
            } else if let token = token {
                let id = self.conversationId
                print("External Conversation ID => \(id)")
                guard id != "0" else {
                    print("Error: External Convo ID => 0")
                    self.messageInputBar.sendButton.isEnabled = true
                    if type == .MMS {
                        UIAlertController.dismissModalSpinner(animated: true, controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Error", message: "Internal Application Error")
                        })
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.sendMessage(token: token, conversationId: id, message: message, type: type)
                }
                
            }
        }
    }
    private func sendMessage(token:String, conversationId:String, message:String, type:ChatMessageType) {
        ExternalConversationsAPI.shared.sendMessage(token: token, conversationId: conversationId, message: message, type: type, isDirectMessage: false) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(animated: true, controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription)
                    })
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(animated: true, controller: self, completion: {
                        UIAlertController.showTelaAlert(title: "Error", message: serviceErr.localizedDescription)
                    })
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        UIAlertController.dismissModalSpinner(animated: true, controller: self, completion: {
                            UIAlertController.showTelaAlert(title: "Message not sent", message: "Invalid Response. Status: \(status)")
                        })
                        self.messageInputBar.sendButton.isEnabled = true
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(animated: true, controller: self, completion: {
                        AssertionModalController(title: "Message Sent").show()
                    })
                }
            }
        }
    }
    
}
