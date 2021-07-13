//
//  AddressBookContactCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 12/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

class AddressBookContactCell: UITableViewCell {
   
   static let cellHeight:CGFloat = 60.0
   
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
      phoneNumberLabel.text = nil
      favouritedImageView.isHidden = true
   }
   
   
   // MARK: - Methods
   
   func configureCell(with contact: AddressBookContact, animated: Bool = false) {
      let phoneNumber = contact.contactPhoneNumber ?? ""
      let number = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
      let name = contact.contactName ?? contact.contactGlobalName
      let isFavourited = contact.isFavourited
      
      // - Setup name label
      if let name = name, !name.isBlank {
         nameLabel.text = name
      } else {
         nameLabel.text = number
      }
      
      // - Setup phone number label
      phoneNumberLabel.text = number
      
      // - Setup Favourited image view
      favouritedImageView.isHidden = !isFavourited
      
      
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
   
   // MARK: - View Constructors
   
   lazy var favouritedImageView:UIImageView = {
      let imageView = UIImageView()
      imageView.image = SFSymbol.star·fill.image.withTintColor(.telaBlue, renderingMode: .alwaysTemplate)
      imageView.contentMode = .scaleAspectFit
      imageView.clipsToBounds = true
      return imageView
   }()
   lazy var nameLabel:UILabel = {
      let label = UILabel()
      label.numberOfLines = 1
      label.textAlignment = .left
      label.lineBreakMode = NSLineBreakMode.byTruncatingTail
      label.textColor = .white
      label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 17.0)
      return label
   }()
   lazy var phoneNumberLabel:UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 1
      label.textColor = UIColor.telaGray7
      label.textAlignment = .left
      label.lineBreakMode = NSLineBreakMode.byTruncatingTail
      label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)
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
      containerView.addSubview(favouritedImageView)
      containerView.addSubview(phoneNumberLabel)
      contentView.addSubview(containerView)
      layoutConstraints()
   }
   
   // MARK: - Layout Constraints
   
   private func layoutConstraints() {
      
      containerView.fillSuperview()
      
      nameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: favouritedImageView.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
      nameLabel.lastBaselineAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -5).activate()
      
      favouritedImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).activate()
      favouritedImageView.constraint(equalTo: CGSize(width: 17, height: 17))
      favouritedImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
      
      phoneNumberLabel.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 5).activate()
      phoneNumberLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).activate()
      phoneNumberLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).activate()
   }
}
