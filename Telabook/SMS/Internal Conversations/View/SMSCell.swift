//
//  SMSCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class SMSCell: UITableViewCell {
    static let cellHeight:CGFloat = 90.0
    var internalConversation:InternalConversation? {
        didSet {
            guard let conversation = internalConversation else {return}
            if let name = conversation.personName {
                self.nameLabel.text = name
                let initials = CustomUtils.shared.getInitials(from: name)
                if let urlStr = conversation.profileImageUrl,
                    let url = CustomUtils.shared.getSlashEncodedURL(from: urlStr) {
                    self.profileImageView.loadImageUsingCache(with: url, placeHolder: UIImage.placeholderInitialsImage(text: initials))
                } else {
                    self.profileImageView.loadImageUsingCache(with: nil, placeHolder: UIImage.placeholderInitialsImage(text: initials))
                }
            }
            if let lowPriorityCheck = conversation.priority1,
                lowPriorityCheck == "1" {
                self.stackView.addArrangedSubview(self.lowPriorityImageView)
            }
            if let mediumPriorityCheck = conversation.priority2,
                mediumPriorityCheck == "1" {
                self.stackView.addArrangedSubview(self.mediumPriorityImageView)
            }
            if let highPriorityCheck = conversation.priority3,
                highPriorityCheck == "1" {
                self.stackView.addArrangedSubview(self.highPriorityImageView)
            }
            let count = conversation.externalPendingMessages
            if count > 0 {
                self.badgeCountLabel.isHidden = false
                self.badgeCountLabel.text = String(count)
            } else {
                self.badgeCountLabel.isHidden = true
            }
            
        }
    }
    func check() {
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        contentView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(stackView)
        contentView.addSubview(containerView)
        contentView.addSubview(badgeCountLabel)
    }
    fileprivate func setupConstraints() {
        profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: badgeCountLabel.leftAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).isActive = true
        nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        stackView.leftAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: 0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15).isActive = true
//        badgeCountLabel.leftAnchor.constraint(equalTo: containerView.rightAnchor, constant: 10).isActive = true
        
        badgeCountLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
//        badgeCountLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        badgeCountLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        badgeCountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
      
    }
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    let nameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)
        return label
    }()
    lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.alignment = UIStackView.Alignment.center
        view.distribution = UIStackView.Distribution.equalSpacing
        return view
    }()
    let lowPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let mediumPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_medium_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let highPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_high")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    let badgeCountLabel:UILabel = {
        let label = InsetLabel(3.5, 3.5, 7, 7)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10"
        label.textColor = .telaWhite
        label.layer.cornerRadius = label.frame.height / 2
        label.backgroundColor = .telaRed
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)
        label.numberOfLines = 1
        label.clipsToBounds = true
        return label
    }()
}
