//
//  MessageDownloadService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
//
// MARK: - Download Service
//

/// Downloads mms images, and stores in local file.
/// Allows cancel, pause, resume download.
class DownloadService {
    
    var activeDownloads: [URL: Download] = [ : ]
    
    
    var downloadsSession: URLSession!
    
  
    func cancelDownload(_ message: UserMessage) {
        guard let download = activeDownloads[message.imageURL!] else {
            return
        }
        download.task?.cancel()
        
        activeDownloads[message.imageURL!] = nil
    }
    
    func pauseDownload(_ message: UserMessage) {
        guard let download = activeDownloads[message.imageURL!],
            download.isDownloading else {
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
        guard let url = message.imageURL else {
            fatalError("### \(#function) - Download URL not available for message: \(message)")
        }
        guard activeDownloads[url] == nil else {
            print("Already download in progress")
            return
        }
        guard let context = message.managedObjectContext else {
            fatalError("Failed to get managed object context from message: \(message)")
        }
        context.performAndWait {
            do {
//                _ = ActiveDownload(context: context, downloadURL: url, conversation: message.conversation!)
                message.isDownloading = true
                try context.save()
            } catch {
                printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
            }
        }
        let download = Download(message: message)
        download.task = downloadsSession.downloadTask(with: url)
        download.task?.resume()
        download.isDownloading = true
        activeDownloads[url] = download
    }
}
