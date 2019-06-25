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
import FirebaseStorage
final class ChatViewController : MessagesViewController {
    var messages:[Message] = []
    private let conversationId:String
    private let node:String
    init(conversationId: String, node: String) {
        self.conversationId = String(conversationId)
        print("External Conversation ID => \(conversationId)")
        self.node = node
        super.init(nibName: nil, bundle: nil)
        self.loadChats(node: node)
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
    
    func loadChats(node:String?) {
        messages = []
        let companyId = UserDefaults.standard.getCompanyId()
        if let node = node {
            let query = Config.DatabaseConfig.getChats(companyId: String(companyId), node: node)
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
    
    func configureMessageCollectionView() {
        messagesCollectionView.backgroundColor = .telaGray1
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.messageCellDelegate = self
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 0)))
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
//        messageInputBar.inputTextView.tintColor = .telaWhite
        messageInputBar.inputTextView.textColor = .telaWhite
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "autoresponse_icon"), for: .normal)
        
        messageInputBar.sendButton.title = nil
//        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = UIColor.telaGray1
        messageInputBar.contentView.backgroundColor = UIColor.telaGray1
        messageInputBar.inputTextView.backgroundColor = UIColor.telaGray5
        messageInputBar.inputTextView.keyboardAppearance = UIKeyboardAppearance.dark
        messageInputBar.inputTextView.layer.borderWidth = 0
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 36)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        let cameraItem = InputBarButtonItem(type: .custom) // 1
//        cameraItem.tintColor = .blue
        cameraItem.image = #imageLiteral(resourceName: "camera_icon")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed), // 2
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false) // 3
//        messageInputBar.sendButton.setTitleColor(.telaGreen, for: .normal)
//        messageInputBar.sendButton.setTitleColor(
//            UIColor.telaGreen.withAlphaComponent(0.3),
//            for: .highlighted
//        )
    }
    @objc private func cameraButtonPressed() {
        promptPhotosPickerMenu()
    }
    private func handleSourceTypeCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.modalPresentationStyle = .overFullScreen
        present(picker, animated: true, completion: nil)
    }
    private func handleSourceTypeGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .overFullScreen
        present(picker, animated: true, completion: nil)
    }
    internal func promptPhotosPickerMenu() {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleSourceTypeCamera()
        })
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleSourceTypeGallery()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        
        alert.view.tintColor = UIColor.telaBlue
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alert.view.subviews.first?.backgroundColor = .clear
        self.present(alert, animated: true, completion: nil)
    }
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    //                    item.isEnabled = !self.isSendingPhoto
                    
                }
            }
        }
    }
    fileprivate var storageUploadTask:StorageUploadTask!
    private func uploadImage(_ image: UIImage, callback: @escaping (URL?) -> Void) {
        
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            callback(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        
        let imageName = [UUID().uuidString, String(Int(Date().timeIntervalSince1970)*1000)].joined(separator: "-") + ".jpg"
        let ref = Config.StorageConfig.messageImageRef.child(imageName)
        
        
        storageUploadTask = ref.putData(data, metadata: metadata, completion: { (meta, error) in
            guard error == nil else {
                print("Error uploading: \(error!)")
                callback(nil)
                return
            }
            ref.downloadURL(completion: { (url, err) in
                guard let downloadUrl = url else {
                    if let err = err {
                        print("Error: Unable to get download url => \(err.localizedDescription)")
                    }
                    callback(nil)
                    return
                }
                callback(downloadUrl)
            })
        })
        
    }
    
    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        
        uploadImage(image) { [weak self] url in
            guard let `self` = self else {
                return
            }
            self.isSendingPhoto = false
            
            guard let url = url else {
                return
            }
            self.handleSendingMessageSequence(message: url.absoluteString, type: .MMS)
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
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
}

extension ChatViewController : MessagesDataSource {
    func currentSender() -> Sender {
        return UserDefaults.standard.currentSender
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
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        avatarView.image = nil
//        avatarView.frame = .zero
//        avatarView.setCorner(radius: .zero)
//    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
//    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return CGSize.zero
//    }

    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let msg = message as? Message,
            let url = msg.imageURL else {
                print("Optional Message Item")
                return
        }
        if let text = msg.imageTEXT,
            !text.isEmpty {
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
        
        imageView.loadImageUsingCacheWithURLString(url.absoluteString, placeHolder: #imageLiteral(resourceName: "landing_callgroup"))
    }
}

// MARK: - MessagesLayoutDelegate

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

//extension ChatViewController : MessageCellDelegate {
//
//}
//extension ChatViewController : MessageLabelDelegate {
//
//}
extension ChatViewController : MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
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
    fileprivate func handleSendingMessageSequence(message:String, type:ChatMessageType) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let token = token {
                let id = self.conversationId
                print("External Conversation ID => \(id)")
                guard id != "0" else {
                    print("Error: External Convo ID => 0")
                    self.messageInputBar.sendButton.isEnabled = true
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
                    UIAlertController.dismissModalSpinner(controller: self)
                    print("***Error Sending Message****\n\(err.localizedDescription)")
                    self.showAlert(title: "Error", message: err.localizedDescription)
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    UIAlertController.dismissModalSpinner(controller: self)
                    print("***Error Sending Message****\n\(serviceErr.localizedDescription)")
                    self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                    self.messageInputBar.sendButton.isEnabled = true
                }
            } else if let status = responseStatus {
                guard status == .Created else {
                    DispatchQueue.main.async {
                        UIAlertController.dismissModalSpinner(controller: self)
                        print("***Error Sending Message****\nInvalid Response: \(status)")
                        self.showAlert(title: "\(status)", message: "Unable to send Message. Please try again")
                        self.messageInputBar.sendButton.isEnabled = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    print("Message sent: \(message)")
//                    self.messageInputBar.inputTextView.text = ""
//                    self.messagesCollectionView.scrollToBottom(animated: true)
//                    self.messageInputBar.sendButton.isEnabled = true
                }
                if let data = data {
                    print("Data length => \(data.count)")
                    print("Data => \(data)")
                }
            }
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
