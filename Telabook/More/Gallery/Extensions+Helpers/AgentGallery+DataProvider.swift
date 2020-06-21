//
//  AgentGallery+DataProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase

extension AgentGalleryController {
    func downloadGalleryItems() {
        if galleryItems.isEmpty {
            showLoadingPlaceholder()
            startSpinner()
        }
        let reference = Config.FirebaseConfig.Node.agentGallery(workerID: Int(agent.workerID)).reference
        reference.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                printAndLog(message: "### \(#function) Snapshot does not exists. Return()", log: .firebase, logType: .info)
                self.stopSpinner()
                self.placeholderLabel.text = "No Media"
                return
            }
            var items = [FirebaseAgentGalleryItem]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    guard let item = FirebaseAgentGalleryItem(snapshot: snapshot) else {
                        let errorMessage = "### \(#function) - Invalid Data Error: Failed to create Gallery item from Firebase child"
                        printAndLog(message: errorMessage, log: .firebase, logType: .debug)
                        continue
                    }
                    items.append(item)
                }
            }
            self.persistFirebaseAgentGalleryItemsInStore(entries: items, fetchedEntries: self.galleryItems)
        }) { error in
            let errorMessage = "Firebase Single Event Observer Error while observing Messages: \(error.localizedDescription)"
            printAndLog(message: errorMessage, log: .firebase, logType: .error)
        }
    }
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func persistFirebaseAgentGalleryItemsInStore(entries:[FirebaseAgentGalleryItem], fetchedEntries:[AgentGalleryItem]) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let objectID = agent.objectID
        let referenceAgent = context.object(with: objectID) as! Agent
        let operation = MergeGalleryItemEntriesFromFirebaseToStore_Operation(context: context, agent: referenceAgent, firebaseEntries: entries, fetchedEntries: fetchedEntries)
        operation.completionBlock = {
                if let error = operation.error {
                    print(error.localizedDescription)
                } else {
                    if self.galleryItems.isEmpty {
                        self.stopSpinner()
                        self.placeholderLabel.text = "No Media"
                    }
                }
        }
        queue.addOperations([operation], waitUntilFinished: false)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    
    
    
    
    func saveNewGalleryItemOnFirebase(newMediaItemUrlString:String, completion: @escaping (Result<Bool, FirebaseAuthService.FirebaseError>) -> ()) {
        let reference = Config.FirebaseConfig.Node.agentGallery(workerID: Int(agent.workerID)).reference
        guard let key = reference.childByAutoId().key else { return }
        
        let dictionary:[String:Any] = [
            "url":newMediaItemUrlString,
            "date":Date().milliSecondsSince1970
        ]
        
        reference.child(key).setValue(dictionary) { (error, _) in
            if let error = error {
                printAndLog(message: error.localizedDescription, log: .firebase, logType: .error)
                completion(.failure(.databaseSetValueError(error)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    
    
    
    
    
    
    // MARK: - operation management
    
    func suspendAllOperations() {
        operations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        operations.downloadQueue.isSuspended = false
    }
    
    func downloadMediaForOnscreenCells() {
        let pathsArray = collectionView.indexPathsForVisibleItems
        let allPendingOperations = Set(operations.downloadsInProgress.keys)
        
        var toBeCancelled = allPendingOperations
        let visiblePaths = Set(pathsArray)
        toBeCancelled.subtract(visiblePaths)
        
        var toBeStarted = visiblePaths
        toBeStarted.subtract(allPendingOperations)
        
        for indexPath in toBeCancelled {
            if let pendingDownload = operations.downloadsInProgress[indexPath] {
                pendingDownload.cancel()
            }
            operations.downloadsInProgress.removeValue(forKey: indexPath)
        }
        for indexPath in toBeStarted {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            startDownloadingMedia(for: item, at: indexPath)
        }
    }

    func startDownloadingMedia(for galleryItem: AgentGalleryItem, at indexPath: IndexPath) {
        guard operations.downloadsInProgress[indexPath] == nil else {
            return
        }
        let downloader = ImageDownloader(galleryItem, context: viewContext)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                self.operations.downloadsInProgress.removeValue(forKey: indexPath)
                self.updateUI(animating:false)
            }
        }
        operations.downloadsInProgress[indexPath] = downloader
        operations.downloadQueue.addOperation(downloader)
    }
    
    
    
    
    // MARK: - scrollview delegate methods
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            downloadMediaForOnscreenCells()
            resumeAllOperations()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        downloadMediaForOnscreenCells()
        resumeAllOperations()
    }
}
