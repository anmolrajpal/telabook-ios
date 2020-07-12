//
//  AgentGallery+CollectionView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import QuickLook

extension AgentGalleryController {
    enum Section { case  main }
    
    typealias SectionType = Section
    typealias ItemType = AgentGalleryItem
    
    class DataSource: UICollectionViewDiffableDataSource<SectionType, ItemType> {}
    internal func configureCollectionView() {
        collectionView.delegate = self
        collectionView.registerCell(AgentGalleryCell.self)
        configureDataSource()
    }
    private func configureDataSource() {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(AgentGalleryCell.self, forItemAt: indexPath)
        cell.delegate = self
        cell.configure(withGalleryItem: item, at: indexPath, showSelectionIcons: collectionView.allowsMultipleSelection)
        return cell
        })
        updateUI(animating: false)
    }
    internal func updateUI(animating:Bool = true, reloadingData:Bool = false) {
        guard let snapshot = currentSnapshot() else { return }
        guard dataSource != nil else { return }
        dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
            guard let self = self else { return }
            if reloadingData { self.collectionView.reloadData() }
            if !self.galleryItems.isEmpty {
                self.stopSpinner()
                self.placeholderLabel.isHidden = true
            } else {
                self.placeholderLabel.isHidden = false
                self.placeholderLabel.text = "No Media"
            }
        })
    }
    private func currentSnapshot() -> NSDiffableDataSourceSnapshot<SectionType, ItemType>? {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(galleryItems)
        return snapshot
    }
    
    /// - Tag: Grid
    internal func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1.0/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
extension AgentGalleryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditing else {
            updateToolBarButtonsState()
            return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if delegate == nil {
            openGalleryItem(item: item)
        } else {
            guard let image = item.getImage() else { return }
            self.delegate?.agentGalleryController(controller: self, didPickImage: image, forGalleryItem: item, at: indexPath)
        }
        /*
        if indexPath.row == 0 {
            promptPhotosPickerMenu()
        } else {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            if delegate == nil {
                openGalleryItem(item: item)
            } else {
                guard let image = item.getImage() else { return }
                self.dismiss(animated: true) {
                    self.delegate?.agentGalleryController(didPickImage: image, forGalleryItem: item, at: indexPath)
                }
            }
        }
         */
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            updateToolBarButtonsState()
        }
    }
    internal func openGalleryItem(item:AgentGalleryItem) {
        guard let cachedImageURL = item.imageLocalURL() else { return }
        guard let index = galleryItems.firstIndex(where: {
            guard $0.imageLocalURL() != nil && $0.getImage() != nil else { return false }
            return $0.imageLocalURL() == cachedImageURL
        }) else { return }
        
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.delegate = self
        controller.currentPreviewItemIndex = index
        present(controller, animated: true)
    }
    
    
    
    // MARK: - Multiple selection methods.

    /// - Tag: collection-view-multi-select
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        // Returning `true` automatically sets `collectionView.allowsMultipleSelection`
        // to `true`. The app sets it to `false` after the user taps the Done button.
        print("\(#function)")
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        // Replace the Select button with Done, and put the
        // collection view into editing mode.
        print("\(#function)")
        setEditing(true, animated: true)
    }
    
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        print("\(#function)")
    }
}
extension AgentGalleryController:AgentGalleryCellDelegate {
    func startDownloadingMedia(forGalleryItem item: AgentGalleryItem, at indexPath: IndexPath) {
        if !collectionView.isDragging && !collectionView.isDecelerating {
            self.startDownloadingMedia(for: item, at: indexPath)
        }
    }
}


// MARK: - Quick Look Preview Controller

extension AgentGalleryController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        validGalleryItems.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        validGalleryItems[index].imageLocalURL()! as NSURL
    }
}


extension AgentGalleryController: QLPreviewControllerDelegate {
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        guard let url = item.previewItemURL,
            let index = validGalleryItems.firstIndex(where: { $0.imageLocalURL() == url }),
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? AgentGalleryCell else {
                return nil
        }
        return cell.imageView
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
//        self.resignFirstResponder()
//        self.becomeFirstResponder()
    }
}
