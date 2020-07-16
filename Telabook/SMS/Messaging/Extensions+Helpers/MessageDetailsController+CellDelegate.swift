//
//  MessageDetailsController+CellDelegate.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import QuickLook
import MessageKit

extension MessageDetailsViewController: MessageCellDelegate {
    internal func openMediaMessage(message:UserMessage) {
        guard message.getImage() != nil else { return }
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.delegate = self
        controller.currentPreviewItemIndex = 0
        present(controller, animated: true)
    }
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard message.getImage() != nil else { return }
        openMediaMessage(message: message)
    }
}


extension MessageDetailsViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return message.getImage() != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        message.imageLocalURL()! as NSURL
    }
}


extension MessageDetailsViewController: QLPreviewControllerDelegate {
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        guard let cell = messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MMSCell else { return nil }
        return cell.imageView
    }
}
