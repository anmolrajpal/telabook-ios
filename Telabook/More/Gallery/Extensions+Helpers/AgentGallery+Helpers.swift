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
        setEditing(false, animated: false)
        configureNavigationBarAppearance()
        configureNavigationBarItems()
        configureHierarchy()
        configureProgressAlert()
        configureCollectionView()
        downloadGalleryItems()
    }
    private func configureNavigationBarItems() {
        title = "Gallery"
        
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectButtonDidTap))
        selectButton.tintColor = .telaBlue
        navigationItem.leftBarButtonItems = [selectButton]
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTap))
        doneButton.tintColor = .telaBlue
//        let image = #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal)
        let image = SFSymbol.plus·circle·fill.image(withSymbolConfiguration: .init(textStyle: .largeTitle))
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonDidTap))
        addButton.tintColor = UIColor.telaBlue
        navigationItem.rightBarButtonItems = [doneButton, addButton]
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonDidTap))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonDidTap))
        toolbarItems = [shareButton, spacer, deleteButton]
    }
    @objc
    private func shareButtonDidTap() {
        promptActivityController()
    }
    @objc
    private func deleteButtonDidTap() {
        promptDeleteItemsAlert()
    }
    @objc
    private func addButtonDidTap() {
        promptPhotosPickerMenu()
    }
    @objc
    private func doneButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc
    private func selectButtonDidTap() {
        setEditing(!isEditing, animated: true)
    }
    
    
    
    private func promptActivityController() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        let itemsToShare = indexPaths.compactMap({ dataSource.itemIdentifier(for: $0)?.getImage() })
        let count = itemsToShare.count
        guard count > 0 else { return }
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        present(controller, animated: true) {
            self.setEditing(false, animated: true)
        }
    }
    private func promptDeleteItemsAlert() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        let itemsToDelete = indexPaths.compactMap({ dataSource.itemIdentifier(for: $0) })
        let count = itemsToDelete.count
        guard count > 0 else { return }
        let alert = UIAlertController(title: "Confirm Delete", message: nil, preferredStyle: .actionSheet)
        let title = count > 1 ? "Delete \(count) items" : "Delete \(count) item"
        let deleteAction = UIAlertAction(title: title, style: .destructive) { _ in
            self.setEditing(false, animated: true)
            self.deleteGalleryItems(items: itemsToDelete)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setTitleColor(color: .telaBlue)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    func updateNavigationBarLeftButton() {
        guard let button = navigationItem.leftBarButtonItem else { return }
        button.title = isEditing ? "Cancel" : "Select"
    }
    func updateNavigationBarAddButton() {
        guard let button = navigationItem.rightBarButtonItems?.last else { return }
        button.isEnabled = !isEditing
    }
    func updateToolBar() {
        navigationController?.setToolbarHidden(!isEditing, animated: true)
        updateToolBarButtonsState()
    }
    func updateToolBarButtonsState() {
        let isEnabled = collectionView.indexPathsForSelectedItems?.count ?? 0 > 0
        toolbarItems?.first?.isEnabled = isEnabled
        toolbarItems?.last?.isEnabled = isEnabled
    }
    func clearSelectedItems(animated: Bool) {
        collectionView.indexPathsForSelectedItems?.forEach({ (indexPath) in
            collectionView.deselectItem(at: indexPath, animated: animated)
        })
        updateUI(animating: false)
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
