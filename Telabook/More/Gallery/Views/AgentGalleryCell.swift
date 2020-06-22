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
    
    var showSelectionIcons = false
    
    
    
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
    
    
    /// The image view shows the checkmark determining selected state when set editing = true
    lazy var selectedImageView:UIImageView = {
        let view = UIImageView()
        view.image = SFSymbol.checkmark·circle·fill.image(withSymbolConfiguration: .init(textStyle: .title2))
        view.backgroundColor = .white
        view.contentMode = .center
        view.clipsToBounds = true
        return view
    }()
    
    
    /// The image view shows the cicle determining unselected state when set editing = true
    lazy var unselectedImageView:UIImageView = {
        let view = UIImageView()
        view.image = SFSymbol.circle.image(withSymbolConfiguration: .init(textStyle: .title2))
        view.backgroundColor = .white
        view.contentMode = .center
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    /// The overlay view shown on cell with selected state
    lazy var overlayView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.layer.opacity = 0.5
        view.contentMode = .scaleToFill
        return view
    }()
    
    
    
    
    
    //MARK: - Methods
    private func setupSubviews() {
        contentView.backgroundColor = UIColor.telaGray4
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        contentView.addSubview(imageView)
        contentView.addSubview(spinner)
        contentView.addSubview(overlayView)
        contentView.addSubview(unselectedImageView)
        contentView.addSubview(selectedImageView)
        layoutConstraints()
    }
    private func layoutConstraints() {
        imageView.fillSuperview()
        spinner.centerInSuperview()
        spinner.constraint(equalTo: CGSize(width: 40, height: 40))
        overlayView.fillSuperview()
        unselectedImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -6).activate()
        unselectedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).activate()
        selectedImageView.anchor(top: unselectedImageView.topAnchor, left: unselectedImageView.leftAnchor, bottom: unselectedImageView.bottomAnchor, right: unselectedImageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        selectedImageView.layoutIfNeeded()
        selectedImageView.layer.cornerRadius = selectedImageView.bounds.height / 2
        unselectedImageView.layoutIfNeeded()
        unselectedImageView.layer.cornerRadius = unselectedImageView.bounds.height / 2
    }
    
    private func startSpinner() {
        spinner.animate()
        spinner.isHidden = false
    }
    private func stopSpinner() {
        spinner.layer.removeAllAnimations()
        spinner.isHidden = true
    }
    func configure(withGalleryItem item:AgentGalleryItem, at indexPath:IndexPath, showSelectionIcons:Bool) {
        self.showSelectionIcons = showSelectionIcons
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
        showSelectionOverlay()
    }
    private func showSelectionOverlay() {
        let alpha: CGFloat = (isSelected && showSelectionIcons) ? 1.0 : 0.0
        overlayView.alpha = alpha
        selectedImageView.alpha = alpha
        unselectedImageView.alpha = showSelectionIcons ? 1.0 : 0.0
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
        isSelected = false
        showSelectionIcons = false
        showSelectionOverlay()
    }
    override var isSelected: Bool {
        didSet {
            showSelectionOverlay()
            setNeedsLayout()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
