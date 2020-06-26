//
//  ConversationGalleryCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class ConversationGalleryCell: UICollectionViewCell {
    
    
    // MARK: - Constructors
    
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
        layoutConstraints()
    }
    private func layoutConstraints() {
        imageView.fillSuperview()
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
    }
}
