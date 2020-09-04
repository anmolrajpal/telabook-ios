//
//  AgentCallCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class AgentCallCell: UITableViewCell {
    static let cellHeight: CGFloat = 56.0
    
    // MARK:: Setup Views Data
    struct Parameters: Equatable {
        let profileImageURL: URL?
        let name: String?
        let phoneNumber: String
        let count: Int
        let callDirection: AgentCall.CallDirection
        let callStatus: AgentCall.CallStatus
        let date: Date?
    }
    
    
    
    // MARK: - Methods
    
    func configureCell(with parameters: Parameters, animated:Bool = false) {
        let urlString = parameters.profileImageURL?.absoluteString
        let profileImageURLString = CustomUtils.shared.getSlashEncodedURL(from: urlString) ?? ""
        let url = URL(string: profileImageURLString)
        
        if let name = parameters.name, !name.isBlank {
            let initialsText = CustomUtils.shared.getInitials(from: name)
            nameLabel.text = name
            profileImageView.pin_setImage(from: url, placeholderImage: UIImage(initials: initialsText))
        } else {
            nameLabel.text = parameters.phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? parameters.phoneNumber
            let placeholderImage = SFSymbol.person·crop·circle.image(withSymbolConfiguration: .init(textStyle: .title3)).withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
            profileImageView.pin_setImage(from: url, placeholderImage: placeholderImage)
        }
        
        switch parameters.callStatus {
        case .answered: callDirectionImageView.tintColor = .systemBlue
        case .unanswered: callDirectionImageView.tintColor = .systemRed
        }
        
        let count = parameters.count
        counterLabel.text = count > 1 ? "(\(count))" : nil
        
        if let date = parameters.date {
            let string = Date.getStringFromDate(date: date, dateFormat: .hmma)
            dateLabel.text = string
        }
        
        guard !animated else {
            self.alpha = 0.1
            UIView.transition(with: self,
                              duration: 0.2,
                              options: [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
                                self.alpha = 1.0
            }, completion: nil)
            return
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
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    lazy var callDirectionImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = SFSymbol.arrow·down·left.image(withSymbolConfiguration: .init(textStyle: .body)).withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var counterLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray7
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    lazy var dateLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray7
        label.textAlignment = .right
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    lazy var containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    
    // MARK: - Setup views hierarchy
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(callDirectionImageView)
        containerView.addSubview(counterLabel)
        containerView.addSubview(dateLabel)
        contentView.addSubview(containerView)
        layoutConstraints()
    }
    
    
    // MARK: - Layout Constraints
    
    private func layoutConstraints() {
        let imageViewHeight:CGFloat = 40
        profileImageView.anchor(top: nil, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: imageViewHeight, heightConstant: imageViewHeight)
        profileImageView.layer.cornerRadius = imageViewHeight / 2
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).activate()
        
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 10)
        
        nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.centerYAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 3, rightConstant: 0)
        
        callDirectionImageView.anchor(top: containerView.centerYAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 3, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        counterLabel.anchor(top: nil, left: callDirectionImageView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        counterLabel.centerYAnchor.constraint(equalTo: callDirectionImageView.centerYAnchor).activate()
        
        dateLabel.anchor(top: nil, left: containerView.centerXAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        dateLabel.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor).activate()
        
    }
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        counterLabel.text = nil
        dateLabel.text = nil
    }
}
