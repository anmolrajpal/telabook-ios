//
//  ContactDetailsAddressCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

class ContactDetailsAddressCell: UITableViewCell {
   
   static let cellHeight:CGFloat = 100.0
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureHierarchy()
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      layoutConstraints()
   }
   override func prepareForReuse() {
      super.prepareForReuse()
      addressNameLabel.text = nil
      mainAddressLabel.text = nil
   }
   
   
   // MARK: - Methods
   
   func configureCell(with address: AddressBookProperties.Address, animated: Bool = false) {
      let addressName = address.addressName
      let mainAddress = address.mainAddress?.formattedAddress
      let isDefaultAddress = address.defaultAddress ?? false
      
      containerView.layer.borderColor = isDefaultAddress ? UIColor.telaBlue.cgColor : UIColor.telaGray7.cgColor
      
      // - Setup address name label
      addressNameLabel.text = addressName
      
      // - Setup main address label
      mainAddressLabel.text = mainAddress
      
      
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
   
   lazy var addressNameLabel:UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 1
      label.textAlignment = .left
      label.lineBreakMode = NSLineBreakMode.byTruncatingTail
      label.textColor = .white
      label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 17.0)
      return label
   }()
   lazy var mainAddressLabel:UILabel = {
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
      view.translatesAutoresizingMaskIntoConstraints = false
      view.clipsToBounds = true
      view.backgroundColor = UIColor.telaGray3.withAlphaComponent(0.5)
      view.layer.borderWidth = 1
      view.layer.cornerRadius = 10
      return view
   }()
   
   
   // MARK: - configure hierarchy
   
   private func configureHierarchy() {
      backgroundColor = .clear
      containerView.addSubview(addressNameLabel)
      containerView.addSubview(mainAddressLabel)
      contentView.addSubview(containerView)
      layoutConstraints()
   }
   
   // MARK: - Layout Constraints
   
   private func layoutConstraints() {
      
      containerView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 15, rightConstant: 0)
      
      addressNameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).activate()
      addressNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).activate()
      addressNameLabel.lastBaselineAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10).activate()
      
      mainAddressLabel.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 10).activate()
      mainAddressLabel.leftAnchor.constraint(equalTo: addressNameLabel.leftAnchor).activate()
      mainAddressLabel.rightAnchor.constraint(equalTo: addressNameLabel.rightAnchor).activate()
   }
}

