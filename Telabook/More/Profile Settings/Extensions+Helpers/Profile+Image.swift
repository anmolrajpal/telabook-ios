//
//  Profile+Image.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Photos
import CropViewController
import Firebase

extension SettingsViewController {
    internal func promptPhotosPickerMenu() {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (action) in self.handleSourceTypeCamera() })
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (action) in self.handleSourceTypeGallery() })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        //        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        //        alert.view.tintColor = UIColor.telaBlue
        //        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        //        alert.view.subviews.first?.backgroundColor = .clear
        present(alert, animated: true, completion: nil)
    }
    private func viewCurrentProfileImage() {
        
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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    fileprivate func alertPhotoLibraryAccessNeeded() {
        let alert = UIAlertController.telaAlertController(title: "Need Library Access", message: "Photo Library access is required to read and write images")
        alert.addAction(UIAlertAction(title: "Allow", style: .cancel, handler: { _ in
            AppDelegate.shared.launchAppSettings()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: - Upload Profile Image
    
    private func uploadImage(_ image: UIImage) {
        guard let username = userProfile?.user?.username else {
            let errorMessage = "Error uploading profile image: Username not found"
            printAndLog(message: errorMessage, log: .default, logType: .error)
            return
        }
        
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.8) else {
            let errorMessage = "Profile Image Error: Unable to get scaled image or compressed image"
            printAndLog(message: errorMessage, log: .ui, logType: .error)
            fatalError(errorMessage)
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = "\(username).jpg"
        let reference = Config.FirebaseConfig.StorageConfig.Node.profileImage.reference.child(imageName)
        uploadTask = reference.putData(data, metadata: metadata)
        
        uploadTask.observe(.resume) { snapshot in
            printAndLog(message: "Upload Progile Picture task resumed", log: .firebase, logType: .info)
        }
        
        uploadTask.observe(.pause) { snapshot in
            printAndLog(message: "Upload Progile Picture task pasused", log: .firebase, logType: .info)
        }
        
        
        uploadTask.observe(.progress) { snapshot in
            let completedUnitCount = snapshot.progress!.completedUnitCount
            let totalUnitCount = snapshot.progress!.totalUnitCount
            let progress = Float(completedUnitCount) / Float(totalUnitCount)
            DispatchQueue.main.async {
                self.progressBar.setProgress(progress, animated: true)
                self.progressTitleLabel.text = "\(Int(progress * 100)) %"
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            printAndLog(message: "Upload Progile Picture task completed with success", log: .firebase, logType: .info)
            reference.downloadURL(completion: { (url, err) in
                guard let downloadUrl = url else {
                    if let err = err {
                        let errorMessage = "Error retrieving download url after uploading profile picture: \(err.localizedDescription)"
                        printAndLog(message: errorMessage, log: .firebase, logType: .error)
                        self.progressAlert.dismiss(animated: true) {
                            self.progressBar.setProgress(0.0, animated: false)
                            self.progressTitleLabel.text = "0 %"
                            UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription)
                        }
                    }
                    return
                }
                self.progressAlert.dismiss(animated: true) {
                    self.progressBar.setProgress(0.0, animated: false)
                    self.progressTitleLabel.text = "0 %"
                    self.profileImageUrl = downloadUrl.absoluteString
                    self.updateUserProfile()
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
            printAndLog(message: "User is cancelling Upload Progile Picture task", log: .firebase, logType: .debug)
            self.uploadTask.cancel()
        }
        progressAlert.addAction(cancelAction)
        progressAlert.view.addSubview(progressTitleLabel)
        progressAlert.view.addSubview(progressBar)
        let constraintHeight = NSLayoutConstraint(
           item: progressAlert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
           NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 140)
        progressAlert.view.addConstraint(constraintHeight)
    }
    func showProgressAlert(completion: (() -> Void)?) {
        TapticEngine.generateFeedback(ofType: .Medium)
        present(progressAlert, animated: true, completion: completion)
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
//        let fromView = profileImageView
        let vc = CropViewController(image: image)
        vc.delegate = self
//        self.show(vc, sender: self)
        picker.pushViewController(vc, animated: true)
//        vc.presentAnimatedFrom(self, fromView: fromView, fromFrame: fromView.frame, setup: nil, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        let toView = profileImageView
        cropViewController.dismissAnimatedFrom(cropViewController, toView: toView, toFrame: toView.bounds, setup: nil, completion: nil)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        let toView = profileImageView
        cropViewController.dismissAnimatedFrom(cropViewController, withCroppedImage: image, toView: toView, toFrame: toView.bounds, setup: nil) { () -> (Void) in
            self.showProgressAlert {
                self.uploadImage(image)
            }
        }
    }
    
}
