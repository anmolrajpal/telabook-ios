//
//  SMSDetailCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class SMSDetailCell: UITableViewCell {
    static let cellHeight:CGFloat = 70.0
    var externalConversation:ExternalConversation? {
        didSet {
            guard let conversation = externalConversation else {return}
            self.setupCell(conversation: conversation)
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
    fileprivate func setupCell(conversation:ExternalConversation) {
        let priorityCode = conversation.priority
        self.priorityImageView.image = ConversationPriority.getImage(by: ConversationPriority.getPriority(by: Int(priorityCode)))
        if let number = conversation.customerPhoneNumber {
            if let name = conversation.internalAddressBookName {
                self.nameLabel.text = "\(name) (\(number))"
            } else {
                self.nameLabel.text = number
            }
        }
        if let lastMessage = conversation.allLastMessageText {
            self.lastMessageLabel.text = lastMessage
        }
        let dateTime = conversation.lastMessageDatetime
        let dateStr = Date.getStringFromDate(date: dateTime, dateFormat: CustomDateFormat.ddMMMyyyy)
        let timeStr = Date.getStringFromDate(date: dateTime, dateFormat: CustomDateFormat.hmma)
        let dateTimeStr = "\(dateStr) | \(timeStr)"
//        let size = (dateTimeStr as NSString).size(withAttributes: [.font: dateTimeLabel.font!])
        
        self.dateTimeLabel.text = dateTimeStr
//        self.dateTimeLabel.widthAnchor.constraint(equalToConstant: size.width + 20).isActive = true
        let color = UIColor.getConversationColor(color: ConversationColor.getColorBy(colorCode: Int(conversation.colour)))
        self.nameLabel.textColor = color
        let count = conversation.unreadMessages
        if count > 0 {
            self.badgeCountLabel.isHidden = false
            self.badgeCountLabel.text = String(count)
        } else {
            self.badgeCountLabel.isHidden = true
        }
    }
    fileprivate func setupViews() {
        contentView.addSubview(priorityImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(lastMessageLabel)
        containerView.addSubview(badgeCountLabel)
        containerView.addSubview(dateTimeLabel)
        contentView.addSubview(containerView)
    }
    fileprivate func setupConstraints() {
        priorityImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        priorityImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        priorityImageView.widthAnchor.constraint(equalToConstant:30).isActive = true
        priorityImageView.heightAnchor.constraint(equalToConstant:30).isActive = true
        containerView.anchor(top: contentView.topAnchor, left: priorityImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).isActive = true
        nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: badgeCountLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        badgeCountLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        badgeCountLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        
        dateTimeLabel.centerYAnchor.constraint(equalTo: lastMessageLabel.centerYAnchor).isActive = true
        dateTimeLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        dateTimeLabel.layoutIfNeeded()
        
        lastMessageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15).isActive = true
        lastMessageLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: 0).isActive = true
        lastMessageLabel.rightAnchor.constraint(equalTo: dateTimeLabel.leftAnchor, constant: -10).withPriority(999).isActive = true
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
    let lastMessageLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaGray7
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11.0)
        label.sizeToFit()
        return label
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
    let dateTimeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaBlue
        label.textAlignment = .right
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11.0)
        label.sizeToFit()
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
