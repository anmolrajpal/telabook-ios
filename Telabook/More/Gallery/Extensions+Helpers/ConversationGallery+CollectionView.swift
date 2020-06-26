//
//  ConversationGallery+CollectionView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import QuickLook

extension ConversationGalleryController {
    enum Section { case  main }
    
    typealias SectionType = Section
    typealias ItemType = UserMessage
    
    class DataSource: UICollectionViewDiffableDataSource<SectionType, ItemType> {}
    internal func configureCollectionView() {
        collectionView.delegate = self
        collectionView.registerCell(ConversationGalleryCell.self)
        configureDataSource()
    }
    private func configureDataSource() {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(ConversationGalleryCell.self, forItemAt: indexPath)
            cell.imageView.image = item.getImage()
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
            if !self.validGalleryItems.isEmpty {
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
        snapshot.appendItems(validGalleryItems)
        return snapshot
    }
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

extension ConversationGalleryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let message = dataSource.itemIdentifier(for: indexPath) else { return }
        if delegate == nil {
            openGalleryItem(message: message)
        } else {
            guard let image = message.getImage() else { return }
            self.dismiss(animated: true) {
                self.delegate?.conversationGalleryController(didPickImage: image, forMessage: message, at: indexPath)
            }
        }
    }
    internal func openGalleryItem(message:UserMessage) {
        guard let cachedImageURL = message.imageLocalURL() else { return }
        guard let index = validGalleryItems.firstIndex(where: {
            guard $0.imageLocalURL() != nil && $0.getImage() != nil else { return false }
            return $0.imageLocalURL() == cachedImageURL
        }) else { return }
        
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.delegate = self
        controller.currentPreviewItemIndex = index
        present(controller, animated: true)
    }
}


// MARK: - Quick Look Preview Controller

extension ConversationGalleryController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        validGalleryItems.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        validGalleryItems[index].imageLocalURL()! as NSURL
    }
}


extension ConversationGalleryController: QLPreviewControllerDelegate {
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        guard let url = item.previewItemURL,
            let index = validGalleryItems.firstIndex(where: { $0.imageLocalURL() == url }),
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ConversationGalleryCell else {
                return nil
        }
        return cell.imageView
    }
}
