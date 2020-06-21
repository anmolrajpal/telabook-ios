//
//  AgentGallery+ImageHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase
import Photos
import CropViewController

extension AgentGalleryController {
    internal func promptPhotosPickerMenu() {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in self.handleSourceTypeCamera() })
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in self.handleSourceTypeGallery() })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    private func handleSourceTypeCamera() {
        requestCamera()
    }
    private func handleSourceTypeGallery() {
        requestPhotoLibrary()
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
    
    
    
    
    
    
    // MARK: - Upload Image to Gallery
    
    private func uploadImage(_ image: UIImage) {
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 1.0) else {
            let errorMessage = "### \(#function) - Agent Gallery Image upload Error: Unable to get scaled image or compressed image"
            printAndLog(message: errorMessage, log: .ui, logType: .error)
            fatalError(errorMessage)
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = "\(UUID().uuidString).jpeg"
        let reference = Config.FirebaseConfig.StorageConfig.Node.agentGallery(workerID: Int(agent.workerID)).reference.child(imageName)
        uploadTask = reference.putData(data, metadata: metadata)
        
        uploadTask.observe(.resume) { snapshot in
            printAndLog(message: "Upload Agent Gallery Picture task resumed", log: .firebase, logType: .info)
        }
        
        uploadTask.observe(.pause) { snapshot in
            printAndLog(message: "Upload Agent gallery Picture task pasused", log: .firebase, logType: .info)
        }
        
        
        uploadTask.observe(.progress) { snapshot in
            let completedUnitCount = snapshot.progress!.completedUnitCount
            let totalUnitCount = snapshot.progress!.totalUnitCount
            let progress = Float(completedUnitCount) / Float(totalUnitCount)
            let progressPercent = Int(progress * 100)
            self.progressTitleLabel.text = "\(progressPercent) %"
            DispatchQueue.main.async {
                self.progressBar.setProgress(progress, animated: true)
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            printAndLog(message: "### \(#function) Upload Agent gallery Picture task completed with success", log: .firebase, logType: .info)
            reference.downloadURL(completion: { (url, err) in
                guard let downloadUrl = url else {
                    if let err = err {
                        let errorMessage = "Error retrieving download url after uploading agent gallery picture: \(err.localizedDescription)"
                        printAndLog(message: errorMessage, log: .firebase, logType: .error)
                        self.progressAlert.dismiss(animated: true) {
                            UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription)
                        }
                    }
                    return
                }
                self.progressTitleLabel.text = "0 %"
                DispatchQueue.main.async {
                    self.progressBar.setProgress(0, animated: false)
                }
                let urlString = downloadUrl.absoluteString
                self.progressBar.isHidden = true
                self.progressTitleLabel.isHidden = true
                self.progressAlertSpinner.isHidden = false
                self.progressAlertSpinner.animate()
                self.saveNewGalleryItemOnFirebase(newMediaItemUrlString: urlString) { result in
                    switch result {
                        case let .failure(error):
                            self.progressAlert.dismiss(animated: true) {
                                UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription)
                            }
                        case .success:
                            self.progressAlert.dismiss(animated: true) {
                                self.downloadGalleryItems()
                            }
                    }
                }
            })
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                printAndLog(message: error.localizedDescription, log: .firebase, logType: .error)
                self.progressAlert.dismiss(animated: true) {
                    self.progressBar.setProgress(0.0, animated: false)
                    self.progressTitleLabel.text = "0 %"
                    UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription)
                }
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    print("User doesn't have permission to access file")
                    break
                case .cancelled:
                    print("User canceled the upload")
                    break
                case .unknown:
                    print("Unknown error occurred, inspect the server response")
                    break
                default:
                    print("A separate error occurred. This is a good place to retry the upload.")
                    break
                }
            }
        }
    }
    
    
    
    func configureProgressAlert() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            printAndLog(message: "User is cancelling Upload Agent Gallery Picture task", log: .ui, logType: .info)
            self.uploadTask.cancel()
        }
        progressAlert.addAction(cancelAction)
        progressAlert.view.addSubview(progressTitleLabel)
        progressAlert.view.addSubview(progressBar)
        progressAlert.view.addSubview(progressAlertSpinner)
        let constraintHeight = NSLayoutConstraint(
           item: progressAlert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
           NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 140)
        progressAlert.view.addConstraint(constraintHeight)
        progressAlertSpinner.constraint(equalTo: CGSize(width: 28, height: 28))
        progressAlertSpinner.centerXAnchor.constraint(equalTo: progressBar.centerXAnchor).activate()
        progressAlertSpinner.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor, constant: -15).activate()
    }
    func showProgressAlert(completion: (() -> Void)?) {
        self.progressBar.isHidden = false
        self.progressTitleLabel.isHidden = false
        self.progressAlertSpinner.isHidden = true
        TapticEngine.generateFeedback(ofType: .Medium)
        present(progressAlert, animated: true, completion: completion)
    }
}


extension AgentGalleryController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
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
            self.showProgressAlert {
                self.uploadImage(image)
            }
        }
    }
    
}
