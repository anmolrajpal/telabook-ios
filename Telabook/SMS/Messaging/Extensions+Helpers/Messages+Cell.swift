//
//  Messages+Cell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import QuickLook

extension MessagesController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let cell  = cell as? MessageContentCell else { return }
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let _ = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when text message cell receive tap gesture")
                return
        }
        indexPathForMessageBottomLabelToShow = indexPathForMessageBottomLabelToShow == indexPath ? nil : indexPath
        messagesCollectionView.reloadItems(at: [indexPath])
    }
    internal func openMediaMessage(message:UserMessage) {
        guard let cachedImageURL = message.imageLocalURL() else { return }
        guard let index = mediaMessages.firstIndex(where: {
            guard $0.imageLocalURL() != nil else { return false }
            return $0.imageLocalURL() == cachedImageURL
        }) else { return }
        
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.delegate = self
        controller.currentPreviewItemIndex = index
        present(controller, animated: true)
    }
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let cell  = cell as? MessageContentCell else { return }
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
                print("Failed to identify message when media cell receive tap gesture")
                return
        }
        
        indexPathForMessageBottomLabelToShow = indexPathForMessageBottomLabelToShow == indexPath ? nil : indexPath
//        messagesCollectionView.reloadItems(at: [indexPath])
        openMediaMessage(message: message)
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        print("Play Button Tapped")
    }

    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        guard let cell  = cell as? MessageContentCell else { return }
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) as? UserMessage else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        alertActionsForErrorMessage(message: message, at: indexPath)
    }
    func alertActionsForErrorMessage(message:UserMessage, at indexPath:IndexPath) {
        let alert = UIAlertController(title: "Error sending message", message: nil, preferredStyle: .actionSheet)
        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(retryAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = retryAction
        present(alert, animated: true)
    }
}



extension MessagesController: QLPreviewControllerDataSource {
    
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        mediaMessages.count
//        mediaMessages.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        mediaMessages[index].imageLocalURL()! as NSURL
    }
}


extension MessagesController: QLPreviewControllerDelegate {
    
    
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        if let url = item.previewItemURL {
            if let index = messages.firstIndex(where: { $0.imageLocalURL() == url }) {
                if let cell = messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: index)) as? MediaMessageCell {
//                    print("Preview item url: \(url)")
                    return cell.imageView
                }
            }
        }
        return nil
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.resignFirstResponder()
        self.becomeFirstResponder()
    }
}
