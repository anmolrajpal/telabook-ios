//
//  TextFieldTableViewCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
   
   static let cellHeight:CGFloat = 50.0
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureHierarchy()
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func prepareForReuse() {
      super.prepareForReuse()
      textField.text = nil
   }
   
   
   // MARK: - Methods
   
   func configureCell(with text: String?, placeholder: String?, animated: Bool = false) {
      textField.text = text
      textField.placeholder = placeholder
      
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
   
   lazy var textField:UITextField = {
      let textField = UITextField()
      let font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)!
      textField.font = font
      textField.tintColor = .white
      textField.autocorrectionType = .no
      textField.keyboardAppearance = UIKeyboardAppearance.dark
      return textField
   }()
   lazy var containerView:UIView = {
      let view = UIView()
      view.clipsToBounds = true
      view.backgroundColor = .clear
      return view
   }()
   
   
   // MARK: - configure hierarchy
   
   private func configureHierarchy() {
      containerView.addSubview(textField)
      contentView.addSubview(containerView)
      layoutConstraints()
   }
   
   // MARK: - Layout Constraints
   
   private func layoutConstraints() {
      
      containerView.fillSuperview()
      
      textField.anchor(top: containerView.topAnchor,
                       left: containerView.leftAnchor,
                       bottom: containerView.bottomAnchor,
                       right: containerView.rightAnchor,
                       topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
   }
}
