//
//  Messages+Display.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit
import PINRemoteImage
import CoreData

extension MessagesController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let message = message as! UserMessage
        guard !message.isFault else { return .clear}
        switch message.kind {
        case .photo:
            return UIColor.telaGray7.withAlphaComponent(0.4)
        case .custom:
            return .clear
        case .emoji:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? .telaBlue : .telaGray7
        }
        
    }
//    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
////        guard let message = message as? UserMessage else { return }
////        if message.isMessageDeleted { return .black }
//        return .telaWhite
//    }
    
//    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
//        return indexPath.section == 3
//    }
    
    
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        let message = message as! UserMessage
        guard !message.isFault else { return [:]}
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.lightGray]
            }
            case .url:
                return [
                    .foregroundColor: UIColor.link,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.link
            ]
            case .date:
                return isFromCurrentSender(message: message) ? [
                    .foregroundColor: UIColor.telaGray7,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.telaGray7 ] : [
                        .foregroundColor: UIColor.telaGray5,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: UIColor.telaGray5 ]
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//        return .bubbleTail(corner, .curved)
        
//        var corners: UIRectCorner = []
        
        
        
        
//        if isFromCurrentSender(message: message) {
//            if !isNextMessageSenderSame(for: message as! UserMessage, at: indexPath) {
//                return .bubbleTail(.bottomRight, .curved)
//            } else {
//                return .bubble
//            }
//        } else {
//            if !isNextMessageSenderSame(for: message as! UserMessage, at: indexPath) {
//                return .bubbleTail(.bottomLeft, .curved)
//            } else {
//                return .bubble
//            }
//        }
        
        
        
        let message = message as! UserMessage
        
        if isFromCurrentSender(message: message) {
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
                return .bubbleTail(.bottomRight, .curved)
            } else {
                return .bubble
            }
        } else {
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageDateInSameDay(at: indexPath) {
                return .bubbleTail(.bottomLeft, .curved)
            } else {
                return .bubble
            }
        }
        
        
        
        
        
    
        
        /*
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
 */
//        return .custom { view in
//            let radius: CGFloat = 16
//            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            view.layer.mask = mask
//        }
        
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed

        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        let message = message as! UserMessage
        guard !message.isFault else { return }
        guard
            isFromCurrentSender(message: message) else { return }
        
        if !message.errorSending && !message.hasError { return }
        
        print("Should show error button")
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(SFSymbol.errorSendingBadge.image(withSymbolConfiguration: .init(textStyle: .title3)), for: .normal)
        button.tintColor = .systemRed
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
    }
    func downloadMessageImage(for message:UserMessage, indexPath:IndexPath, viewContext:NSManagedObjectContext) {
        guard let url = message.imageURL else { print("Message image remote url not available"); return }
        print("Downloading image for remote url: \(url)")
        serialQueue.async {
            URLSession.shared.downloadTask(with: url) { [weak self] (tmpURL, response, error) in
                guard let tmpURL = tmpURL else {
                    print("Error downloading image; no tmp url")
//                    completion(nil)
                    return
                }
                if let error = error {
                    print("MMS image downloading error; \(error.localizedDescription)")
//                    completion(nil)
                    return
                }
                
//                guard let imageData = try? Data(contentsOf: tmpURL) else { print("Failed to get data from temp url"); return }
                    
                var destinationURL:URL?
                viewContext.performAndWait {
                    do {
                        message.imageUUID = UUID()
                        try viewContext.save()
                        destinationURL = message.imageLocalURL()
                    } catch {
                        print("### \(#function): Core Data Error updating imageUUID: \(error)")
                    }
                }
                do {
                    try FileManager.default.moveItem(at: tmpURL, to: destinationURL!)
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self?.messagesCollectionView.reloadSections([indexPath.section])
                        }
                    }
                } catch {
                    print("### \(#function): Failed to move image file from tmp url: \(tmpURL) to image local url: \(destinationURL!); \nError Description: \(error)")
                }
            }.resume()
        }
    }
    func reloadCell(at indexPath:IndexPath) {
        messagesCollectionView.reloadSections([indexPath.section])
    }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        imageView.subviews.forEach { $0.removeFromSuperview() }
        let message = message as! UserMessage
//        guard let url = message.imageURL else { print("Message image remote url not available"); return }
//        let loader = UIActivityIndicatorView(style: .medium)
//        loader.color = .white
//        loader.hidesWhenStopped = true
//        loader.startAnimating()
//        loader.translatesAutoresizingMaskIntoConstraints = false
//
//        imageView.addSubview(loader)
//        loader.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
//        loader.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        
//        if message.imageUUID != nil,
//            let image = message.getImage() {
//            imageView.image = image
//            print("Loading image from local url: \(String(describing: message.imageLocalURL()))")
////            loader.stopAnimating()
//        } else {
//            if !messagesCollectionView.isDragging && !messagesCollectionView.isDecelerating {
//                downloadMessageImage(for: message, indexPath: indexPath, viewContext: viewContext)
//            downloadService.startDownload(message)
            
//            reloadCell(at: indexPath)
//            downloadMessageImage(for: message, viewContext: viewContext) { image in
//                if let image = image {
//                    imageView.image = image
//                    loader.stopAnimating()
//                } else {
//                    imageView.image = UIImage()
//                }
//            }
            /*
            imageView.pin_updateWithProgress = true
            imageView.pin_setImage(from: url) { result in
                if let image = result.image,
                    let imageData = image.jpegData(compressionQuality: 1) {
                    DispatchQueue.global().async {
                        var nsError: NSError?
                        NSFileCoordinator().coordinate(writingItemAt: message.imageLocalURL(), options: .forReplacing, error: &nsError,
                                                       byAccessor: { (newURL: URL) -> Void in
                            do {
                                try imageData.write(to: newURL, options: .atomic)
                            } catch {
                                print("###\(#function): Failed to save an image file: \(message.imageLocalURL())")
                            }
                        })
                        if let nsError = nsError {
                            print("###\(#function): \(nsError.localizedDescription)")
                        }
                    }
                }
            }
            */
//        }
        
        
        
        if let text = message.textMessage,
            !text.isBlank {
            #if !RELEASE
//            print("Image Text for image with URL: \(url) is => \(text)")
            #endif
//            let textView = mediaTextView
//            textView.text = text
//            textView.backgroundColor = isFromCurrentSender(message: message) ? .telaBlue : .telaGray7
//            imageView.addSubview(textView)
//            textView.anchor(top: nil, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
            
        }
//        imageView.loadImageUsingCache(with: url.absoluteString)
//        imageView.pin_updateWithProgress = true
//        imageView.pin_setImage(from: url) { result in
        
        
    }

 
 
    
}

