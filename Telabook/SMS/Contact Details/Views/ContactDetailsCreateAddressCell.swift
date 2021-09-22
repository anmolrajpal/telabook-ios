//
//  ContactDetailsCreateAddressCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

protocol ContactDetailsCreateAddressCellDelegate: AnyObject {
   func createNewAddressDidTap()
}
class ContactDetailsCreateAddressCell: UITableViewCell {
   weak var delegate: ContactDetailsCreateAddressCellDelegate?
   
   static let cellHeight:CGFloat = 100.0
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureHierarchy()
      configureTargetActions()
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      layoutConstraints()
   }
   
   
   // MARK: - Methods
   private func configureTargetActions() {
      createButton.addTarget(self, action: #selector(createButtonDidTap(_:)), for: .touchUpInside)
   }
   @objc
   private func createButtonDidTap(_ button: UIButton) {
      delegate?.createNewAddressDidTap()
   }
   
   // MARK: - View Constructors
   
   lazy var createButton: UIButton = {
      let button = UIButton(type: .system)
      let image = SFSymbol.plus·circle·fill.image(withSymbolConfiguration: .init(textStyle: .largeTitle))
         .image(scaledTo: CGSize(width: 32, height: 32))!
         .withTintColor(.telaBlue, renderingMode: .alwaysOriginal)
      button.setTitle("Create New Address", for: .normal)
      button.setTitleColor(UIColor.telaBlue, for: .normal)
      button.setImage(image, for: .normal)
      button.setBackgroundColor(color: UIColor.clear, forState: .normal)
      button.setBackgroundColor(color: UIColor.telaGray2.withAlphaComponent(0.5), forState: .highlighted)
      button.clipsToBounds = true
      button.semanticContentAttribute = .forceRightToLeft
      button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
      button.adjustsImageWhenHighlighted = false
      return button
   }()
   
   lazy var containerView:UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.clipsToBounds = true
      view.backgroundColor = UIColor.telaGray3.withAlphaComponent(1)
      view.layer.borderWidth = 1
      view.layer.borderColor = UIColor.telaGray7.cgColor
      view.layer.cornerRadius = 10
      return view
   }()
   
   
   // MARK: - configure hierarchy
   
   private func configureHierarchy() {
      backgroundColor = .clear
      containerView.addSubview(createButton)
      contentView.addSubview(containerView)
      layoutConstraints()
   }
   
   // MARK: - Layout Constraints
   
   private func layoutConstraints() {
      
      containerView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 15, rightConstant: 0)
      
      createButton.fillSuperview()
   }
}


