//
//  AgentGalleryCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
protocol AgentGalleryCellDelegate {
    func startDownloadingMedia(forGalleryItem item:AgentGalleryItem, at indexPath:IndexPath)
}
class AgentGalleryCell: UICollectionViewCell {
    
    var delegate:AgentGalleryCellDelegate?
    
    //MARK: - Constructors
    
    /// The loader animation over the cell
    lazy var spinner:CircularSpinner = {
        let view = CircularSpinner()
        return view
    }()
    
    
    /// The image view display the media content.
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    
    
    
    //MARK: - Methods
    private func setupSubviews() {
        contentView.backgroundColor = UIColor.telaGray4
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        contentView.addSubview(imageView)
        contentView.addSubview(spinner)
        layoutConstraints()
    }
    private func layoutConstraints() {
        imageView.fillSuperview()
        spinner.centerInSuperview()
        spinner.constraint(equalTo: CGSize(width: 40, height: 40))
    }
    
    private func startSpinner() {
        spinner.animate()
        spinner.isHidden = false
    }
    private func stopSpinner() {
        spinner.layer.removeAllAnimations()
        spinner.isHidden = true
    }
    func configure(withGalleryItem item:AgentGalleryItem, at indexPath:IndexPath) {
        let image = item.getImage()
        imageView.image = image
        switch item.state {
            case .failed:
                stopSpinner()
            case .downloaded:
                if image != nil {
                    stopSpinner()
                }
            case .new:
                startSpinner()
                delegate?.startDownloadingMedia(forGalleryItem: item, at: indexPath)
        }
    }
    func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: imageView)

        guard imageView.frame.contains(touchLocation) else {
            return
        }
        
    }
    
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
//        spinner.stopAnimation()
//        spinner.layer.removeAllAnimations()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        if imageView.image == nil {
//            spinner.animate()
//        } else {
//            spinner.layer.removeAllAnimations()
//            spinner.layer.lineWidth = 0
//        }
    }
}
