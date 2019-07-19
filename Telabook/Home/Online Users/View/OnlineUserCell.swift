//
//  OnlineUserCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class OnlineUserCell: UITableViewCell {
    internal var onlineUser:OnlineUser? {
        didSet {
            guard let user = onlineUser else { print("Failed to unwrap Online User"); return }
            setupCell(with: user)
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
        contentView.addSubview(onlineStatusImageView)
        contentView.bringSubviewToFront(onlineStatusImageView)
        contentView.addSubview(onlineStatusLabel)
        containerView.addSubview(agentNameLabel)
        containerView.addSubview(dateTimeLabel)
        containerView.addSubview(lastEventLabel)
        contentView.addSubview(containerView)
    }
    fileprivate func setupConstraints() {
        profileImageView.anchor(top: nil, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
        onlineStatusImageView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).activate()
        onlineStatusImageView.centerYAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -2).activate()
        onlineStatusImageView.widthAnchor.constraint(equalToConstant: 28).activate()
        onlineStatusImageView.heightAnchor.constraint(equalToConstant: 28).activate()
        
        
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        agentNameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: onlineStatusLabel.topAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 10, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        onlineStatusLabel.anchor(top: nil, left: agentNameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        onlineStatusLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
        dateTimeLabel.centerYAnchor.constraint(equalTo: onlineStatusLabel.centerYAnchor).activate()
        dateTimeLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).activate()
        lastEventLabel.anchor(top: onlineStatusLabel.bottomAnchor, left: onlineStatusLabel.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 10, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    fileprivate func setupCell(with data: OnlineUser) {
        profileImageView.loadImageUsingCache(with: CustomUtils.shared.getSlashEncodedURL(from: data.profileImageURL))
        agentNameLabel.text = data.personName
        let currentDate = Date()
        let date = data.date ?? currentDate
        let dateString = Date.getStringFromDate(date: date, dateFormat: "MMM d, h:mm a")
        dateTimeLabel.text = dateString
        if date > currentDate.subtract(minutes: 3)! {
            print("Online")
            onlineStatusLabel.text = "Online"
            onlineStatusImageView.image = #imageLiteral(resourceName: "radio_active")
        } else if date > currentDate.subtract(minutes: 5)! {
            print("Idle")
            onlineStatusLabel.text = "Idle"
            onlineStatusImageView.image = #imageLiteral(resourceName: "online")
        } else {
            print("Offline")
            onlineStatusLabel.text = "Offline"
            onlineStatusImageView.image = #imageLiteral(resourceName: "idle")
        }
        
        
        
        
        let lastEventTitleAttributedString = NSAttributedString(string: "Last Event: ", attributes: [
            .foregroundColor : UIColor.telaGray7
            ])
        let lastEventNameAttributedString = NSAttributedString(string: data.lastEvent ?? "", attributes: [
            .foregroundColor : UIColor.telaBlue
            ])
        let lastEventAttributedString = NSMutableAttributedString()
        lastEventAttributedString.append(lastEventTitleAttributedString)
        lastEventAttributedString.append(lastEventNameAttributedString)
        lastEventLabel.attributedText = lastEventAttributedString
        
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
    let onlineStatusImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "online")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 14
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
    let dateTimeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaGray6
        label.textAlignment = .right
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12.0)
        return label
    }()
    let lastEventLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12.0)
        return label
    }()
    let onlineStatusLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12.0)
        return label
    }()
    let containerView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
}
