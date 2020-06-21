//
//  AgentGallery+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension AgentGalleryController {
    internal func commonInit() {
        configureNavigationBarAppearance()
        configureNavigationBarItems()
        configureHierarchy()
        configureProgressAlert()
        configureCollectionView()
        downloadGalleryItems()
    }
    private func configureNavigationBarItems() {
        title = "Gallery"
        let image = #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonDidTap))
        navigationItem.rightBarButtonItems = [button]
    }
    @objc
    private func addButtonDidTap() {
        promptPhotosPickerMenu()
    }
    private func configureHierarchy() {
        view.backgroundColor = .telaGray1
        view.addSubview(collectionView)
        view.addSubview(spinner)
        view.addSubview(placeholderLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
        collectionView.fillSuperview()
        spinner.centerInSuperview()
        placeholderLabel.anchor(top: spinner.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 15, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
    }
    func startSpinner() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    func stopSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    func showLoadingPlaceholder() {
        placeholderLabel.text = "Loading..."
        placeholderLabel.isHidden = false
    }
}

extension AgentGalleryController {
    class PendingOperations {
        lazy var downloadsInProgress: [IndexPath: Operation] = [:]
        lazy var downloadQueue: OperationQueue = {
            var queue = OperationQueue()
            queue.name = "Agent's Gallery Download Queue"
            queue.maxConcurrentOperationCount = 1
            return queue
        }()
    }
    class ImageDownloader: Operation {
        
        let galleryItem: AgentGalleryItem
        let context:NSManagedObjectContext
        
        init(_ galleryItem: AgentGalleryItem, context:NSManagedObjectContext) {
            self.galleryItem = galleryItem
            self.context = context
        }
        
        override func main() {
            if isCancelled { return }
            
            guard let url = galleryItem.mediaItemURL,
                let imageData = try? Data(contentsOf: url) else { return }
            
            if isCancelled { return }
            
            var destinationURL:URL?
            context.performAndWait {
                do {
                    galleryItem.uuid = UUID()
                    try context.save()
                    destinationURL = galleryItem.imageLocalURL()
                } catch {
                    printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                }
            }
            
            if isCancelled { return }
            
            if !imageData.isEmpty {
                var nsError: NSError?
                NSFileCoordinator().coordinate(writingItemAt: destinationURL!, options: .forReplacing, error: &nsError, byAccessor: { (newURL: URL) -> Void in
                    do {
                        try imageData.write(to: newURL, options: .atomic)
                    } catch {
                        let errorMessage = "###\(#function) - Failed to save an image file: \(destinationURL!)"
                        printAndLog(message: errorMessage, log: .ui, logType: .error)
                    }
                })
                if let nsError = nsError {
                    print("###\(#function): \(nsError.localizedDescription)")
                }
                if isCancelled { return }
                context.performAndWait {
                    do {
                        galleryItem.state = .downloaded
                        try context.save()
                    } catch {
                        printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                    }
                }
            } else {
                if isCancelled { return }
                context.performAndWait {
                    do {
                        galleryItem.state = .failed
                        try context.save()
                    } catch {
                        printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
                    }
                }
            }
        }
    }

}
