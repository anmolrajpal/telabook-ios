//
//  ChatViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import Photos
import MessageKit
import MessageInputBar
import Firebase
import FirebaseStorage
final class ChatViewController : MessagesViewController {
    var messages:[Message] = []
    internal var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    //                    item.isEnabled = !self.isSendingPhoto
                    
                }
            }
        }
    }
    internal var storageUploadTask:StorageUploadTask!
    internal let conversationId:String
    internal let node:String
    var workerId:Int16?
    internal let externalConversation:ExternalConversation?
    init(conversationId: String, node: String) {
        self.conversationId = String(conversationId)
        print("External Conversation ID => \(conversationId)")
        self.node = node
        self.externalConversation = nil
        super.init(nibName: nil, bundle: nil)
        self.preLoadMessages(node: node)
    }
    init(conversationId: String, node: String, conversation:ExternalConversation) {
        self.conversationId = String(conversationId)
        print("External Conversation ID => \(conversationId)\nNode => \(node)\nWorker ID => \(self.workerId ?? 0)")
        self.node = node
        self.externalConversation = conversation
        super.init(nibName: nil, bundle: nil)
        self.preLoadMessages(node: node)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        print("Current Sender => \(String(describing: UserDefaults.standard.currentSender)))")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
 
    func preLoadMessages(node:String?) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.preLoadChats(node: node, completion: { (messages) in
                DispatchQueue.main.async {
                    self.messages = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            })
        }
    }
    
    func preLoadChats(node:String?, completion: @escaping ([Message]) -> Void) {
        var preLoadedMessages:[Message] = []
        let companyId = UserDefaults.standard.getCompanyId()
        if let node = node {
            let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node)
            query.observe(.childAdded, with: { snapshot in
                let messageId = snapshot.key
                if let data = snapshot.value as? [String: Any] {
                    if let imageUrl = data["img"] as? String,
                        let text = data["message"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        let date = data["date"] as? Double {
                        guard let url = URL(string: imageUrl) else {
                            print("Unable to construct URL from imageURL => \(imageUrl)")
                            return
                        }
                        print("Image Message with text => \(text)")
                        let message = Message(imageUrl: url, text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        preLoadedMessages.append(message)
                    } else if let imageUrl = data["img"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        let date = data["date"] as? Double {
                        guard let url = URL(string: imageUrl) else {
                            print("Unable to construct URL from imageURL => \(imageUrl)")
                            return
                        }
                        let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        preLoadedMessages.append(message)
                    } else if let text = data["message"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        let date = data["date"] as? Double {
                        let message = Message(text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        preLoadedMessages.append(message)
                    } else {
                        print("Unknown Scenario : ")
                        print(data)
                    }
                }
                DispatchQueue.main.async {
                    completion(preLoadedMessages)
                }
            }) { (error) in
                print("Error retrieving observer: \(error.localizedDescription)")
            }
        }
    }
    func loadChats(node:String?) {
        let companyId = UserDefaults.standard.getCompanyId()
        if let node = node {
            let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node).queryLimited(toLast: 5)
            query.observe(.childAdded, with: { [weak self] snapshot in
                let messageId = snapshot.key
                if let data = snapshot.value as? [String: Any] {
                    if let imageUrl = data["img"] as? String,
                        let text = data["message"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        let date = data["date"] as? Double {
                        guard let url = URL(string: imageUrl) else {
                            print("Unable to construct URL from imageURL => \(imageUrl)")
                            return
                        }
                        print("Image Message with text => \(text)")
                        let message = Message(imageUrl: url, text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        //                        let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        self?.insertMessage(message)
                    } else if let imageUrl = data["img"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        let date = data["date"] as? Double {
                        guard let url = URL(string: imageUrl) else {
                            print("Unable to construct URL from imageURL => \(imageUrl)")
                            return
                        }
                        let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        self?.insertMessage(message)
                    } else if let text = data["message"] as? String,
                        let senderId = data["sender"] as? Int,
                        let senderName = data["sender_name"] as? String,
                        //                    let senderNumber = data["sender_number"] as? String,
                        //                    let isSenderWorker = data["sender_is_worker"] as? Int,
                        //                    let type = data["type"] as? String,
                        let date = data["date"] as? Double {
                        let message = Message(text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                        self?.insertMessage(message)
                    } else {
                        print("Unknown Scenario")
                    }
                }
            })
        }
    }
    
    /*
    func loadChatsSample(node:String?) {
        let companyId = UserDefaults.standard.getCompanyId()
        if let node = node {
            var offsetKey:String? = nil
            if offsetKey == nil {
                let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node).queryLimited(toLast: 5)
                query.observe(.childAdded, with: { [weak self] snapshot in
                    let messageId = snapshot.key
                    if let data = snapshot.value as? [String: Any] {
                        if let imageUrl = data["img"] as? String,
                            let text = data["message"] as? String,
                            let senderId = data["sender"] as? Int,
                            let senderName = data["sender_name"] as? String,
                            let date = data["date"] as? Double {
                            guard let url = URL(string: imageUrl) else {
                                print("Unable to construct URL from imageURL => \(imageUrl)")
                                return
                            }
                            print("Image Message with text => \(text)")
                            let message = Message(imageUrl: url, text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            //                        let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            self?.insertMessage(message)
                        } else if let imageUrl = data["img"] as? String,
                            let senderId = data["sender"] as? Int,
                            let senderName = data["sender_name"] as? String,
                            let date = data["date"] as? Double {
                            guard let url = URL(string: imageUrl) else {
                                print("Unable to construct URL from imageURL => \(imageUrl)")
                                return
                            }
                            let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            self?.insertMessage(message)
                        } else if let text = data["message"] as? String,
                            let senderId = data["sender"] as? Int,
                            let senderName = data["sender_name"] as? String,
                            //                    let senderNumber = data["sender_number"] as? String,
                            //                    let isSenderWorker = data["sender_is_worker"] as? Int,
                            //                    let type = data["type"] as? String,
                            let date = data["date"] as? Double {
                            let message = Message(text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            self?.insertMessage(message)
                        } else {
                            print("Unknown Scenario")
                        }
                    }
                })
            } else {
                let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node).queryOrderedByKey().queryStarting(atValue: offsetKey).queryLimited(toLast: 6)
                query.observe(.childAdded, with: { [weak self] snapshot in
                    let messageId = snapshot.key
                    if let data = snapshot.value as? [String: Any] {
                        if let imageUrl = data["img"] as? String,
                            let text = data["message"] as? String,
                            let senderId = data["sender"] as? Int,
                            let senderName = data["sender_name"] as? String,
                            let date = data["date"] as? Double {
                            guard let url = URL(string: imageUrl) else {
                                print("Unable to construct URL from imageURL => \(imageUrl)")
                                return
                            }
                            print("Image Message with text => \(text)")
                            let message = Message(imageUrl: url, text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            //                        let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            self?.insertMessage(message)
                        } else if let imageUrl = data["img"] as? String,
                            let senderId = data["sender"] as? Int,
                            let senderName = data["sender_name"] as? String,
                            let date = data["date"] as? Double {
                            guard let url = URL(string: imageUrl) else {
                                print("Unable to construct URL from imageURL => \(imageUrl)")
                                return
                            }
                            let message = Message(imageUrl: url, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            self?.insertMessage(message)
                        } else if let text = data["message"] as? String,
                            let senderId = data["sender"] as? Int,
                            let senderName = data["sender_name"] as? String,
                            //                    let senderNumber = data["sender_number"] as? String,
                            //                    let isSenderWorker = data["sender_is_worker"] as? Int,
                            //                    let type = data["type"] as? String,
                            let date = data["date"] as? Double {
                            let message = Message(text: text, sender: Sender(id: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                            self?.insertMessage(message)
                        } else {
                            print("Unknown Scenario")
                        }
                    }
                })
            }
        }
    }
    */
    func loadMockMessages() {
        messages = []
        let mockUser = Sender(id: "99", displayName: "Arya Stark")
        let message = Message(text: "Valar Morghulis!", sender: currentSender(), messageId: UUID().uuidString, date: Date())
        self.insertMessage(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            let replyMessage = Message(text: "Valar Dohaeris!", sender: mockUser, messageId: UUID().uuidString, date: Date())
            self.insertMessage(replyMessage)

        }
    }
    
    
    
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
    // MARK: - Helpers
    /*
    func loadMoreMessages() {
        if !lastMessageKey {
            // Loading messages first time
            msgsReference.queryOrderedByKey().queryLimited(toLast: K_MESSAGES_PER_PAGE).observeSingleEventOfType(FIRDataEventTypeValue, withBlock: { snapshot in
                if snapshot.exists {
                    for child in snapshot.children {
                        var dict = child.value
                        dict["id"] = child.key
                        messages.append(dict)
                    }
                    lastMessageKey = Array(snapshot.children).first?.key()
                    print("\(messages)")
                }
            })
        } else {
            // Paging started
            ((msgsReference.queryOrderedByKey().queryLimited(toLast: K_MESSAGES_PER_PAGE + 1)).queryEnding(atValue: lastMessageKey)).observeSingleEventOfType(FIRDataEventTypeValue, withBlock: { snapshot in
                if snapshot.exists {
                    var count = 0
                    var newPage = []
                    for child in snapshot.children {
                        // Ignore last object because this is duplicate of last page
                        if count == snapshot.childrenCount - 1 {
                            break
                        }
                        count += 1
                        var dict = child.value
                        dict["id"] = child.key
                        newPage.append(dict)
                    }
                    lastMessageKey = Array(snapshot.children).first?.key()
                    // Insert new messages at top of old array
                    let indexes = NSIndexSet(indexesIn: NSRange(location: 0, length: newPage.count))
                    for (objectIndex, insertionIndex) in indexes.enumerated() { messages.insert((newPage)[objectIndex], at: insertionIndex) }
                    print("\(messages)")
                }
            })
        }
    }
    */
    
    func insertMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            self?.messagesCollectionView.scrollToBottom(animated: true)
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
        
    }
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    func showAlert(title:String, message:String) {
        let alertVC = UIAlertController.telaAlertController(title: title, message: message)
        alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == NSSelectorFromString("followUp:") {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if action == NSSelectorFromString("followUp:") {
            print("Follow Up Tapped")
            let message = messages[indexPath.section]
            print(message)
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
}




extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let asset = info[.phAsset] as? PHAsset { // 1
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
