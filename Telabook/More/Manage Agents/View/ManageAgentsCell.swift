//
//  ManageAgentsCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 30/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ManageAgentsCell: UITableViewCell {
    static let cellHeight:CGFloat = 80.0
    var agentDetails:InternalConversationsCodable? {
        didSet {
            guard let details = agentDetails else {return}
            if let name = details.personName {
                self.agentNameLabel.text = name
                let initialsText = CustomUtils.shared.getInitials(from: name)
                if let urlStr = details.profileImageUrl,
                    let url = CustomUtils.shared.getSlashEncodedURL(from: urlStr) {
                    
                    self.profileImageView.loadImageUsingCache(with: url, placeHolder: UIImage.placeholderInitialsImage(text: initialsText))
                } else {
                    self.profileImageView.loadImageUsingCache(with: nil, placeHolder: UIImage.placeholderInitialsImage(text: initialsText))
                }
            }
            if let roleId = details.roleId {
                let designation = UserRole.getRole(by: roleId)
                self.agentDesignationLabel.text = String(describing: designation)
            }
            if let lowPriorityCheck = details.priority1,
                lowPriorityCheck == "1" {
                self.stackView.addArrangedSubview(self.lowPriorityImageView)
            }
            if let mediumPriorityCheck = details.priority2,
                mediumPriorityCheck == "1" {
                self.stackView.addArrangedSubview(self.mediumPriorityImageView)
            }
            if let highPriorityCheck = details.priority3,
                highPriorityCheck == "1" {
                self.stackView.addArrangedSubview(self.highPriorityImageView)
            }
        }
    }
    var agent:Agent? {
        didSet {
            guard let agentItem = agent else {return}
            if let image = agentItem.profileImage {
                self.profileImageView.image = image
            }
            if let name = agentItem.name {
                self.agentNameLabel.text = name
            }
            if let details = agentItem.details {
                self.agentDesignationLabel.text = details
            }
        }
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
        containerView.addSubview(agentNameLabel)
        containerView.addSubview(agentDesignationLabel)
        containerView.addSubview(stackView)
        contentView.addSubview(containerView)
    }
    fileprivate func setupConstraints() {
    profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
    profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
      profileImageView.widthAnchor.constraint(equalToConstant:60).isActive = true
     profileImageView.heightAnchor.constraint(equalToConstant:60).isActive = true
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        agentNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).isActive = true
        agentNameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        agentDesignationLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15).isActive = true
        agentDesignationLabel.anchor(top: nil, left: agentNameLabel.leftAnchor, bottom: nil, right: agentNameLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: agentDesignationLabel.centerYAnchor).isActive = true
    }
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    let agentNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)
        return label
    }()
    let agentDesignationLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12.0)
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
}
