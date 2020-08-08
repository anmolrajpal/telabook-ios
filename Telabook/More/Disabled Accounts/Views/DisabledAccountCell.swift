//
//  DisabledAccountCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class DisabledAccountCell: UITableViewCell {
    
    
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
         profileImageView.image = nil
         lineNameLabel.text = nil
         badgeCountLabel.text = nil
         badgeCountLabel.isHidden = true
     }
    
     
     
     // MARK: - Methods
     
     func configureCell(with account: DisabledAccountProperties, animated:Bool = false) {
         let name = account.personName ?? "No Name"
         let initialsText = CustomUtils.shared.getInitials(from: name)
         
         lineNameLabel.text = name
         
         let count = account.externalPendingMessages ?? 0
         updateBadgeCount(count: count)
         
         
         let urlString = account.profileImageUrl
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
    lazy var lineNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)
        return label
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
        containerView.addSubview(lineNameLabel)
        contentView.addSubview(badgeCountLabel)
        
        layoutConstraints()
    }
        
        
        
        
    // MARK: - Layout Constraints
    
    private func layoutConstraints() {
        let imageViewHeight:CGFloat = contentView.frame.height
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: imageViewHeight, heightConstant: imageViewHeight)
//        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).activate()
        
        containerView.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 10)
        
        
        lineNameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        lineNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
        
        
        badgeCountLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).activate()
        badgeCountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).activate()
    }
}