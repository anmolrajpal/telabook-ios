//
//  ScheduledMessageCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class ScheduledMessageCell: UITableViewCell {
    var scheduledMessage:ScheduleMessagesCodable.ScheduleMessage? {
        didSet {
            guard let message = scheduledMessage else { return }
            setupCell(message: message)
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
        contentView.addSubview(agentLabel)
        contentView.addSubview(customerLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
    }
    fileprivate func setupConstraints() {
        
        agentLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.centerXAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        customerLabel.anchor(top: contentView.topAnchor, left: contentView.centerXAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        let agentLabelExpectedTextSize = ((agentLabel.text ?? "") as NSString).size(withAttributes: [.font: agentLabel.font!])
        let customerLabelExpectedTextSize = ((customerLabel.text ?? "") as NSString).size(withAttributes: [.font: customerLabel.font!])
        let agentLabelTextWidth = agentLabelExpectedTextSize.width
        let customerLabelTextWidth = customerLabelExpectedTextSize.width
        let maxWidth = max(agentLabelTextWidth, customerLabelTextWidth)
        
        messageLabel.anchor(top: maxWidth == agentLabelTextWidth ? agentLabel.bottomAnchor : customerLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 15, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        timeLabel.anchor(top: messageLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 15, leftConstant: 20, bottomConstant: 10, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    
    
    let agentLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        return label
    }()
    let customerLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        return label
    }()
    let messageLabel:UILabel = {
        let label = InsetLabel(10, 10, 7, 7)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.telaGray3
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 15)
        label.textColor = UIColor.telaWhite
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
        return label
    }()
    let timeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        return label
    }()
    
    fileprivate func setupCell(message:ScheduleMessagesCodable.ScheduleMessage) {
        setupAgentLabel(message.worker)
        setupCustomerLabel(message.customer)
        messageLabel.text = message.text
        setupTimeLabel(message.waitTime)
    }
    fileprivate func setupAgentLabel(_ text:String?) {
        let agentTitleAttributedString = NSAttributedString(string: "Agent: ", attributes: [
            .foregroundColor : UIColor.telaGray5
            ])
        let agentNameAttributedString = NSAttributedString(string: text ?? "", attributes: [
            .foregroundColor : UIColor.telaGray7
            ])
        let agentAttributedString = NSMutableAttributedString()
        agentAttributedString.append(agentTitleAttributedString)
        agentAttributedString.append(agentNameAttributedString)
        agentLabel.attributedText = agentAttributedString
    }
    fileprivate func setupCustomerLabel(_ text:String?) {
        let customerTitleAttributedString = NSAttributedString(string: "Customer: ", attributes: [
            .foregroundColor : UIColor.telaGray5
            ])
        let customerNameAttributedString = NSAttributedString(string: text ?? "", attributes: [
            .foregroundColor : UIColor.telaGray7
            ])
        let customerAttributedString = NSMutableAttributedString()
        customerAttributedString.append(customerTitleAttributedString)
        customerAttributedString.append(customerNameAttributedString)
        customerLabel.attributedText = customerAttributedString
    }
    fileprivate func setupTimeLabel(_ text:String?) {
        if let date = Date.getDateFromString(dateString: text, dateFormat: CustomDateFormat.dateWithTime) {
            let dateStr = Date.isDateSame(date1: Date(), date2: date) ? "Today" : Date.getStringFromDate(date: date, dateFormat: "EEEE, MMMM d")
            let timeStr = Date.getStringFromDate(date: date, dateFormat: CustomDateFormat.hmma)
            
            let scheduledForTitleAttributedString = NSAttributedString(string: "Scheduled for ", attributes: [
                .foregroundColor : UIColor.telaGray7
                ])
            let dateAttributedString = NSAttributedString(string: dateStr, attributes: [
                .foregroundColor : UIColor.telaWhite
                ])
            let atTitleAttributedString = NSAttributedString(string: " at ", attributes: [
                .foregroundColor : UIColor.telaGray7
                ])
            let timeAttributedString = NSAttributedString(string: timeStr, attributes: [
                .foregroundColor : UIColor.telaWhite
                ])
            let timeLabelAttributedString = NSMutableAttributedString()
            timeLabelAttributedString.append(scheduledForTitleAttributedString)
            timeLabelAttributedString.append(dateAttributedString)
            timeLabelAttributedString.append(atTitleAttributedString)
            timeLabelAttributedString.append(timeAttributedString)
            timeLabel.attributedText = timeLabelAttributedString
        }
    }
}
