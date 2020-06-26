//
//  MMSCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import MessageKit

extension UICollectionViewCell {
    static var identifier:String {
        NSStringFromClass(self)
    }
}
protocol MMSCellDelegate {
    func didTapDownloadButton(in cell:MMSCell)
    func startDownloadingMedia(forMultimediaMessage message:UserMessage, at indexPath:IndexPath)
    func startUploadingMedia(forMultimediaMessage message:UserMessage, at indexPath:IndexPath)
}

class MMSCell: MediaMessageCell {
    var cellDelegate:MMSCellDelegate?
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
        button.isHidden = true
        return button
    }()
    
    func layoutConstraints() {
        overlayView.fillSuperview()
        
        downloadButton.centerInSuperview()
        downloadButton.constraint(equalTo: .init(width: 50, height: 50))
        downloadButton.layoutIfNeeded()
        downloadButton.layer.cornerRadius = downloadButton.bounds.height / 2
        
        spinner.centerInSuperview()
        spinner.constraint(equalTo: .init(width: 55, height: 55))
        
        progressBar.centerInSuperview()
        progressBar.constraint(equalTo: .init(width: 55, height: 55))
        
        statusLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 15).activate()
        
        progressLabel.anchor(top: statusLabel.bottomAnchor, left: statusLabel.leftAnchor, bottom: nil, right: statusLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        statusLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: 22).activate()
        statusLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -22).activate()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(overlayView)
        messageContainerView.addSubview(downloadButton)
        messageContainerView.addSubview(spinner)
        messageContainerView.addSubview(progressBar)
        messageContainerView.addSubview(statusLabel)
        messageContainerView.addSubview(progressLabel)
        layoutConstraints()
//        configureTargetActions()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopSpinner()
        overlayView.alpha = 0
//        progressBar.setProgress(to: 0, withAnimation: false)
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
    open func configure(with message: UserMessage, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, upload:Upload?, download:Download?, shouldAutoDownload:Bool) {
        
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        let image = message.getImage()
        imageView.image = image
        let imageLoaded = image != nil
        
        switch message.uploadState {
            case .none: break
            case .pending:
                guard image != nil else {
                    print("****** Need to resolve this: image not available for cell while uploading media")
                    return
                }
                overlayView.alpha = 1.0
                startSpinner()
                statusLabel.text = "Uploading..."
                statusLabel.isHidden = false
                if let upload = upload {
                    if upload.progress > 0 || upload.isUploading {
                        self.stopSpinner()
                    }
                } else {
                    cellDelegate?.startUploadingMedia(forMultimediaMessage: message, at: indexPath)
                }
                return
            case .uploaded:
                // In case image has been deleted locally
                if !imageLoaded {
                    if download != nil {
                        startSpinner()
                        downloadButton.isHidden = true
                        statusLabel.isHidden = false
                        statusLabel.text = "Downloading..."
                    } else {
                        downloadButton.isHidden = false
                    }
                } else {
                    overlayView.alpha = 0
                    self.stopSpinner()
                    self.downloadButton.isHidden = imageLoaded
                    self.progressBar.isHidden = imageLoaded
                    self.statusLabel.isHidden = imageLoaded
                    self.progressLabel.isHidden = imageLoaded
                }
                return
            case .failed:
                self.stopSpinner()
                self.downloadButton.isHidden = true
                self.progressBar.isHidden = true
                self.statusLabel.isHidden = false
                self.progressLabel.isHidden = true
                self.statusLabel.text = "Fail to Upload"
                return
        }
        
        switch message.downloadState {
            case .new:
                guard image == nil else {
                    print("Should update message download state to `Downloaded`")
                    return
                }
                if shouldAutoDownload {
                    self.startSpinner()
                    statusLabel.text = "Downloading..."
                    self.statusLabel.isHidden = false
                    if let download = download {
                        if download.progress > 0 || download.isDownloading {
                            self.stopSpinner()
                        }
                    } else {
                        cellDelegate?.startDownloadingMedia(forMultimediaMessage: message, at: indexPath)
                    }
                } else {
                    if download != nil {
                        self.startSpinner()
                        self.downloadButton.isHidden = true
                        self.statusLabel.isHidden = false
                        self.statusLabel.text = "Downloading..."
                    } else {
                        self.stopSpinner()
                        self.downloadButton.isHidden = false
                        self.progressBar.isHidden = true
                        self.statusLabel.isHidden = true
                        self.progressLabel.isHidden = true
                        self.progressLabel.text = "1.5 MB"
                    }
                }
            case .downloaded:
                
                // In case image has been deleted locally
                if image == nil {
                    if download != nil {
                        startSpinner()
                        downloadButton.isHidden = true
                        statusLabel.isHidden = false
                        statusLabel.text = "Downloading..."
//                        if download.progress > 0 || download.isDownloading {
//                            stopSpinner()
//                            progressBar.isHidden = false
//                        }
                    } else {
                        downloadButton.isHidden = false
                    }
                } else {
                    self.stopSpinner()
                    self.downloadButton.isHidden = imageLoaded
                    self.progressBar.isHidden = imageLoaded
                    self.statusLabel.isHidden = imageLoaded
                    self.progressLabel.isHidden = imageLoaded
                }
            case .failed:
                self.stopSpinner()
                self.downloadButton.isHidden = false
                self.progressBar.isHidden = true
                self.statusLabel.isHidden = false
                self.progressLabel.isHidden = true
                self.statusLabel.text = "Fail to download"
        }
        
        
    }
    
    func updateProgress(progress:Float, loadedSize:String, totalSize:String) {
        progressBar.setProgress(to: Double(progress), withAnimation: true)
        progressLabel.text = loadedSize + " / " + totalSize
        if progress > 0 && progressBar.isHidden {
            stopSpinner()
            downloadButton.isHidden = true
            progressBar.isHidden = false
            statusLabel.isHidden = false
            progressLabel.isHidden = false
        }
    }
    
    private func configureTargetActions() {
        downloadButton.addTarget(self, action: #selector(downloadButtonDidTap(_:)), for: .touchUpInside)
    }
    @objc
    private func downloadButtonDidTap(_ button:UIButton) {
        cellDelegate?.didTapDownloadButton(in: self)
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
}
