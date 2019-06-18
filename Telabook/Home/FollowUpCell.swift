//
//  FollowUpCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class FollowUpCell:UITableViewCell {
    static let cellHeight:CGFloat = 91.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupCell() {
        self.priorityImageView.image = #imageLiteral(resourceName: "followup_small_high")
        self.nameLabel.text = "+1234567890"
        self.messageLabel.text = "Hi there!"
        self.dateTimeLabel.text = "12 Jun, 2019 | 9:37 AM"
    }
    fileprivate func setupViews() {
        contentView.addSubview(priorityImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(dateTimeLabel)
        contentView.addSubview(containerView)
    }
    fileprivate func setupConstraints() {
        priorityImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        priorityImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        priorityImageView.widthAnchor.constraint(equalToConstant:40).isActive = true
        priorityImageView.heightAnchor.constraint(equalToConstant:40).isActive = true
        containerView.anchor(top: contentView.topAnchor, left: priorityImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).isActive = true
        nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15).isActive = true
        messageLabel.anchor(top: nil, left: nameLabel.leftAnchor, bottom: nil, right: dateTimeLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        dateTimeLabel.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor).isActive = true
        dateTimeLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
    }
    let priorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_high")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    let nameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 15.0)
        return label
    }()
    let messageLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaGray7
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11.0)
        return label
    }()
    let dateTimeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaBlue
        label.textAlignment = .right
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11.0)
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
