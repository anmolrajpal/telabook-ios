//
//  MessagesController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

class MessagesController: UIViewController {
    
    
    
    
    
    
    var handle:UInt!
    let customer:Customer
    let node:Config.FirebaseConfig.Node
    let reference:DatabaseReference
    init(customer:Customer) {
        self.customer = customer
        self.node = .messages(companyID: AppData.companyId, node: customer.node!)
        self.reference = node.reference
        super.init(nibName: nil, bundle: nil)
//        self.preLoadMessages(node: node)
//        self.preLoadChats(node: customer.node) { messages in
//
//        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    //MARK: Lifecycle
    override func loadView() {
        super.loadView()
//        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .telaGray1
        setUpNavBar()
//        setup()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reference.removeObserver(withHandle: handle)
        stopObservingReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = customer.addressBookName?.isEmpty ?? true ? customer.phoneNumber : customer.addressBookName
        observeReachability()
        loadMessages()
    }
    
    
    func loadMessages() {
        handle = reference.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                print("Snapshot Does not exists: returning")
                return
            }
//            var messages:[Message] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    print(snapshot)
//                    guard let message = FirebaseCustomer(snapshot: snapshot, workerID: workerIDstring) else {
//                        print("Unresolved Error: Unable to create conversation from Firebase Customer")
//                        return
//                    }
                    //                    print(conversation)
//                    conversations.append(conversation)
                }
            }
//            self.firebaseCustomers = conversations
//            self.persistFirebaseEntriesToCoreDataStore(entries: conversations)
            //            print(snapshot.value as Any)
        }) { error in
            print("Value Observer Event Error: \(error)")
        }
    }
    
    
    func preLoadChats(node:String?, completion: @escaping ([Message]) -> Void) {
           var preLoadedMessages:[Message] = []
           let companyId = AppData.companyId
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
                           let message = Message(imageUrl: url, text: text, sender: Sender(senderId: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                           preLoadedMessages.append(message)
                       } else if let imageUrl = data["img"] as? String,
                           let senderId = data["sender"] as? Int,
                           let senderName = data["sender_name"] as? String,
                           let date = data["date"] as? Double {
                           guard let url = URL(string: imageUrl) else {
                               print("Unable to construct URL from imageURL => \(imageUrl)")
                               return
                           }
                           let message = Message(imageUrl: url, sender: Sender(senderId: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
                           preLoadedMessages.append(message)
                       } else if let text = data["message"] as? String,
                           let senderId = data["sender"] as? Int,
                           let senderName = data["sender_name"] as? String,
                           let date = data["date"] as? Double {
                           let message = Message(text: text, sender: Sender(senderId: String(senderId), displayName: senderName), messageId: messageId, date: Date(timeIntervalSince1970: TimeInterval(date) / 1000))
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
}
