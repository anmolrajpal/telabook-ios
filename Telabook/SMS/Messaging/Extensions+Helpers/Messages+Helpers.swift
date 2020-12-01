//
//  Messages+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Photos
import FirebaseStorage
import MessageKit
import MenuController


extension MessagesController: NormalDialerDelegate {
    func normalDialer(didEnteredNumberToDial number: String, controller: NormalDialerViewController) {
        controller.dismiss(animated: true) {
            guard let workerPhoneNumber = self.customer.agent?.didNumber,
                !workerPhoneNumber.isBlank else {
                    fatalError()
            }
            self.initiateClick2CallOperation(for: self.conversationID, fromPhoneNumber: number, toPhoneNumber: workerPhoneNumber, isAgent: 3)
        }
    }
}

extension MessagesController {
    internal func commonInit() {
        title = customer.addressBookName?.isEmpty ?? true ? customer.phoneNumber?.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? customer.phoneNumber : customer.addressBookName
        configureNavigationBarAppearance()
//        configureNavigationBarItems()
        configureHierarchy()
        configureMessageCollectionView()
        configureMessageInputBar()
        loadInitialMessages(fetchFromFirebase: true, shouldLoadUnseenMessages: true)
        setupTargetActions()
        reloadQuickResponses()
//        clearUnreadMessagesCount()
    }
    
    func configureNavigationBarItems() {
        self.navigationItem.rightBarButtonItems = [self.phoneBarButtonItem]
        updateNavigationBarItems()
    }
    @objc
    func phoneButtonDidTapped(_ button: UIBarButtonItem) {
        promptClick2CallMenu()
    }
    
    
    func updateNavigationBarItems() {
        if isClick2CallOperationActive {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItems = [self.phoneSpinnerBarButtonItem]
            }
            startPhoneSpinner()
        } else {
            stopPhoneSpinner()
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItems = [self.phoneBarButtonItem]
            }
            if let workerPhoneNumber = customer.agent?.didNumber,
               let currentUserPhoneNumber = AppData.userInfo?.phone,
                !workerPhoneNumber.isBlank,
                !currentUserPhoneNumber.isBlank {
                self.phoneBarButtonItem.isEnabled = true
            } else {
                self.phoneBarButtonItem.isEnabled = false
            }
        }
    }
    
    private func startPhoneSpinner() {
        DispatchQueue.main.async {
            self.phoneSpinner.startAnimating()
        }
    }
    private func stopPhoneSpinner() {
        DispatchQueue.main.async {
            self.phoneSpinner.stopAnimating()
        }
    }
    
    private func promptClick2CallMenu() {
        var menuItems = [UIControlMenuAction]()
        
        guard let workerPhoneNumber = customer.agent?.didNumber,
              let currentUserPhoneNumber = AppData.userInfo?.phone,
            !workerPhoneNumber.isBlank,
            !currentUserPhoneNumber.isBlank else {
                printAndLog(message: "Invalid parameters", log: .ui, logType: .error)
                fatalError()
        }
        
        let formattedCurrentUserPhoneNumber = currentUserPhoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? currentUserPhoneNumber
        let formattedWorkerPhoneNumber = workerPhoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? workerPhoneNumber
        
        
        // MARK: - Call Me Action
        
        let callMeAction = UIControlMenuAction(title: "Call Me \(formattedCurrentUserPhoneNumber)", image: SFSymbol.phone·fill.image) { _ in
            self.initiateClick2CallOperation(for: self.conversationID, fromPhoneNumber: currentUserPhoneNumber, toPhoneNumber: workerPhoneNumber, isAgent: 2)
        }
        menuItems.append(callMeAction)
        
        
        // MARK: - Call Agent Action
        
        let callAgentAction = UIControlMenuAction(title: "Call Agent \(formattedWorkerPhoneNumber)", image: SFSymbol.phone·fill.image) { _ in
            self.initiateClick2CallOperation(for: self.conversationID, fromPhoneNumber: currentUserPhoneNumber, toPhoneNumber: workerPhoneNumber, isAgent: 1)
        }
        menuItems.append(callAgentAction)
        
        
        // MARK: - Dial Phone Number Action
        
        let dialAction = UIControlMenuAction(title: "Dial Phone Number", image: #imageLiteral(resourceName: "keypad")) { _ in
            self.showDialer()
        }
        menuItems.append(dialAction)
        
        let label = UILabel()
        label.text = "Who do you want to call?"
        label.textColor = .telaBlue
        label.font = UIFont.gothamBook(forTextStyle: .callout)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView()
        headerView.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 8).isActive = true
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        let vc = MenuController(headerView: headerView, actions: menuItems)
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
    private func showDialer() {
        let vc = NormalDialerViewController()
        vc.delegate = self
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
    private func configureHierarchy() {
        messagesCollectionView.addSubview(spinner)
        messagesCollectionView.addSubview(placeholderLabel)
        downIndicatorContainerView.addSubview(scrollToBottomButton)
        downIndicatorContainerView.addSubview(newMessagesCountLabel)
        view.addSubview(downIndicatorContainerView)
        layoutConstraints()
    }
    private func layoutConstraints() {
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
        
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: spinner.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 24, bottomConstant: 30, rightConstant: 24)
        
        scrollToBottomButton.anchor(top: downIndicatorContainerView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 6, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        scrollToBottomButton.centerXAnchor.constraint(equalTo: downIndicatorContainerView.centerXAnchor).activate()
        
        
        
        
        newMessagesCountLabel.anchor(top: scrollToBottomButton.bottomAnchor, left: nil, bottom: downIndicatorContainerView.bottomAnchor, right: nil, topConstant: 5, leftConstant: 5, bottomConstant: 5, rightConstant: 5)
        newMessagesCountLabel.centerXAnchor.constraint(equalTo: scrollToBottomButton.centerXAnchor).activate()
        newMessagesCountLabelHeightConstraint = newMessagesCountLabel.heightAnchor.constraint(equalToConstant: 0)
        newMessagesCountLabelHeightConstraint.activate()
        
        downIndicatorContainerView.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 50, rightConstant: 0, widthConstant: 60, heightConstant: 0)
        downIndicatorBottomConstraint = downIndicatorContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(messagesCollectionView.adjustedContentInset.bottom + 60))
        downIndicatorBottomConstraint.activate()
        //        downIndicatorContainerView.anchor(top: nil, left: nil, bottom: messageInputBar.topAnchor, right: messageInputBar.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 50, rightConstant: 0, widthConstant: 60, heightConstant: 0)
        
        //        downIndicatorContainerView.anchor(top: nil, left: nil, bottom: messagesCollectionView.bottomAnchor, right: messagesCollectionView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 100, rightConstant: 0, widthConstant: 60, heightConstant: 0)
    }
    private func setupTargetActions() {
        scrollToBottomButton.addTarget(self, action: #selector(downButtonDidTap(_:)), for: .touchUpInside)
    }
    @objc
    private func downButtonDidTap(_ button:UIButton) {
        print("down button tapped")
        messagesCollectionView.scrollToBottom(animated: true)
    }
    internal func startSpinner() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    internal func stopSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    
    
    
    // MARK: - Message Helpers
    
    func changeDownIndicatorState(show:Bool, animated:Bool = true) {
        if show {
            UIView.animate(withDuration: 0.2) {
                self.downIndicatorContainerView.alpha = 1
            }
            self.scrollToBottomButton.isEnabled = true
        } else {
            UIView.animate(withDuration: 0.2) {
                self.downIndicatorContainerView.alpha = 0
            }
            self.scrollToBottomButton.isEnabled = false
        }
    }
    
    func isLastSectionVisible() -> Bool {
        let count = messages.count
        guard count != 0 else { return false }
        let lastIndexPath = IndexPath(item: 0, section: count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section - 1].messageSender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].messageSender == messages[indexPath.section + 1].messageSender
    }
    
    func isNextMessageDateInSameDay(at indexPath:IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section + 1 < messages.count else { return false }
        guard let currentMessageDate = messages[indexPath.section].date, let nextMessageDate = messages[indexPath.section + 1].date else { return false }
        return Calendar.current.isDate(currentMessageDate, inSameDayAs: nextMessageDate)
    }
    func isPreviousMessageDateInSameDay(at indexPath:IndexPath) -> Bool {
        guard !messages.isEmpty else { return false }
        guard indexPath.section - 1 >= 0 else { return false }
        guard let currentMessageDate = messages[indexPath.section].date, let previousMessageDate = messages[indexPath.section - 1].date else { return false }
        return Calendar.current.isDate(currentMessageDate, inSameDayAs: previousMessageDate)
    }
    func shouldShowNewMessagesCountFooter(at section:Int) -> Bool {
        //        print("Last message: \(messages[section]) : section: \(section) & refresh time: \(String(describing: messages[section].lastRefreshedAt))")
        guard !messages.isEmpty else { return false }
        guard section + 1 < messages.count else { return false }
        guard !isFromCurrentSender(message: messages[section + 1]) else { return false }
        
        guard let match = messages.firstIndex(where: {
            guard let currentMessageDate = $0.date else { return false }
            return currentMessageDate > self.screenEntryTime
        }) else { return false }
        return section == match - 1
    }
    
    func reloadDataKeepingOffset() {
        let offset = self.messagesCollectionView.contentOffset.y + messagesCollectionView.adjustedContentInset.bottom + messagesCollectionView.verticalScrollIndicatorInsets.bottom
        let oldY = self.messagesCollectionView.contentSize.height - offset
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.layoutIfNeeded()
        let y = self.messagesCollectionView.contentSize.height - oldY
        let newOffset = CGPoint(x: 0, y: y)
        self.messagesCollectionView.contentOffset = newOffset
    }
    func insertMessages(messages:[UserMessage]) {
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            //            self?.messagesCollectionView.scrollToBottom(animated: true)
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func updateCell(with message:UserMessage) {
        messagesCollectionView.performBatchUpdates({ [weak self] in
            guard let self = self else { return }
            if let index = self.messages.firstIndex(of: message) {
                let indexPath = IndexPath(item: 0, section: index)
                if let cell = self.messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell {
                    cell.configure(with: message, at: indexPath, and: self.messagesCollectionView)
                }
                /*
                switch message.kind {
                    case .photo:
                        if let cell = self.messagesCollectionView.cellForItem(at: indexPath) as? MMSCell {
                            cell.configure(with: message, at: indexPath, and: self.messagesCollectionView, upload: self.uploadService.activeUploads[message.imageURL!], download: self.downloadService.activeDownloads[message.imageURL!], shouldAutoDownload: self.shouldAutoDownloadImageMessages)
                        }
                    default:
                        if let cell = self.messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell {
                            cell.configure(with: message, at: indexPath, and: self.messagesCollectionView)
                        }
                }
                */
            }
        }) { [weak self] _ in
            guard let self = self else { return }
            if let index = self.messages.firstIndex(of: message) {
                UIView.performWithoutAnimation {
                    self.messagesCollectionView.reloadSections([index])
                }
            }
        }
    }
    
    
    func upsertMessage(message: UserMessage) {
        if let index = self.messages.firstIndex(where: { $0.firebaseKey == message.firebaseKey }) {
            self.messages[index] = message
            self.updateCell(with: message)
        } else if message.sentDate >= self.screenEntryTime {
            self.messages.append(message)
            self.messagesCollectionView.performBatchUpdates({
                self.messagesCollectionView.insertSections([self.messages.count - 1])
                if self.messages.count >= 2 {
                    self.messagesCollectionView.reloadSections([self.messages.count - 2])
                }
            }) { _ in
                if self.isLastSectionVisible() {
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    @objc internal func cameraButtonDidTap() {
        messageInputBar.inputTextView.resignFirstResponder()
        promptPhotosPickerMenu()
    }
    
    
    
    
    
    
    /*
     private func uploadImage(_ image: UIImage, completion: @escaping(URL?, Error?) -> Void) {
     var uploadTask:StorageUploadTask
     guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
     let message = "Unable to get scaled compressed image"
     print(message)
     completion(nil, ApplicationError.Internal(status: 900, message: message))
     return
     }
     let metadata = StorageMetadata()
     metadata.contentType = "image/jpeg"
     
     
     
     let imageName = [UUID().uuidString, String(Int(Date().timeIntervalSince1970)*1000)].joined(separator: "-") + ".jpg"
     let ref = Config.StorageConfig.messageImageRef.child(imageName)
     
     uploadTask = ref.putData(data, metadata: metadata)
     
     uploadTask.observe(.resume) { snapshot in
     print("Upload resumed, also fires when the upload starts")
     }
     
     uploadTask.observe(.pause) { snapshot in
     print("Upload paused")
     }
     let alertVC = UIAlertController.telaAlertController(title: "Uploading...")
     let margin:CGFloat = 8.0
     let alertVCWidth:CGFloat = 270.0
     print("Alert VC width => \(alertVCWidth)")
     let frame = CGRect(x: margin, y: 72.0, width: alertVCWidth - margin * 2.0 , height: 2.0)
     let progressBar = UIProgressView(progressViewStyle: .default)
     progressBar.frame = frame
     progressBar.progressTintColor = UIColor.telaBlue
     let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
     uploadTask.cancel()
     
     }
     alertVC.addAction(cancelAction)
     alertVC.view.addSubview(progressBar)
     DispatchQueue.main.async {
     UIAlertController.presentAlert(alertVC)
     }
     progressBar.setProgress(0.0, animated: true)
     
     uploadTask.observe(.progress) { snapshot in
     let completedUnitCount = snapshot.progress!.completedUnitCount
     let totalUnitCount = snapshot.progress!.totalUnitCount
     let progress = Float(completedUnitCount) / Float(totalUnitCount)
     progressBar.setProgress(progress, animated: true)
     }
     
     uploadTask.observe(.success) { snapshot in
     print("Upload completed successfully")
     alertVC.dismiss(animated: true, completion: nil)
     ref.downloadURL(completion: { (url, err) in
     guard let downloadUrl = url else {
     if let err = err {
     print("Error: Unable to get download url => \(err.localizedDescription)")
     completion(nil, err)
     }
     return
     }
     completion(downloadUrl, nil)
     })
     }
     
     uploadTask.observe(.failure) { snapshot in
     if let error = snapshot.error as NSError? {
     switch (StorageErrorCode(rawValue: error.code)!) {
     case .objectNotFound:
     print("File doesn't exist")
     break
     case .unauthorized:
     print("User doesn't have permission to access file")
     break
     case .cancelled:
     print("User canceled the upload")
     alertVC.dismiss(animated: true, completion: nil)
     break
     case .unknown:
     print("Unknown error occurred, inspect the server response")
     break
     default:
     print("A separate error occurred. This is a good place to retry the upload.")
     break
     }
     completion(nil, error)
     }
     }
     }
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
     */
    /*
     internal func sendPhoto(_ image: UIImage) {
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
     */
}


/*
 extension MessagesController: ImageAssertionDelegate {
 func sendMediaMessage(image: UIImage, withReply message: String) {
 self.uploadImage(image) { (url, error) in
 if let error = error {
 print(error.localizedDescription)
 DispatchQueue.main.async {
 UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription)
 }
 } else if let url = url {
 DispatchQueue.main.async {
 UIAlertController.showModalSpinner(with: "Sending...", controller: self)
 }
 print(url)
 //                self.handleSendingMessageSequence(message: url.absoluteString, type: .MMS)
 }
 }
 }
 }
 */

/*
 
 extension MessagesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 //        picker.dismiss(animated: true, completion: nil)
 
 if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
 let vc = ImageAssertionViewController(image)
 vc.delegate = self
 picker.show(vc, sender: self)
 //            vc.modalPresentationStyle = .overFullScreen
 //            vc.modalTransitionStyle = .crossDissolve
 //            picker.dismiss(animated: false) {
 //                self.navigationController?.present(vc, animated: true, completion: nil)
 //            }
 }
 else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
 let vc = ImageAssertionViewController(image)
 vc.delegate = self
 picker.show(vc, sender: self)
 //            vc.modalPresentationStyle = .overFullScreen
 //            vc.modalTransitionStyle = .crossDissolve
 //            picker.dismiss(animated: false) {
 //                self.navigationController?.present(vc, animated: true, completion: nil)
 //            }
 
 } else {
 print("Unknown stuff")
 }
 }
 
 func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
 picker.dismiss(animated: true, completion: nil)
 }
 
 }
 */


/*
 extension MessagesController {
 // MARK: - Inset Computation
 
 
 
 private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
 // we only need to adjust for the part of the keyboard that covers (i.e. intersects) our collection view;
 // see https://developer.apple.com/videos/play/wwdc2017/242/ for more details
 let intersection = messagesCollectionView.frame.intersection(keyboardFrame)
 
 if intersection.isNull || intersection.maxY < messagesCollectionView.frame.maxY {
 // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
 // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
 return max(0, additionalBottomInset - automaticallyAddedBottomInset)
 } else {
 return max(0, intersection.height + additionalBottomInset - automaticallyAddedBottomInset)
 }
 }
 
 internal func requiredInitialScrollViewBottomInset() -> CGFloat {
 guard let inputAccessoryView = inputAccessoryView else { return 0 }
 return max(0, inputAccessoryView.frame.height + additionalBottomInset - automaticallyAddedBottomInset)
 }
 
 /// iOS 11's UIScrollView can automatically add safe area insets to its contentInset,
 /// which needs to be accounted for when setting the contentInset based on screen coordinates.
 ///
 /// - Returns: The distance automatically added to contentInset.bottom, if any.
 private var automaticallyAddedBottomInset: CGFloat {
 return messagesCollectionView.adjustedContentInset.bottom - messagesCollectionView.contentInset.bottom
 }
 }
 */
