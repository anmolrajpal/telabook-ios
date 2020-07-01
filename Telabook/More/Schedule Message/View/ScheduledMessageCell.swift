//
//  ScheduledMessageCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class ScheduledMessageCell: UITableViewCell {

    func configureCell(with message:ScheduledMessage, animated:Bool = true) {
        configureAgentLabel(message.workerName)
        configureCustomerLabel(message.customerName)
        messageLabel.text = message.textMessage
        configureTimeLabel(message.deliveryTime)
        
        switch message.deliveryStatus {
            case .pending:
                statusLabel.text = "Pending"
                statusImageView.tintColor = UIColor.systemOrange
            case .delivered:
                statusLabel.text = "Delivered"
                statusImageView.tintColor = UIColor.systemGreen
        }
        
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
    
    
    
    private func commonInit() {
        configureHierarchy()
    }
   
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutConstraints()
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    
    
    
    
    
    // MARK: - Helpers
    
    private func configureAgentLabel(_ text:String?) {
        guard let text = text else {
            agentLabel.text = nil
            agentLabel.attributedText = nil
            return
        }
        let agentTitleAttributedString = NSAttributedString(string: "Agent: ", attributes: [
            .foregroundColor : UIColor.telaGray5
        ])
        let agentNameAttributedString = NSAttributedString(string: text, attributes: [
            .foregroundColor : UIColor.telaGray7
        ])
        let agentAttributedString = NSMutableAttributedString()
        agentAttributedString.append(agentTitleAttributedString)
        agentAttributedString.append(agentNameAttributedString)
        agentLabel.attributedText = agentAttributedString
    }
    private func configureCustomerLabel(_ text:String?) {
        guard let text = text else {
            customerLabel.text = nil
            customerLabel.attributedText = nil
            return
        }
        let customerTitleAttributedString = NSAttributedString(string: "Customer: ", attributes: [
            .foregroundColor : UIColor.telaGray5
        ])
        let customerNameAttributedString = NSAttributedString(string: text, attributes: [
            .foregroundColor : UIColor.telaGray7
        ])
        let customerAttributedString = NSMutableAttributedString()
        customerAttributedString.append(customerTitleAttributedString)
        customerAttributedString.append(customerNameAttributedString)
        customerLabel.attributedText = customerAttributedString
    }
    private func configureTimeLabel(_ date:Date?) {
        guard let date = date else {
            timeLabel.text = nil
            timeLabel.attributedText = nil
            return
        }
        let isToday = Calendar.current.isDateInToday(date)
        let isTomorrow = Calendar.current.isDateInTomorrow(date)
        let isYesterday = Calendar.current.isDateInYesterday(date)
        let dateStr:String
        switch true {
            case isToday: dateStr = "Today"
            case isTomorrow: dateStr = "Tomorrow"
            case isYesterday: dateStr = "Yesterday"
            default: dateStr = Date.getStringFromDate(date: date, dateFormat: "EEEE, MMMM d")
        }
        
        let timeStr = Date.getStringFromDate(date: date, dateFormat: CustomDateFormat.hmma)
        
        let scheduledForTitleAttributedString = NSAttributedString(string: "Scheduled for ", attributes: [
            .foregroundColor : UIColor.telaGray7
        ])
        let dateAttributedString = NSAttributedString(string: dateStr, attributes: [
            .foregroundColor : UIColor.telaBlue
        ])
        let atTitleAttributedString = NSAttributedString(string: " at ", attributes: [
            .foregroundColor : UIColor.telaGray7
        ])
        let timeAttributedString = NSAttributedString(string: timeStr, attributes: [
            .foregroundColor : UIColor.telaBlue
        ])
        let timeLabelAttributedString = NSMutableAttributedString()
        timeLabelAttributedString.append(scheduledForTitleAttributedString)
        timeLabelAttributedString.append(dateAttributedString)
        timeLabelAttributedString.append(atTitleAttributedString)
        timeLabelAttributedString.append(timeAttributedString)
        timeLabel.attributedText = timeLabelAttributedString
    }
    
    
    
    
    
    
    // MARK: - Hierarchy
    
    private func configureHierarchy() {
        contentView.addSubview(agentLabel)
        contentView.addSubview(statusImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(customerLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
        
        agentLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: 16, bottomConstant: 0, rightConstant: 100)
        
        statusImageView.topAnchor.constraint(equalTo: agentLabel.topAnchor, constant: -3).activate()
        statusImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).activate()
        
        statusLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor).activate()
        statusLabel.rightAnchor.constraint(equalTo: statusImageView.leftAnchor, constant: -6).activate()
        
        
        customerLabel.anchor(top: agentLabel.bottomAnchor, left: agentLabel.leftAnchor, bottom: nil, right: statusImageView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        messageLabel.anchor(top: customerLabel.bottomAnchor, left: agentLabel.leftAnchor, bottom: nil, right: statusImageView.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        
        timeLabel.anchor(top: messageLabel.bottomAnchor, left: agentLabel.leftAnchor, bottom: contentView.bottomAnchor, right: statusImageView.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 20, rightConstant: 0)
//        timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).withPriority(1000).activate()
    }
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var agentLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    lazy var customerLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    lazy var messageLabel:UILabel = {
        let label = InsetLabel(textInsets: UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 7))
        label.backgroundColor = UIColor.telaGray4
        label.textAlignment = .left
        label.numberOfLines = 0
//        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 15)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.telaWhite
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    lazy var statusImageView:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = SFSymbol.circleSwitch.image
        return view
    }()
    lazy var statusLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.numberOfLines = 1
        let font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)!
        label.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
}
