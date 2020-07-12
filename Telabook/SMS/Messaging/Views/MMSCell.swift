//
//  MMSCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit


protocol MMSCellDelegate {
    func didTapDownloadButton(in cell:MMSCell)
    func startDownloadingMedia(forMultimediaMessage message:UserMessage, at indexPath:IndexPath)
    func startUploadingMedia(forMultimediaMessage message:UserMessage, at indexPath:IndexPath)
}

class MMSCell: MessageContentCell {
    var cellDelegate:MMSCellDelegate?
    var messageLabelHeightConstraint:NSLayoutConstraint!
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
    
    /// The overlay view shown on cell with selected state
    lazy var overlayView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.contentMode = .scaleToFill
        return view
    }()
    lazy var statusLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.telaBlue
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var progressLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        return label
    }()
    lazy var progressBar:CircularProgressBar = {
        let bar = CircularProgressBar()
        bar.lineWidth = 3
        bar.labelFont = UIFont.preferredFont(forTextStyle: .footnote)
        bar.isHidden = true
        return bar
    }()
    lazy var spinner:CircularSpinner = {
        let view = CircularSpinner()
        view.isHidden = true
        return view
    }()
    lazy var downloadButton:UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .medium)
        let image = SFSymbol.arrow·down·circle·fill.image(withSymbolConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.telaGray6
        button.clipsToBounds = true
        return button
    }()
    
    var messageLabel = MessageLabel()
    
//    lazy var bottomLabel:UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.white
//        label.numberOfLines = 1
//        label.font = UIFont.preferredFont(forTextStyle: .footnote)
//        return label
//    }()
 
    
    
    
    private func configureHierarchy() {
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(messageLabel)
//        messageContainerView.addSubview(bottomLabel)
//        messageContainerView.addSubview(playButtonView)
        messageContainerView.addSubview(overlayView)
        messageContainerView.addSubview(downloadButton)
        messageContainerView.addSubview(spinner)
        messageContainerView.addSubview(progressBar)
        messageContainerView.addSubview(statusLabel)
        messageContainerView.addSubview(progressLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
//        imageView.constraint(equalTo: CGSize(width: 240, height: 240))
        
        imageView.anchor(top: messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: nil, right: messageContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        
        
        messageLabel.anchor(top: imageView.bottomAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        messageLabelHeightConstraint = messageLabel.heightAnchor.constraint(equalToConstant: 0)
//        bottomLabel.anchor(top: messageLabel.bottomAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
//        playButtonView.centerInSuperview()
//        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
        
        overlayView.anchor(top: imageView.topAnchor, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        
        downloadButton.constraint(equalTo: .init(width: 50, height: 50))
        downloadButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
        downloadButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        downloadButton.layoutIfNeeded()
        downloadButton.layer.cornerRadius = downloadButton.bounds.height / 2
        
        
        
        spinner.constraint(equalTo: .init(width: 55, height: 55))
        spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        
        
        
        progressBar.constraint(equalTo: .init(width: 55, height: 55))
        progressBar.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
        progressBar.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        
        
        statusLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 15).activate()
        
        
        progressLabel.anchor(top: statusLabel.bottomAnchor, left: statusLabel.leftAnchor, bottom: nil, right: statusLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
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
        statusLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: 22).activate()
        statusLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -22).activate()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        messageLabel.text = nil
        messageLabel.attributedText = nil
//        bottomLabel.text = nil
        stopSpinner()
        overlayView.isHidden = true
        downloadButton.isHidden = true
        progressBar.layer.removeAllAnimations()
        progressBar.isHidden = true
        statusLabel.text = nil
        statusLabel.isHidden = true
        progressLabel.text = nil
        progressLabel.isHidden = true
    }
    
    
    
    
    
    
    
    
    private func startSpinner() {
        spinner.animate()
        spinner.isHidden = false
    }
    private func stopSpinner() {
        spinner.layer.removeAllAnimations()
        spinner.isHidden = true
    }
    func configure(with message: UserMessage, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, upload:Upload?, download:Download?, shouldAutoDownload:Bool) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        /*
        switch message.kind {
            case .photo(let mediaItem as ImageItem):
                imageView.image = mediaItem.image ?? mediaItem.placeholderImage
                playButtonView.isHidden = true
            case .video(let mediaItem as ImageItem):
                imageView.image = mediaItem.image ?? mediaItem.placeholderImage
                playButtonView.isHidden = false
            default: break
        }
        */

        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)
        
        messageLabel.configure {
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
//                        messageLabel.isHidden = false
                    } else {
                        messageLabelHeightConstraint.activate()
//                        messageLabel.isHidden = true
                        /*
                        let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
                        messageLabel.text = mediaItem.imageText
                        messageLabel.textColor = textColor
                        */
                }
                default: break
            }
        }
        
        if message.uploadState == .none {
            handleDownloadState(for: message, at: indexPath, download: download, shouldAutoDownload: shouldAutoDownload)
        } else {
            handleUploadState(for: message, at: indexPath, upload: upload, download: download)
        }
    }
    
    
    private func handleUploadState(for message:UserMessage, at indexPath:IndexPath, upload:Upload?, download:Download?) {
        let image = message.getImage()
        imageView.image = image
        let imageLoaded = image != nil
        
        switch message.uploadState {
            case .none: break
            case .pending:
                guard image != nil else {
                    fatalError("****** Need to resolve this: image not available for cell while uploading media")
                }
                startSpinner()
                overlayView.isHidden = false
                downloadButton.isHidden = true
                statusLabel.text = "Uploading..."
                statusLabel.isHidden = false
                if upload == nil {
                    cellDelegate?.startUploadingMedia(forMultimediaMessage: message, at: indexPath)
                }
                return
            case .uploaded:
                // In case image has been deleted locally
                if !imageLoaded {
                    if download != nil {
                        startSpinner()
                        overlayView.isHidden = false
                        downloadButton.isHidden = true
                        statusLabel.isHidden = false
                        statusLabel.text = "Downloading..."
                    } else {
                        downloadButton.isHidden = false
                        stopSpinner()
                        overlayView.isHidden = true
                        progressBar.isHidden = true
                        statusLabel.isHidden = true
                        progressLabel.isHidden = true
                    }
                } else {
                    self.stopSpinner()
                    self.overlayView.isHidden = imageLoaded
                    self.downloadButton.isHidden = imageLoaded
                    self.progressBar.isHidden = imageLoaded
                    self.statusLabel.isHidden = imageLoaded
                    self.progressLabel.isHidden = imageLoaded
                }
                return
            case .failed:
                self.stopSpinner()
                self.overlayView.isHidden = true
                self.downloadButton.isHidden = true
                self.progressBar.isHidden = true
                self.statusLabel.isHidden = false
                self.progressLabel.isHidden = true
                self.statusLabel.text = "Fail to Upload"
                return
        }
    }
    private func handleDownloadState(for message:UserMessage, at indexPath:IndexPath, download:Download?, shouldAutoDownload:Bool) {
        let image = message.getImage()
        imageView.image = image
        let imageLoaded = image != nil
        
        switch message.downloadState {
            case .new:
                guard image == nil else {
                    print("Should update message download state to `Downloaded`")
                    return
                }
                if shouldAutoDownload {
                    startSpinner()
                    overlayView.isHidden = false
                    downloadButton.isHidden = true
                    statusLabel.text = "Downloading..."
                    statusLabel.isHidden = false
                    if download == nil {
                        cellDelegate?.startDownloadingMedia(forMultimediaMessage: message, at: indexPath)
                    }
                } else {
                    if download != nil {
                        startSpinner()
                        overlayView.isHidden = false
                        downloadButton.isHidden = true
                        statusLabel.isHidden = false
                        statusLabel.text = "Downloading..."
                    } else {
                        stopSpinner()
                        overlayView.isHidden = true
                        downloadButton.isHidden = false
                        progressBar.isHidden = true
                        statusLabel.isHidden = true
                        progressLabel.isHidden = true
                        progressLabel.text = "1.5 MB"
                    }
                }
            case .downloaded:
                // In case image has been deleted locally
                if image == nil {
                    if download != nil {
                        startSpinner()
                        overlayView.isHidden = false
                        downloadButton.isHidden = true
                        statusLabel.isHidden = false
                        statusLabel.text = "Downloading..."
                    } else {
                        downloadButton.isHidden = false
                        stopSpinner()
                        overlayView.isHidden = true
                        progressBar.isHidden = true
                        statusLabel.isHidden = true
                        progressLabel.isHidden = true
                    }
                } else {
                    stopSpinner()
                    overlayView.isHidden = imageLoaded
                    downloadButton.isHidden = imageLoaded
                    progressBar.isHidden = imageLoaded
                    statusLabel.isHidden = imageLoaded
                    progressLabel.isHidden = imageLoaded
                }
            case .failed:
                stopSpinner()
                overlayView.isHidden = true
                downloadButton.isHidden = false
                progressBar.isHidden = true
                statusLabel.isHidden = false
                progressLabel.isHidden = true
                statusLabel.text = "Fail to download"
        }
    }
    
    
    
    
    func updateProgress(progress:Float, loadedSize:String, totalSize:String) {
        progressBar.setProgress(to: Double(progress), withAnimation: true)
        progressLabel.text = loadedSize + " / " + totalSize
        if progress > 0 && progressBar.isHidden {
            stopSpinner()
            overlayView.isHidden = false
            downloadButton.isHidden = true
            progressBar.isHidden = false
            statusLabel.isHidden = false
            progressLabel.isHidden = false
        }
    }
    

    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let downloadButtonTouchArea = CGRect(x: downloadButton.frame.origin.x - 10.0, y: downloadButton.frame.origin.y - 10, width: downloadButton.frame.size.width + 20, height: downloadButton.frame.size.height + 20)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if downloadButtonTouchArea.contains(translateTouchLocation) && !downloadButton.isHidden {
            cellDelegate?.didTapDownloadButton(in: self)
        } else {
//            super.handleTapGesture(gesture)
            switch true {
            case imageView.frame.contains(touchLocation):
                delegate?.didTapImage(in: self)
            default: break
            }
        }
    }
}
