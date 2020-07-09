//
//  AgentCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import PINCache

class AgentCell: UITableViewCell {
    let cellView = AgentCellView()
    static let cellHeight:CGFloat = 80.0
    var shouldShowBadgeCount = true
    var agentDetails:Agent? {
        didSet {
//            updateCell()
        }
    }
    
    private func updateCell() {
        guard let details = agentDetails else { return }
        let roleID = Int(details.roleID)
        let name = details.personName ?? "No Name"
        let initialsText = CustomUtils.shared.getInitials(from: name)
        let role = AppUserRole.getUserRole(byRoleCode: roleID)
        let lowPriorityCheck = details.priority1
        let mediumPriorityCheck = details.priority2
        let highPriorityCheck = details.priority3
        let urlString = details.profileImageURL?.absoluteString
        let profileImageURLString = CustomUtils.shared.getSlashEncodedURL(from: urlString)
        let pendingMessagesCount = Int(details.externalPendingMessagesCount)
        cellView.parameters = AgentCellView.Parameters(name: name,
                                                              initials: initialsText,
                                                              role: role,
                                                              profileImageURLString: profileImageURLString,
                                                              lowPriorityCheck: lowPriorityCheck,
                                                              mediumPriorityCheck: mediumPriorityCheck,
                                                              highPriorityCheck: highPriorityCheck,
                                                              pendingMessagesCount: pendingMessagesCount)
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        agentNameLabel.text = nil
        badgeCountLabel.text = nil
        badgeCountLabel.isHidden = true
    }
   
    
    
    // MARK: - Methods
    
    func configureCell(with agent:Agent, animated:Bool = false) {
        let name = agent.personName ?? "No Name"
        let initialsText = CustomUtils.shared.getInitials(from: name)
        
        agentNameLabel.text = name
        
        let count = Int(agent.externalPendingMessagesCount)
        updateBadgeCount(count: count)
        
        
        let urlString = agent.profileImageURL?.absoluteString
        let profileImageURLString = CustomUtils.shared.getSlashEncodedURL(from: urlString) ?? ""
        let url = URL(string: profileImageURLString)
        profileImageView.pin_setImage(from: url, placeholderImage: UIImage(initials: initialsText))
        
        
        
        guard !animated else {
            self.alpha = 0.1
            UIView.transition(with: self,
                              duration: 0.2,
                              options: [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
                                self.alpha = 1.0
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
        let newHeight = frame.size.height + CGFloat(Int(fontSize / 2))
        let newWidth = count <= 9 ? newHeight : frame.size.width + fontSize
        badgeCountLabel.constraint(equalTo: CGSize(width: newWidth, height: newHeight))
        
        badgeCountLabel.layer.cornerRadius = newHeight / 2
    }
    
    
    
    
    // MARK: - View Constructors
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var agentNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)
        return label
    }()
    lazy var agentDesignationLabel:UILabel = {
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
    lazy var lowPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var mediumPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_medium_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var highPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_high")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
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
    
    
    
    
    
    
    
    // MARK: - Setup views hierarchy
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(containerView)
        containerView.addSubview(agentNameLabel)
        contentView.addSubview(badgeCountLabel)
        
        layoutConstraints()
    }
        
        
        
        
    // MARK: - Layout Constraints
    
    private func layoutConstraints() {
        let imageViewHeight:CGFloat = 60
        profileImageView.anchor(top: nil, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: imageViewHeight, heightConstant: imageViewHeight)
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).activate()
        
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 10)
        
        
        agentNameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        agentNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
        
        
        badgeCountLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).activate()
        badgeCountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).activate()
    }
}
