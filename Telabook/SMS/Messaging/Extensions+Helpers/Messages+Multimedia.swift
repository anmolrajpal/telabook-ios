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
        
    }
    private func handleSourceTypeAgentGallery() {
        
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
            case .authorized: presentPhotoLibrary()
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
    
    private func uploadImage(_ image: UIImage) {
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
        
//        DispatchQueue.global().async {
//            var nsError: NSError?
//            NSFileCoordinator().coordinate(writingItemAt: localImageURL, options: .forReplacing, error: &nsError,
//                                           byAccessor: { (newURL: URL) -> Void in
//                do {
//                    try imageData.write(to: newURL, options: .atomic)
//                } catch {
//                    print("###\(#function): Failed to save an image file at destination url: \(localImageURL)")
//                }
//            })
//            if let nsError = nsError {
//                print("###\(#function): \(nsError.localizedDescription)")
//                return
//            }
//        }
        
        
        let message = NewMessage(kind: .photo(ImageItem(image: scaledImage, imageUUID: imageUUID, imageText: nil)), messageId: key, sender: thisSender, sentDate: Date())
        
        print(message)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let reference = Config.FirebaseConfig.StorageConfig.Node.conversationMedia(conversationNode: customer.node!, imageFileName: imageFileName).reference
        let path = reference.fullPath
        
        let uploadURLString = FirebaseConfiguration.storageURLString + path
        let uploadURL = URL(string: uploadURLString)!
        print("Upload URL String : \(uploadURLString)\nUploarURL: \(uploadURL)")
        
    
    }
}
let fire =
"""
{
  "name": "profile-image/1559770807069",
  "bucket": "telebookchat.appspot.com",
  "generation": "1559770807831939",
  "metageneration": "1",
  "contentType": "image/jpeg",
  "timeCreated": "2019-06-05T21:40:07.831Z",
  "updated": "2019-06-05T21:40:07.831Z",
  "storageClass": "STANDARD",
  "size": "36025",
  "md5Hash": "pdsfl+31kkewDMtSqvxizw==",
  "contentEncoding": "identity",
  "contentDisposition": "inline; filename*=utf-8''1559770807069",
  "crc32c": "zVtY1w==",
  "etag": "CIObuoen0+ICEAE=",
  "downloadTokens": "624e742a-4e08-471e-9e12-807523658cdf"
}
"""



extension MessagesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let vc = CropViewController(image: image)
        vc.delegate = self
        picker.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) {
            
        }
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.uploadImage(image)
        }
    }
    
}



extension MessagesController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
          if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let completionHandler = appDelegate.backgroundSessionCompletionHandler {
            appDelegate.backgroundSessionCompletionHandler = nil
            completionHandler()
          }
        }
    }
}


extension MessagesController: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("### \(#function) Error: \(String(describing: error))")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadURL = task.originalRequest?.url else {
            return
        }
        guard let upload = uploadService.activeUploads[uploadURL] else { return }
        
        upload.progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        let uploadedSize = ByteCountFormatter.string(fromByteCount: totalBytesSent, countStyle: .file)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToSend, countStyle: .file)
        
        DispatchQueue.main.async {
            if let index = self.messages.firstIndex(of: upload.message),
                let cell = self.messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: Int(index))) as? MMSCell {
                cell.updateProgress(progress: upload.progress, loadedSize: uploadedSize, totalSize: totalSize)
            }
        }
    }
}



extension MessagesController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("### \(#function) Did receive response: \(response)")
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("### \(#function) Did Receive Data: \(data)")
    }
}



extension MessagesController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else {
//            printAndLog(message: "### \(#function) No Source download url", log: .network, logType: .error)
            return
        }
//        print("### \(#function) - Download Original Request URL: \(sourceURL)")
        guard let download = downloadService.activeDownloads[sourceURL] else {
//            printAndLog(message: "### \(#function) - No Active download at URL: \(sourceURL)", log: .network, logType: .error)
            return
        }
        downloadService.activeDownloads[sourceURL] = nil
        
        // 2
        var destinationURL:URL?
        viewContext.performAndWait {
            do {
                download.message.imageUUID = UUID()
                try viewContext.save()
                destinationURL = download.message.imageLocalURL()
            } catch {
                print("### \(#function): Core Data Error updating imageUUID: \(error)")
            }
        }
        
        // 3
        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(at: location, to: destinationURL!)
        } catch {
            print("### \(#function): Failed to move image file from tmp url: \(location) to image local url: \(destinationURL!); \nError Description: \(error)")
        }
        
        // 4
        if let index = messages.firstIndex(of: download.message) {
          DispatchQueue.main.async { [weak self] in
            self?.messagesCollectionView.reloadSections([Int(index)])
          }
        }
    }
    
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let downloadURL = downloadTask.originalRequest?.url else {
//            printAndLog(message: "### \(#function) Failed to retrieve original request download url", log: .network, logType: .error)
            return
        }
//        print("### \(#function) download url: \(downloadURL)")
        guard let download = downloadService.activeDownloads[downloadURL] else {
//            printAndLog(message: "### \(#function) - No active download for download url: \(downloadURL)", log: .network, logType: .error)
            return
        }
        
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let downloadedSize = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .file)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        DispatchQueue.main.async {
            if let index = self.messages.firstIndex(of: download.message),
                let cell = self.messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: Int(index))) as? MMSCell {
                cell.updateProgress(progress: download.progress, loadedSize: downloadedSize, totalSize: totalSize)
            }
        }
    }
}




class Upload {
    //
    // MARK: - Variables And Properties
    //
    var isUploading = false
    var progress: Float = 0
    var task: URLSessionUploadTask?
    var message: UserMessage
    
    //
    // MARK: - Initialization
    //
    init(message: UserMessage) {
      self.message = message
    }
}
class Download {
    //
    // MARK: - Variables And Properties
    //
    var isDownloading = false
    var resumeData:Data?
    var progress: Float = 0
    var task: URLSessionDownloadTask?
    var message: UserMessage
    
    //
    // MARK: - Initialization
    //
    init(message: UserMessage) {
      self.message = message
    }
}



//
// MARK: - Upload Service
//

/// Uploads media messages from local file.
/// Allows cancel, pause, resume upload.
class UploadService {
  //
  // MARK: - Variables And Properties
  //
  var activeUploads: [URL: Upload] = [ : ]
  
  /// MessagesController creates uploadsSession
  var uploadsSession: URLSession!
  
  //
  // MARK: - Internal Methods
  //
  func cancelUpload(_ message: UserMessage) {
    guard let upload = activeUploads[message.imageURL!] else {
      return
    }
    upload.task?.cancel()
    activeUploads[message.imageURL!] = nil
  }
  
  func pauseUpload(_ message: UserMessage) {
    guard let upload = activeUploads[message.imageURL!],
      upload.isUploading else {
        return
    }
    upload.task?.suspend()
    upload.isUploading = false
  }
  
  func resumeUpload(_ message: UserMessage) {
    guard let upload = activeUploads[message.imageURL!] else {
      return
    }
    upload.task?.resume()
    upload.isUploading = true
  }
  
  func startUpload(_ message: UserMessage) {
    let upload = Upload(message: message)
    upload.task = uploadsSession.uploadTask(with: message.uploadRequest!, fromFile: message.imageLocalURL()!)
    upload.task?.resume()
    upload.isUploading = true
    activeUploads[upload.message.imageURL!] = upload
  }
}



//
// MARK: - Download Service
//

/// Downloads mms images, and stores in local file.
/// Allows cancel, pause, resume download.
class DownloadService {
  //
  // MARK: - Variables And Properties
  //
  var activeDownloads: [URL: Download] = [ : ]
  
  /// MessagesController creates downloadsSession
  var downloadsSession: URLSession!
  
  //
  // MARK: - Internal Methods
  //
  func cancelDownload(_ message: UserMessage) {
    guard let download = activeDownloads[message.imageURL!] else {
      return
    }
    download.task?.cancel()

    activeDownloads[message.imageURL!] = nil
  }
  
  func pauseDownload(_ message: UserMessage) {
    guard
      let download = activeDownloads[message.imageURL!],
      download.isDownloading
      else {
        return
    }
    
    download.task?.cancel(byProducingResumeData: { data in
      download.resumeData = data
    })

    download.isDownloading = false
  }
  
  func resumeDownload(_ message: UserMessage) {
    guard let download = activeDownloads[message.imageURL!] else {
      return
    }
    
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
    } else {
      download.task = downloadsSession.downloadTask(with: download.message.imageURL!)
    }
    
    download.task?.resume()
    download.isDownloading = true
  }
  
  func startDownload(_ message: UserMessage) {
    guard activeDownloads[message.imageURL!] == nil else { return }
    let download = Download(message: message)
    download.task = downloadsSession.downloadTask(with: message.imageURL!)
    download.task?.resume()
    download.isDownloading = true
    activeDownloads[download.message.imageURL!] = download
  }
}





class FirebaseImageUploader {
    
    var uploadTask:StorageUploadTask!
    
    private let message:UserMessage
    
    init(message:UserMessage) {
        self.message = message
    }
    func start() {
        
    }
}










