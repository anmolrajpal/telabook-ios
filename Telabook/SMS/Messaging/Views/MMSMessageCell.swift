//
//  MMSMessageCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit

open class MMSMessageCell: MessageContentCell {
    
    // MARK: - Properties

    private var imageViewHeightConstraint:NSLayoutConstraint!
    private var messageLabelZeroHeightConstraint:NSLayoutConstraint!
    
    // MARK: - View Constructors
    
    /// The play button view to display on video messages.
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()

    /// The image view display the media content.
    open lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.telaGray3
        imageView.clipsToBounds = true
        return imageView
    }()
    
    open lazy var messageLabel = MessageLabel()
    
    
    
    /// - Tag: Setup Views
    private func configureHierarchy() {
        
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(messageLabel)
        
        layoutConstraints()
    }
    private func layoutConstraints() {
 
        messageLabel.anchor(top: nil, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        messageLabelZeroHeightConstraint = messageLabel.heightAnchor.constraint(equalToConstant: 0)
        
    }
    
    
    
    
    // MARK: - Lifecycle
    
    open override func setupSubviews() {
        super.setupSubviews()
        configureHierarchy()
    }
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.font = attributes.messageLabelFont
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        messageLabel.text = nil
        messageLabel.attributedText = nil
    }
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        
        switch true {
            case imageView.frame.contains(translateTouchLocation):
                delegate?.didTapImage(in: self)
            default: break
        }
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        let message = message as! UserMessage

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)
        messageLabel.configure {
            messageLabel.backgroundColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            switch message.kind {
                case .photo(let mediaItem as ImageItem):
                    imageView.frame = CGRect(origin: .zero, size: mediaItem.size)
                    if let attributedText = mediaItem.attributedText, !attributedText.string.isEmpty {
                        messageLabel.attributedText = attributedText
                        messageLabelZeroHeightConstraint.deactivate()
                    } else {
                        messageLabelZeroHeightConstraint.activate()
                    }
                case .video(let mediaItem as ImageItem):
                    imageView.frame = CGRect(origin: .zero, size: mediaItem.size)
                    imageView.image = mediaItem.image ?? mediaItem.placeholderImage
                    if let attributedText = mediaItem.attributedText, !attributedText.string.isEmpty {
                        messageLabel.attributedText = attributedText
                        messageLabelZeroHeightConstraint.deactivate()
                    } else {
                        messageLabelZeroHeightConstraint.activate()
                    }
                default: break
            }
            
        }
        
    }
}
