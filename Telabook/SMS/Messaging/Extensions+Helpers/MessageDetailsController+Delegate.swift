//
//  MessageDetailsController+Delegate.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import AVFoundation
import MessageKit

extension MessageDetailsViewController: UICollectionViewDelegateFlowLayout {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            UIAlertController.showTelaAlert(title: "Error", message: error.localizedDescription)
        } else {
            guard AppData.alertOnSavingMediaToLibrary else { return }
            let notificationsService = LocalNotificationService.shared
            notificationsService.notificationCenter.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                    case .authorized, .provisional:
                        notificationsService.postNotification(forRequest: .imageSavedToLibrary) {
                    }
                    default:
                        AssertionModalController().show()
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = "\(message.firebaseKey!)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            var menuItems = [UIMenuElement]()
            
            // MARK: - Save Image Action
            if self.message.messageType == .multimedia {
                if let image = self.message.getImage() {
                    let saveToCameraRollAction = UIAction(title: "Save Image", image: SFSymbol.download.image) { _ in
                        DispatchQueue.main.async {
                            self.requestPhotoLibrary {
                                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                            }
                        }
                    }
                    menuItems.append(saveToCameraRollAction)
                }
                // MARK: - Copy Image message Text Action
                if let text = self.message.textMessage, !text.isEmpty, !text.isBlank {
                    let copyAction = UIAction(title: "Copy Text", image: SFSymbol.copy.image) { _ in
                        UIPasteboard.general.string = text
                    }
                    menuItems.append(copyAction)
                }
            } else {
                // MARK: - Copy Action
                if let text = self.message.textMessage, !text.isEmpty, !text.isBlank {
                    let copyAction = UIAction(title: "Copy", image: SFSymbol.copy.image) { _ in
                        UIPasteboard.general.string = text
                    }
                    menuItems.append(copyAction)
                }
            }
            
            /*
            let forwardAction = UIAction(title: "Forward", image: SFSymbol.forward.image) { _ in
                
            }
            menuItems.append(forwardAction)
            */
            
            
            
            
            /*
            let setTagsAction = UIAction(title: "Add Tags", image: SFSymbol.tag.image) { _ in
                
            }
            menuItems.append(setTagsAction)
            */
            
            
            
            if let text = self.message.textMessage, !text.isEmpty, !text.isBlank {
                let speakAction = UIAction(title: "Speak", image: SFSymbol.speak.image) { _ in
                    let utterance = AVSpeechUtterance(string: text)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
                }
                menuItems.append(speakAction)
            }
            
            
            
            //MARK: - Delete message Action
            let deleteAction = UIAction(title: "Delete", image: SFSymbol.delete.image, attributes: .destructive) { _ in
                self.promptDeleteMessageAlert(forMessage: self.message)
            }
            if !self.message.isMessageDeleted {
                menuItems.append(deleteAction)
            }
            
            
            
            
            
            return UIMenu(title: "", children: menuItems)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard message.messageType == .multimedia, message.getImage() != nil else { return }
        
        animator.addCompletion { [weak self] in
            guard let self = self else { return }
            self.openMediaMessage(message: self.message)
        }
    }
    
    
    func promptDeleteMessageAlert(forMessage message:UserMessage) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: "Confirm Delete", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
        ])
        let attributedMessageString = NSAttributedString(string: "This can't be undone", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 11)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaGray6
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.setValue(attributedMessageString, forKey: "attributedMessage")
        alert.view.subviews[0].subviews[0].subviews[0].backgroundColor = UIColor.telaGray5
        alert.view.tintColor = UIColor.telaBlue
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.delegate?.deleteMessage(message: message, controller: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration)
    }
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let indexPath = IndexPath(item: 0, section: 0)
        guard let cell = messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell.messageContainerView, parameters: parameters)
    }
}
