//
//  CallDetailsTableHeaderView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class CallDetailsTableHeaderView: UIView {
    
    var profileImageViewHeightConstraint = NSLayoutConstraint()
    
    struct Parameters: Codable {
        let profileImageURL: URL?
        let name: String?
        let phoneNumber: String
    }
    
    func configureData(with parameters: Parameters) {
        let urlString = parameters.profileImageURL?.absoluteString
        let profileImageURLString = CustomUtils.shared.getSlashEncodedURL(from: urlString) ?? ""
        let url = URL(string: profileImageURLString)
        
        if let name = parameters.name, !name.isBlank {
            let initialsText = CustomUtils.shared.getInitials(from: name)
            topLabel.text = name
            profileImageView.pin_setImage(from: url, placeholderImage: UIImage(initials: initialsText))
            bottomLabel.text = parameters.phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? parameters.phoneNumber
        } else {
            topLabel.text = parameters.phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? parameters.phoneNumber
            let placeholderImage = SFSymbol.person·crop·circle·fill.image(withSymbolConfiguration: .init(textStyle: .title3)).withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
            profileImageView.pin_setImage(from: url, placeholderImage: placeholderImage)
        }
    }
    
    
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var topLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    lazy var bottomLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray7
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    lazy var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    
    
    private func configureHierarchy() {
        containerView.addSubview(profileImageView)
        containerView.addSubview(topLabel)
        containerView.addSubview(bottomLabel)
        addSubview(containerView)
        
        layoutConstraints()
    }
    private func layoutConstraints() {
    
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        
        profileImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22).activate()
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).activate()
        let height = CGFloat(80)
        profileImageViewHeightConstraint = profileImageView.heightAnchor.constraint(equalToConstant: height)
        profileImageViewHeightConstraint.activate()
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).activate()
        
        profileImageView.layer.cornerRadius = height / 2.0
        profileImageView.layoutIfNeeded()
        
        topLabel.anchor(top: profileImageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 20, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        
        bottomLabel.anchor(top: topLabel.bottomAnchor, left: topLabel.leftAnchor, bottom: nil, right: topLabel.rightAnchor, topConstant: 14, leftConstant: 0, bottomConstant: 10, rightConstant: 0)
//        bottomLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).withPriority(1000).activate()
        containerView.bottomAnchor.constraint(equalTo: bottomLabel.bottomAnchor, constant: 22).activate()
        
        bottomAnchor.constraint(equalTo: containerView.bottomAnchor).activate()
    }
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }
}
