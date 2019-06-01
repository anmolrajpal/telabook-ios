//
//  ManageAgentsCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 30/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ManageAgentsCell: UITableViewCell {
    static let cellHeight:CGFloat = 90.0
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
                self.agentDetailsLabel.text = details
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
        containerView.addSubview(agentDetailsLabel)
        contentView.addSubview(containerView)
    }
    fileprivate func setupConstraints() {
    profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
    profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
      profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
     profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        agentNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).isActive = true
        agentNameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        agentDetailsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15).isActive = true
        agentDetailsLabel.anchor(top: nil, left: agentNameLabel.leftAnchor, bottom: nil, right: agentNameLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
    let agentNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)
        return label
    }()
    let agentDetailsLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12.0)
        return label
    }()
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
}
