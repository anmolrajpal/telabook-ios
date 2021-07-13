//
//  MessageMediaManager.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import CoreData

protocol MessageMediaManagerDelegate: AnyObject {
    func downloadProgressDidUpdate(for downloadItem:Download, formattedDownloadedSize:String, formattedTotalSize:String)
    func downloadDidFinish(for downloadItem:Download)
    func uploadProgressDidUpdate(for uploadItem:Upload, formattedUploadedSize:String, formattedTotalSize:String)
    func uploadDidFinish(for uploadItem:Upload, message:UserMessage)
}


final class MessageMediaManager:NSObject {
    
    static let shared = MessageMediaManager()
    
    weak var delegate:MessageMediaManagerDelegate?

    var backgroundCompletionHandler: (() -> Void)?

    let configuration = URLSessionConfiguration.background(withIdentifier: .messageDownload)
    
    private let decoder = JSONDecoder()
    
    private var session:URLSession!
    
    let downloadService = DownloadService()
    let uploadService = UploadService()
    
    override init() {
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        downloadService.downloadsSession = session
        uploadService.uploadsSession = session
    }
}


// MARK: - URLSession Foreground Completion

extension MessageMediaManager: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}




// MARK: - Uploading

extension MessageMediaManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("### \(#function) Error: \(error)")
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadURL = task.originalRequest?.url else {
            return
        }
        
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        let uploadedSize = ByteCountFormatter.string(fromByteCount: totalBytesSent, countStyle: .file)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToSend, countStyle: .file)
        
        if let upload = uploadService.activeUploads[uploadURL] {
            upload.progress = progress
            delegate?.uploadProgressDidUpdate(for: upload, formattedUploadedSize: uploadedSize, formattedTotalSize: totalSize)
        } else {
            printAndLog(message: "\n\n\t\t### \(#function) - Active upload not found...", log: .network, logType: .error)
        }
    }
}
extension MessageMediaManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let jsonstring = String(data: data, encoding: .utf8) ?? "nil"
        guard let uploadURL = dataTask.originalRequest?.url else {
            return
        }
        if let upload = uploadService.activeUploads[uploadURL] {
            uploadService.activeUploads[uploadURL] = nil
            do {
                let metadata = try decoder.decode(FirebaseMediaMetadata.self, from: data)
                let object = upload.message
                let objectID = object.objectID
                let context = PersistentContainer.shared.newBackgroundContext()
                let message = context.object(with: objectID) as! UserMessage
                
                let mediaSize = Int(metadata.size ?? "0") ?? 0
                
                var urlString = uploadURL.absoluteString
                urlString = "\(urlString)?alt=media"
                if let token = metadata.downloadTokens {
                    urlString = "\(urlString)&token=\(token)"
                }
                let downloadURL = URL(string: urlString)!
                
                context.performAndWait {
                    do {
                        message.mediaSize = Int64(mediaSize)
                        message.imageURL = downloadURL
                        message.imageUrlString = downloadURL.absoluteString
                        message.uploadState = .uploaded
                        message.isUploading = false
                        try context.save()
                    } catch {
                        printAndLog(message: "### \(#function) - Core Data Error updating message: \(message)", log: .coredata, logType: .error)
                    }
                }
                delegate?.uploadDidFinish(for: upload, message: message)
            } catch {
                printAndLog(message: "### \(#function) - JSON decoding error while converting json string: \n\(jsonstring)", log: .ui, logType: .error)
            }
        } else {
            printAndLog(message: "\n\n\t\t### \(#function) - Active upload not found...", log: .network, logType: .error)
        }
    }
}





// MARK: - Downloading

extension MessageMediaManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadURL = downloadTask.originalRequest?.url else {
            printAndLog(message: "### \(#function) Failed to retrieve original request download url", log: .network, logType: .error)
            return
        }
        if let download = downloadService.activeDownloads[downloadURL] {
            downloadService.activeDownloads[downloadURL] = nil
//            guard let context = download.message.managedObjectContext else {
//                fatalError("### \(#function) - Failed to get managed object context of message: \(download.message)")
//            }
            var destinationURL:URL?
            let objectID = download.message.objectID
            let context = PersistentContainer.shared.newBackgroundContext()
            let referenceMessage = context.object(with: objectID) as! UserMessage
            context.performAndWait {
                do {
                    referenceMessage.imageUUID = UUID()
                    referenceMessage.downloadState = .downloaded
                    referenceMessage.isDownloading = false
                    try context.save()
                    destinationURL = referenceMessage.imageLocalURL()
                } catch {
                    referenceMessage.downloadState = .failed
                    printAndLog(message: "### \(#function): Core Data Error updating imageUUID: \(error)\n for message: \(referenceMessage)", log: .coredata, logType: .error)
                }
            }
            
            guard let fileURL = destinationURL else {
                printAndLog(message: "Failed to retrieve destination local image url from user message", log: .coredata, logType: .error)
                context.performAndWait {
                    do {
                        referenceMessage.downloadState = .failed
                        try context.save()
                    } catch {
                    }
                }
//                download.message.downloadState = .failed
                return
            }
            let fileManager = FileManager.default
            do {
                try fileManager.moveItem(at: location, to: fileURL)
            } catch {
                context.performAndWait {
                    do {
                        referenceMessage.downloadState = .failed
                        try context.save()
                    } catch {
                    }
                }
                let errorMessage = "### \(#function): Failed to move image file from tmp url: \(location) to image local url: \(fileURL); \nError Description: \(error)"
                printAndLog(message: errorMessage, log: .ui, logType: .error)
            }
            download.completionHandler?()
            delegate?.downloadDidFinish(for: download)
        } else {
            printAndLog(message: "\n\n\t\t### \(#function) - Active download not found...", log: .network, logType: .error)
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let downloadURL = downloadTask.originalRequest?.url else {
            printAndLog(message: "### \(#function) Failed to retrieve original request download url", log: .network, logType: .error)
            return
        }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let downloadedSize = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .file)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        if let download = downloadService.activeDownloads[downloadURL] {
            download.progress = progress
            delegate?.downloadProgressDidUpdate(for: download, formattedDownloadedSize: downloadedSize, formattedTotalSize: totalSize)
        } else {
            printAndLog(message: "\n\n\t\t### \(#function) - Active download not found...", log: .network, logType: .error)
        }
    }
    
}
extension MessagesController: MessageMediaManagerDelegate {
    func uploadProgressDidUpdate(for uploadItem: Upload, formattedUploadedSize: String, formattedTotalSize: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.messages.firstIndex(where: { $0.messageId == uploadItem.message.messageId }),
                let cell = self.messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: Int(index))) as? MultimediaMessageCell {
                cell.updateProgress(progress: uploadItem.progress, loadedSize: formattedUploadedSize, totalSize: formattedTotalSize)
            }
        }
    }
    
    func uploadDidFinish(for uploadItem: Upload, message:UserMessage) {
        sendNewMultimediaMessage(newMessage: message)
        if let index = messages.firstIndex(where: { $0.firebaseKey == message.messageId }) {
            DispatchQueue.main.async { [weak self] in
                self?.messagesCollectionView.reloadSections([Int(index)])
            }
        }
    }
    
    func downloadProgressDidUpdate(for downloadItem: Download, formattedDownloadedSize: String, formattedTotalSize: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.messages.firstIndex(where: { $0.messageId == downloadItem.message.messageId }),
                let cell = self.messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: Int(index))) as? MultimediaMessageCell {
                cell.updateProgress(progress: downloadItem.progress, loadedSize: formattedDownloadedSize, totalSize: formattedTotalSize)
            }
        }
    }
    func downloadDidFinish(for downloadItem: Download) {
        if let index = messages.firstIndex(where: { $0.messageId == downloadItem.message.messageId }) {
          DispatchQueue.main.async { [weak self] in
            self?.messagesCollectionView.reloadSections([Int(index)])
          }
        }
    }
    var activeDownloadMessages:[UserMessage] {
        let fetchRequest:NSFetchRequest<UserMessage> = UserMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversation == %@ AND type == %@ AND isDownloading = %d", customer, MessageCategory.multimedia.rawValue, true)
        var results = [UserMessage]()
        viewContext.performAndWait {
            do {
                results = try fetchRequest.execute()
            } catch {
                printAndLog(message: "\(error)", log: .coredata, logType: .error)
            }
        }
        return results
    }
}
