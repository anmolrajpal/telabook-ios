//
//  MessageUploadService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

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
        FirebaseAuthService.shared.getCurrentToken { result in
            switch result {
                case let .success(token):
                    guard var request = message.uploadRequest else {
                        fatalError("Unable to get upload request from message")
                    }
                    request.setValue("Bearer \(token)", forHTTPHeaderField: Header.headerName.Authorization.rawValue)
                    guard let fileURL = message.imageLocalURL() else {
                        printAndLog(message: "### \(#function) - Failed to get image local url for message: \(message)", log: .coredata, logType: .error)
                        return
                    }
                    
                    let upload = Upload(message: message)
                    upload.task = self.uploadsSession.uploadTask(with: request, fromFile: fileURL)
                    upload.task?.resume()
                    upload.isUploading = true
                    self.activeUploads[request.url!] = upload
                case let .failure(error):
                    printAndLog(message: "### \(#function) - Unable to get id token from firebase: \(error)", log: .firebase, logType: .error)
            }
        }
    }
}


