//
//  Messages+Multimedia.swift
//  Telabook
//
//  Created by Anmol Rajpal on 17/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Photos
import CropViewController
import Firebase
import MessageKit
import CoreData

extension MessagesController {
    internal func promptPhotosPickerMenu() {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in self.handleSourceTypeCamera() })
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in self.handleSourceTypeGallery() })
        let conversationGalleryAction = UIAlertAction(title: "Conversation Gallery", style: .default, handler: { (action) in self.handleSourceTypeConversationGallery() })
        let agentsGalleryAction = UIAlertAction(title: "Agent's Gallery", style: .default, handler: { (action) in self.handleSourceTypeAgentGallery() })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(conversationGalleryAction)
        alert.addAction(agentsGalleryAction)
        alert.addAction(cancelAction)
        //        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        //        alert.view.tintColor = UIColor.telaBlue
        //        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        //        alert.view.subviews.first?.backgroundColor = .clear
        present(alert, animated: true, completion: nil)
    }
    private func handleSourceTypeCamera() {
        requestCamera()
    }
    private func handleSourceTypeGallery() {
        requestPhotoLibrary()
    }
    private func handleSourceTypeConversationGallery() {
        let vc = ConversationGalleryController(conversation: customer)
        vc.delegate = self
        let controller = UINavigationController(rootViewController: vc)
        present(controller, animated: true)
    }
    private func handleSourceTypeAgentGallery() {
        let vc = AgentGalleryController(agent: customer.agent!)
        vc.delegate = self
        let controller = UINavigationController(rootViewController: vc)
        present(controller, animated: true)
    }
    
    
    // MARK: - Request Camera
    
    fileprivate func requestCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
            case .authorized: presentCamera()
            case .notDetermined: requestCameraPermission()
            case .denied, .restricted: alertCameraAccessNeeded()
            @unknown default: fatalError()
        }
    }
    fileprivate func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
            self.presentCamera()
        })
    }
    fileprivate func presentCamera() {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            } else {
                picker.sourceType = .photoLibrary
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    fileprivate func alertCameraAccessNeeded() {
        let alert = UIAlertController.telaAlertController(title: "Need Camera Access", message: "Camera access is required to take photo")
        alert.addAction(UIAlertAction(title: "Allow", style: .cancel, handler: { _ in
            AppDelegate.shared.launchAppSettings()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Request Photo Library
    
    fileprivate func requestPhotoLibrary() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized, .limited: presentPhotoLibrary()
            case .notDetermined: requestPhotoLibraryPermission()
            case .denied, .restricted: alertPhotoLibraryAccessNeeded()
            @unknown default: fatalError()
        }
    }
    fileprivate func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            self.presentPhotoLibrary()
        }
    }
    fileprivate func presentPhotoLibrary() {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }
    }
    fileprivate func alertPhotoLibraryAccessNeeded() {
        let alert = UIAlertController.telaAlertController(title: "Need Library Access", message: "Photo Library access is required to read and write images")
        alert.addAction(UIAlertAction(title: "Allow", style: .cancel, handler: { _ in
            AppDelegate.shared.launchAppSettings()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    // MARK: - Upload Conversation Media Image
    
    func uploadImage(_ image: UIImage, textMessage:String) {
        guard let key = reference.childByAutoId().key else {
            printAndLog(message: "### \(#function) Failed to create child by auto id while uploading image", log: .firebase, logType: .error)
            return
        }
        guard let scaledImage = image.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 1) else {
            let errorMessage = "Profile Image Error: Unable to get scaled image or compressed image"
            printAndLog(message: errorMessage, log: .ui, logType: .error)
            fatalError(errorMessage)
        }
        
        let imageUUID = UUID()
        
        
        let imageFileName = imageUUID.uuidString + ".jpeg"
        
        let localImageURL = customer.mediaFolder().appendingPathComponent(imageFileName)
        
        
        
        DispatchQueue.global().async {
            var nsError: NSError?
            NSFileCoordinator().coordinate(writingItemAt: localImageURL, options: .forReplacing, error: &nsError,
                                           byAccessor: { (newURL: URL) -> Void in
                do {
                    try imageData.write(to: newURL, options: .atomic)
                } catch {
                    print("###\(#function): Failed to save an image file at destination url: \(localImageURL)")
                }
            })
            if let nsError = nsError {
                print("###\(#function): \(nsError.localizedDescription)")
                return
            }
        }
        
        
        
        let reference = Config.FirebaseConfig.StorageConfig.Node.conversationMedia(conversationNode: customer.node!, imageFileName: imageFileName).reference
        let path = reference.fullPath
        let slashEncodedPath = path.replacingOccurrences(of: "/", with: "%2F")
        let uploadURLString = FirebaseConfiguration.storageURLString + slashEncodedPath
        let uploadURL = URL(string: uploadURLString)!
        
        let message = NewMessage(kind: .photo(ImageItem(image: scaledImage, imageUUID: imageUUID, uploadURL: uploadURL, imageText: textMessage)), messageId: key, sender: thisSender, sentDate: Date())
        print(message)
        viewContext.performAndWait {
            let newMessage = UserMessage(context: viewContext, newMessageEntryFromCurrentUser: message, forConversationWithCustomer: customer)
            newMessage.uploadState = .pending
            newMessage.isUploading = true
            do {
                if viewContext.hasChanges { try viewContext.save() }
            } catch {
                printAndLog(message: "### \(#function) - Core Data Error saving new media message entry in store: \(message) | Error: \(error)", log: .coredata, logType: .error)
                return
            }
            DispatchQueue.main.async {
                self.upsertMessage(message: newMessage)
            }
            uploadService.startUpload(newMessage)
        }
    }
    
}

/*
extension MessagesController:MMSCellDelegate {
    func didTapDownloadButton(in cell: MMSCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
                print("Failed to identify MMS message download button when MMS message cell download button receive tap gesture")
                return
        }
        downloadService.startDownload(message)
        UIView.performWithoutAnimation {
            self.messagesCollectionView.reloadSections([indexPath.section])
        }
    }
    func startDownloadingMedia(forMultimediaMessage message: UserMessage, at indexPath: IndexPath) {
        downloadService.startDownload(message)
    }
    func startUploadingMedia(forMultimediaMessage message: UserMessage, at indexPath: IndexPath) {
        uploadService.startUpload(message)
    }
}
*/

extension MessagesController: MultimediaMessageCellDelegate {
    func handleMediaState(_ cell: MultimediaMessageCell, message: UserMessage, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let imageURL = message.imageURL else { return }
        let upload = uploadService.activeUploads[imageURL]
        let download = downloadService.activeDownloads[imageURL]
        cell.handleMediaState(for: message, at: indexPath, in: messagesCollectionView, upload: upload, download: download, shouldAutoDownload: shouldAutoDownloadImageMessages)
    }
    
    func didTapDownloadButton(in cell: MultimediaMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
                print("Failed to identify MMS message download button when MMS message cell download button receive tap gesture")
                return
        }
        downloadService.startDownload(message)
        UIView.performWithoutAnimation {
            self.messagesCollectionView.reloadSections([indexPath.section])
        }
    }
    func startDownloadingMedia(forMultimediaMessage message: UserMessage, at indexPath: IndexPath) {
        downloadService.startDownload(message)
    }
    func startUploadingMedia(forMultimediaMessage message: UserMessage, at indexPath: IndexPath) {
        uploadService.startUpload(message)
    }
    
}




// MARK: - Photo Library / Camera Image picker delegate

extension MessagesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let vc = CropViewController(image: image)
        vc.delegate = self
        picker.pushViewController(vc, animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



// MARK: - Agent Gallery image picker delegate

extension MessagesController: AgentGalleryImagePickerDelegate {
    func agentGalleryController(controller: AgentGalleryController, didPickImage image: UIImage, forGalleryItem item: AgentGalleryItem, at indexPath: IndexPath) {
        let vc = CropViewController(image: image)
        vc.delegate = self
        controller.show(vc, sender: controller)
    }
    func agentGalleryController(controller: AgentGalleryController, didFinishCancelled cancelled: Bool) {
        controller.dismiss(animated: true)
    }
}



// MARK: - Conversation Gallery image picker delegate

extension MessagesController: ConversationGalleryImagePickerDelegate {
    func conversationGalleryController(controller: ConversationGalleryController, didPickImage image: UIImage, forMessage message: UserMessage, at indexPath: IndexPath) {
        let vc = CropViewController(image: image)
        vc.delegate = self
        controller.show(vc, sender: controller)
    }
    func conversationGalleryController(controller: ConversationGalleryController, didFinishCancelled cancelled: Bool) {
        controller.dismiss(animated: true)
    }
}



// MARK: - Crop View Controller delegate

extension MessagesController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        let vc = MediaAssertionController(image: image)
        vc.delegate = self
        cropViewController.show(vc, sender: cropViewController)
    }
}



// MARK: - Media Assertion delegate: Add text message to image

extension MessagesController: MediaAssertionDelegate {
    func mediaAssertionController(controller: UIViewController, didPickImage image: UIImage, textMessage: String) {
        controller.dismiss(animated: true) {
            self.uploadImage(image, textMessage: textMessage)
        }
    }
    func mediaAssertionController(controller: UIViewController, didFinishCancelled cancelled: Bool) {
        controller.dismiss(animated: true)
    }
}



















