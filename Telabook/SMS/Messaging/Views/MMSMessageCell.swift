//
//  MMSMessageCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit

class MMSMessageCell: MessageContentCell {
    
    // MARK: - Properties

    private var messageLabelHeightConstraint:NSLayoutConstraint!
    
    
    // MARK: - View Constructors
    
    /// The play button view to display on video messages.
    lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()

    /// The image view display the media content.
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.telaGray3
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var messageLabel = MessageLabel()
    
    
    
    /// - Tag: Setup Views
    private func configureHierarchy() {
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(messageLabel)
        
        
        layoutConstraints()
    }
    private func layoutConstraints() {
        imageView.fillSuperview()
        messageLabel.anchor(top: nil, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        messageLabelHeightConstraint = messageLabel.heightAnchor.constraint(equalToConstant: 0)
    }
    
    
    
    
    // MARK: - Lifecycle
    
    override func setupSubviews() {
        super.setupSubviews()
        configureHierarchy()
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.font = attributes.messageLabelFont
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        messageLabel.text = nil
        messageLabel.attributedText = nil
    }
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        switch true {
            case imageView.frame.contains(touchLocation):
                delegate?.didTapImage(in: self)
            default: break
        }
    }
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        let message = message as! UserMessage
        let image = message.getImage()
        imageView.image = image
        
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
                    if let attributedText = mediaItem.attributedText, !attributedText.string.isEmpty {
                        messageLabel.attributedText = attributedText
                        messageLabelHeightConstraint.deactivate()
                    } else {
                        messageLabelHeightConstraint.activate()
                    }
                default: break
            }
        }
        
    }
}
