//
//  ScheduledMessageCellView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class ScheduledMessageCellView: UIView {
    
    // MARK: - Setup Views Data
    
    struct Parameters:Equatable {
        let customer:String?
        let worker:String?
        let textMessage:String?
        let deliveryTime:Date?
    }
    var parameters: Parameters? {
        didSet {
            if oldValue != parameters {
                updateContents(resetExisting: true)
            }
        }
    }
    
    private func updateContents(resetExisting: Bool = false) {
        queue.cancelAllOperations()
        
        if resetExisting || parameters == nil {
            setupData(parameters: nil, animated: false)
        }
        
        guard let parameters = parameters else { return }
        let operation = BlockOperation()
        
        operation.addExecutionBlock() { [weak self, weak operation] in
            guard let self = self, let operation = operation, !operation.isCancelled else {
                return
            }
            DispatchQueue.main.async() {
                guard !operation.isCancelled else { return }
                
                self.setupData(parameters: parameters, animated: true)
            }
        }
        
        queue.addOperation(operation)
    }
    private func setupData(parameters:Parameters?, animated:Bool) {
        configureAgentLabel(parameters?.worker)
        configureCustomerLabel(parameters?.customer)
        messageLabel.text = parameters?.textMessage
        configureTimeLabel(parameters?.deliveryTime)
        
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
    
    
    
    
    
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureHierarchy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutConstraints()
        updateContents()
    }
    

    
    
    
    // MARK: - Hierarchy
    
    private func configureHierarchy() {
        addSubview(agentLabel)
        addSubview(customerLabel)
        addSubview(messageLabel)
        addSubview(timeLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
        
        agentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        
        customerLabel.anchor(top: agentLabel.bottomAnchor, left: agentLabel.leftAnchor, bottom: nil, right: agentLabel.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        messageLabel.anchor(top: customerLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 15, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        
//        bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: -10).activate()
        
        timeLabel.anchor(top: messageLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 15, leftConstant: 22, bottomConstant: 10, rightConstant: 22)
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).withPriority(1000).activate()
    }
    
    
    
    
    
    
    //MARK: - Constructors
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    
    
    
    
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
        label.backgroundColor = UIColor.telaGray5
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 15)
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
}
