//
//  CustomerCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {
    
    static let cellHeight:CGFloat = 80.0
    var shouldShowBadgeCount = true
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        lastMessageLabel.text = nil
        dateTimeLabel.text = nil
        badgeCountLabel.isHidden = true
        pinImageView.isHidden = true
    }
    
    
    
    
    
    
    // MARK: - Methods
    
    func configureCell(with customer: Customer, animated: Bool = false) {
        let phoneNumber = customer.phoneNumber ?? ""
        let number = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
        let name = customer.addressBookName
        let messageType = MessageCategory(stringValue: customer.messageType ?? "")
        let lastMessage = customer.lastMessageText
        let lastMessageDate = customer.lastMessageDateTime
        let conversationColor = CustomerConversationColor.colorCase(from: Int(customer.colorCode)).color
        let unreadMessagesCount = Int(customer.unreadMessagesCount)
        let isPinned = customer.isPinned
        
        
        // - Setup name label
        if let name = name, !name.isBlank {
            nameLabel.text = name
        } else {
            nameLabel.text = number
        }
        nameLabel.textColor = conversationColor
        
        
        // - Setup last message label
        switch messageType {
            case .text: lastMessageLabel.text = lastMessage
            case .multimedia: lastMessageLabel.text = "📷"
            default: lastMessageLabel.text = nil
        }
        
        
        // - Setup date label
        if let lastMessageDate = lastMessageDate {
            let dateStr = Date.getStringFromDate(date: lastMessageDate, dateFormat: CustomDateFormat.ddMMMyyyy)
            let timeStr = Date.getStringFromDate(date: lastMessageDate, dateFormat: CustomDateFormat.hmma)
            let dateTimeStr = "\(dateStr) | \(timeStr)"
            dateTimeLabel.text = dateTimeStr
        } else {
            dateTimeLabel.text = nil
        }
        
        
        // - Setup Badge count label
        updateBadgeCount(count: unreadMessagesCount)
        
        
        // - Setup PIN image view
        pinImageView.isHidden = !isPinned
        
        
        
        
        guard !animated else {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 1.0)
            UIView.transition(with: self,
                              duration: 0.3,
                              options: [.curveLinear, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
                                self.transform = .identity
            }, completion: nil)
            return
        }
    }
    
    
    
    func configureCell(with conversation: LookupConversationProperties, animated: Bool = false) {
        let phoneNumber = conversation.customerPhoneNumber ?? ""
        let number = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
        
        
        let name = conversation.customerPerson
        let messageType = MessageCategory(stringValue: conversation.messageType ?? "")
        let lastMessage = conversation.allLastMessageText
        let lastMessageDate = conversation.lastMessageDatetime
        
        // - Setup name label
        if let name = name, !name.isBlank {
            nameLabel.text = name
        } else {
            nameLabel.text = number
        }
        
        // - Setup last message label
        switch messageType {
            case .text: lastMessageLabel.text = lastMessage
            case .multimedia: lastMessageLabel.text = "📷"
            default: lastMessageLabel.text = nil
        }
        
        // - Setup date label
        if let lastMessageDate = lastMessageDate {
            let dateStr = Date.getStringFromDate(date: lastMessageDate, dateFormat: CustomDateFormat.ddMMMyyyy)
            let timeStr = Date.getStringFromDate(date: lastMessageDate, dateFormat: CustomDateFormat.hmma)
            let dateTimeStr = "\(dateStr) | \(timeStr)"
            dateTimeLabel.text = dateTimeStr
        } else {
            dateTimeLabel.text = nil
        }
        
        // - Setup PIN image view
        pinImageView.isHidden = true
        
        guard !animated else {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 1.0)
            UIView.transition(with: self,
                              duration: 0.3,
                              options: [.curveLinear, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
                                self.transform = .identity
            }, completion: nil)
            return
        }
    }
    
    
    func updateBadgeCount(count: Int) {
        guard count > 0 && shouldShowBadgeCount else {
            badgeCountLabel.isHidden = true
            return
        }
        badgeCountLabel.isHidden = false
        let fontSize = badgeCountLabel.font!.pointSize
        badgeCountLabel.text = String(count)
        badgeCountLabel.sizeToFit()
        let frame = badgeCountLabel.frame
        let newHeight = frame.size.height + CGFloat(Int(fontSize * 0.4))
        let newWidth = count <= 9 ? newHeight : frame.size.width + fontSize
        badgeCountLabel.constraint(equalTo: CGSize(width: newWidth, height: newHeight))
        
        badgeCountLabel.layer.cornerRadius = newHeight / 2
    }
    
    
    
    
    // MARK: - View Constructors
    
    lazy var pinImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = SFSymbol.pin.image.withTintColor(.telaBlue).withRenderingMode(.alwaysTemplate).rotate(radians: .pi / 4)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 15.0)
        return label
    }()
    lazy var lastMessageLabel:UILabel = {
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
    lazy var badgeCountLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    lazy var dateTimeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaBlue
        label.textAlignment = .right
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11.0)
        label.sizeToFit()
        return label
    }()
    lazy var containerView:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    
    
    
    
    // MARK: - configure hierarchy
    
    private func configureHierarchy() {
        containerView.addSubview(nameLabel)
        containerView.addSubview(badgeCountLabel)
        containerView.addSubview(pinImageView)
        containerView.addSubview(dateTimeLabel)
        containerView.addSubview(lastMessageLabel)
        contentView.addSubview(containerView)
        layoutConstraints()
    }
    
    // MARK: - Layout Constraints
    
    private func layoutConstraints() {
        
        containerView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: badgeCountLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -20).activate()
        
        badgeCountLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).activate()
        badgeCountLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).activate()
        
        pinImageView.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 17, heightConstant: 17)
        pinImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
        
        dateTimeLabel.anchor(top: nil, left: containerView.centerXAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 5)
        dateTimeLabel.centerYAnchor.constraint(equalTo: lastMessageLabel.centerYAnchor).activate()
        
        lastMessageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 20).activate()
        lastMessageLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).activate()
        lastMessageLabel.rightAnchor.constraint(lessThanOrEqualTo: containerView.centerXAnchor).activate()
    }
    
}
