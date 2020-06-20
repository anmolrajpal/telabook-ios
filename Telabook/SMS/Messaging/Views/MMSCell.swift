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

class MMSCell: MediaMessageCell {
    
    open var statusLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.telaBlue
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    open var progressLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.telaGray7
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        return label
    }()
    open var progressBar:CircularProgressBar = {
        let bar = CircularProgressBar()
        bar.lineWidth = 4
        return bar
    }()
    open var spinner:CircularSpinner = {
        let view = CircularSpinner()
        return view
    }()
    
    open func layoutConstraints() {
        spinner.centerInSuperview()
        spinner.constraint(equalTo: .init(width: 55, height: 55))
        
        progressBar.centerInSuperview()
        progressBar.constraint(equalTo: .init(width: 55, height: 55))
        
        statusLabel.anchor(top: progressBar.bottomAnchor, left: messageContainerView.leftAnchor, bottom: nil, right: messageContainerView.rightAnchor, topConstant: 15, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        
        progressLabel.anchor(top: statusLabel.bottomAnchor, left: messageContainerView.leftAnchor, bottom: nil, right: messageContainerView.rightAnchor, topConstant: 8, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
    }
    
    
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(spinner)
        messageContainerView.addSubview(progressBar)
        messageContainerView.addSubview(statusLabel)
        messageContainerView.addSubview(progressLabel)
        layoutConstraints()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        spinner.layer.removeAllAnimations()
        progressBar.layer.removeAllAnimations()
        progressLabel.text = nil
        statusLabel.text = nil
    }
    
    
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, upload:Upload?, download:Download?) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        spinner.animate()
        var shouldHide = true
        
        if upload != nil {
            // Upload in Progress
            shouldHide = false
            statusLabel.text = "Uploading..."
        } else if download != nil {
            // Download in Progress
            shouldHide = false
            statusLabel.text = "Downloading..."
        }
        
        progressBar.isHidden = shouldHide
        statusLabel.isHidden = shouldHide
        progressLabel.isHidden = shouldHide
        
    }
    
    func updateProgress(progress:Float, loadedSize:String, totalSize:String) {
        progressBar.setProgress(to: Double(progress), withAnimation: true)
        progressLabel.text = loadedSize + "/" + totalSize
    }
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        super.handleTapGesture(gesture)
    }
}
