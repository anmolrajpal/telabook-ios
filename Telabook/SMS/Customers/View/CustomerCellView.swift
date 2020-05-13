//
//  CustomerCellView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class CustomerCellView: UIView {
    // MARK:: Setup Views Data
    struct Parameters:Equatable {
        let priority:CustomerPriority
        let phoneNumber:String
        let name:String?
        let lastMessageType:MessageCategory
        let lastMessage:String?
        let lastMessageDate:Date?
        let conversationColor:UIColor
        let unreadMessagesCount:Int
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
        priorityImageView.image = parameters?.priority.image
        if let phoneNumber = parameters?.phoneNumber {
            if let name = parameters?.name {
                nameLabel.text = "\(name) (\(phoneNumber))"
            } else {
                nameLabel.text = phoneNumber
            }
        } else {
            nameLabel.text = nil
        }
        nameLabel.textColor = parameters?.conversationColor
        if parameters?.lastMessageType == .Text {
            lastMessageLabel.text = parameters?.lastMessage
        } else if parameters?.lastMessageType == .Multimedia {
            lastMessageLabel.text = "📷"
        } else {
            lastMessageLabel.text = nil
        }

        if let lastMessageDate = parameters?.lastMessageDate {
            let dateStr = Date.getStringFromDate(date: lastMessageDate, dateFormat: CustomDateFormat.ddMMMyyyy)
            let timeStr = Date.getStringFromDate(date: lastMessageDate, dateFormat: CustomDateFormat.hmma)
            let dateTimeStr = "\(dateStr) | \(timeStr)"
            dateTimeLabel.text = dateTimeStr
        } else {
            dateTimeLabel.text = nil
        }
        if let unreadMessagesCount = parameters?.unreadMessagesCount {
            badgeCountLabel.isHidden = unreadMessagesCount == 0
            badgeCountLabel.text = String(unreadMessagesCount)
        } else {
            badgeCountLabel.text = nil
            badgeCountLabel.isHidden = true
        }
        
       
        guard !animated else {
//            self.alpha = 0.1
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.6)
            UIView.transition(with: self,
                              duration: 0.4,
                              options: [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
//                                self.alpha = 1.0
                                self.transform = .identity
            }, completion: nil)
            return
        }
    }
    
    
    
    
    // MARK: init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutConstraints()
        updateContents()
    }
    
    
    
    
    
    //MARK: Add Views to hierarchy
    private func setupViews() {
        addSubview(priorityImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(badgeCountLabel)
        containerView.addSubview(dateTimeLabel)
        containerView.addSubview(lastMessageLabel)
        addSubview(containerView)
    }
    
    //MARK: Layout Constraints
    private func layoutConstraints() {
        priorityImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        priorityImageView.centerYAnchor.constraint(equalTo:centerYAnchor).activate()
        
        containerView.anchor(top: topAnchor, left: priorityImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: badgeCountLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).activate()
        
        badgeCountLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).activate()
        badgeCountLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).activate()
        
        
        dateTimeLabel.anchor(top: nil, left: containerView.centerXAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 5)
        dateTimeLabel.centerYAnchor.constraint(equalTo: lastMessageLabel.centerYAnchor).activate()
        
        lastMessageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15).activate()
        lastMessageLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).activate()
        lastMessageLabel.rightAnchor.constraint(lessThanOrEqualTo: containerView.centerXAnchor).activate()
    }
    
    
    //MARK: Constructors
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    lazy var priorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_high")
        imageView.contentMode = .scaleAspectFill
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
}
