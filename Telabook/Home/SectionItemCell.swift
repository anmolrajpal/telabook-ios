//
//  SectionItemCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class SectionItemCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    internal func configureCell(sectionItem:SectionItem) {
        sectionItemImageView.image = sectionItem.sectionImage
        sectionItemTitleLabel.text = sectionItem.sectionTitle
        sectionItemSubTitleLabel.text = sectionItem.sectionSubTitle
    }
//    let sectionItemButton:UIButton = {
//        let button = UIButton(type: UIButton.ButtonType.system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.cornerRadius = 7
//        button.backgroundColor = .clear
//
//        return button
//    }()
    
    fileprivate func setupViews() {
        contentView.addSubview(sectionItemView)
        sectionItemView.addSubview(sectionItemImageView)
        sectionItemView.addSubview(sectionItemTitleLabel)
        sectionItemView.addSubview(sectionItemSubTitleLabel)
    }
    fileprivate func setupConstraints() {
        sectionItemView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        sectionItemImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        sectionItemImageView.centerYAnchor.constraint(equalTo: sectionItemView.centerYAnchor, constant: -15).isActive = true
        sectionItemImageView.centerXAnchor.constraint(equalTo: sectionItemView.centerXAnchor).isActive = true
        sectionItemTitleLabel.anchor(top: sectionItemImageView.bottomAnchor, left: sectionItemView.leftAnchor, bottom: nil, right: sectionItemView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        sectionItemTitleLabel.centerXAnchor.constraint(equalTo: sectionItemView.centerXAnchor).isActive = true
        sectionItemSubTitleLabel.anchor(top: sectionItemTitleLabel.bottomAnchor, left: sectionItemView.leftAnchor, bottom: nil, right: sectionItemView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        sectionItemSubTitleLabel.centerXAnchor.constraint(equalTo: sectionItemView.centerXAnchor).isActive = true
        
    }
    let sectionItemView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.telaGray6.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .clear
        return view
    }()
    let sectionItemImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let sectionItemTitleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    let sectionItemSubTitleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
}
