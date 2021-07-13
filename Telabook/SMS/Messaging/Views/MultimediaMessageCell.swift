//
//  MultimediaMessageCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit


protocol MultimediaMessageCellDelegate: AnyObject {
    func didTapDownloadButton(in cell:MultimediaMessageCell)
    func startDownloadingMedia(forMultimediaMessage message:UserMessage, at indexPath:IndexPath)
    func startUploadingMedia(forMultimediaMessage message:UserMessage, at indexPath:IndexPath)
    func handleMediaState(_ cell: MultimediaMessageCell, message:UserMessage, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
}


class MultimediaMessageCell: MMSMessageCell {
    
    // MARK: - Properties
    
    weak var cellDelegate: MultimediaMessageCellDelegate?
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    
    
    // MARK: - Lifecycle
        
    override func setupSubviews() {
        super.setupSubviews()
        configureHierarchy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
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
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let downloadButtonTouchArea = CGRect(x: downloadButton.frame.origin.x - 10.0, y: downloadButton.frame.origin.y - 10, width: downloadButton.frame.size.width + 20, height: downloadButton.frame.size.height + 20)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if downloadButtonTouchArea.contains(translateTouchLocation) && !downloadButton.isHidden {
            cellDelegate?.didTapDownloadButton(in: self)
        } else {
            super.handleTapGesture(gesture)
        }
    }
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        cellDelegate?.handleMediaState(self, message: message as! UserMessage, at: indexPath, in: messagesCollectionView)
    }
    
    
    
    
    // MARK: - Methods
    
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
    
    
    func handleMediaState(for message:UserMessage, at indexPath:IndexPath, in messagesCollectionView: MessagesCollectionView, upload:Upload?, download:Download?, shouldAutoDownload:Bool) {
        queue.cancelAllOperations()
        let operation = BlockOperation()
        operation.addExecutionBlock() { [weak self, weak operation] in
            guard let self = self, let operation = operation, !operation.isCancelled else {
                return
            }
            DispatchQueue.main.async() {
                guard !operation.isCancelled else { return }
                
                if message.uploadState == .none {
                    self.handleDownloadState(for: message, at: indexPath, in: messagesCollectionView, download: download, shouldAutoDownload: shouldAutoDownload)
                } else {
                    self.handleUploadState(for: message, at: indexPath, in: messagesCollectionView, upload: upload, download: download)
                }
            }
        }
        queue.addOperation(operation)
    }
    
    /*
    func handleMediaState(for message:UserMessage, at indexPath:IndexPath, in messagesCollectionView: MessagesCollectionView, upload:Upload?, download:Download?, shouldAutoDownload:Bool) {
        if message.uploadState == .none {
            self.handleDownloadState(for: message, at: indexPath, in: messagesCollectionView, download: download, shouldAutoDownload: shouldAutoDownload)
        } else {
            self.handleUploadState(for: message, at: indexPath, in: messagesCollectionView, upload: upload, download: download)
        }
    }
    */
    
    
    
    
    
    // MARK: - Private Methods
    
    private func handleUploadState(for message:UserMessage, at indexPath:IndexPath, in messagesCollectionView: MessagesCollectionView, upload:Upload?, download:Download?) {

        let imageLoaded = message.getImageData() != nil
        
        switch message.uploadState {
            case .none: break
            case .pending:
                guard imageLoaded else {
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
    private func handleDownloadState(for message:UserMessage, at indexPath:IndexPath, in messagesCollectionView: MessagesCollectionView, download:Download?, shouldAutoDownload:Bool) {
        let imageLoaded = message.getImageData() != nil
        
        switch message.downloadState {
            case .new:
                guard !imageLoaded else {
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
    private func startSpinner() {
        spinner.animate()
        spinner.isHidden = false
    }
    private func stopSpinner() {
        spinner.layer.removeAllAnimations()
        spinner.isHidden = true
    }
    
    
    
    
    
    
    // MARK: - View Constructors
    
    
    /// The overlay view shown on cell with selected state
    lazy var overlayView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
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
    
    private func configureHierarchy() {
        imageView.addSubview(overlayView)
        imageView.addSubview(downloadButton)
        imageView.addSubview(spinner)
        imageView.addSubview(progressBar)
        imageView.addSubview(statusLabel)
        imageView.addSubview(progressLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
        
//        overlayView.anchor(top: imageView.topAnchor, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        overlayView.fillSuperview()
        
        
        downloadButton.constraint(equalTo: .init(width: 50, height: 50))
        downloadButton.centerInSuperview()
//        downloadButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
//        downloadButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        downloadButton.layoutIfNeeded()
        downloadButton.layer.cornerRadius = downloadButton.bounds.height / 2
        
        
        
        spinner.constraint(equalTo: .init(width: 55, height: 55))
        spinner.centerInSuperview()
//        spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
//        spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        
        
        
        progressBar.constraint(equalTo: .init(width: 55, height: 55))
        progressBar.centerInSuperview()
//        progressBar.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).activate()
//        progressBar.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).activate()
        
        
        statusLabel.anchor(top: progressBar.bottomAnchor, left: imageView.leftAnchor, bottom: nil, right: imageView.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        progressLabel.anchor(top: statusLabel.bottomAnchor, left: statusLabel.leftAnchor, bottom: nil, right: statusLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
}
