//
//  NewConversationView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class NewConversationView: UIView {
    // MARK: init
    private func setupViews() {
        backgroundColor = .clear
        addSubview(blurredEffectView)
        addSubview(cancelButton)
        addSubview(headingLabel)
        addSubview(numberTextField)
        addSubview(startButton)
        addSubview(spinner)
        layoutConstraints()
    }
    private func layoutConstraints() {
        
        blurredEffectView.frame = bounds
        
        
        cancelButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 30, heightConstant: 30)
        
        
        headingLabel.anchor(top: cancelButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 40, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        
        
        let calculatedSize = ("(000) 000-0000" as NSString).size(withAttributes: [
            .font: numberTextField.font!,
            .kern: 1.5
        ])
        let leftViewWidth = numberTextField.leftView?.frame.width ?? 46.5
        let width = calculatedSize.width + leftViewWidth + 10 // 10 is extra unknown margin
        numberTextField.anchor(top: headingLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 60, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: 58)
        numberTextField.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
        startButton.anchor(top: numberTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 33)
        startButton.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
        
        spinner.centerXAnchor.constraint(equalTo: startButton.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).activate()
    }
    
    
    
    // MARK: Constructors
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    private lazy var blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.2)
        return button
    }()
    lazy var headingLabel:UILabel = {
        let label = UILabel()
        label.text = "New Conversation"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 25)
        label.textColor = .telaBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var numberTextField:UITextField = {
        let textField = UITextField()
        let font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 28)!
        let spacing:Double = 1.5
        textField.attributedPlaceholder = NSAttributedString(string: "(123) 456-7890", attributes: [
            .font: font,
            .foregroundColor: UIColor.telaGray7,
            .kern: spacing
        ])
        textField.defaultTextAttributes = [
            .font: font,
            .kern: spacing,
            .foregroundColor: UIColor.telaWhite
        ]
        textField.tintColor = .telaWhite
        textField.setDefault(string: "+1", withFont: font, characterSpacing: spacing, at: .Left, withRightSpacing: 6)
        textField.layer.borderColor = UIColor.telaGray5.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 12
        textField.keyboardType = UIKeyboardType.numberPad
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.textContentType = UITextContentType.telephoneNumber
        return textField
    }()
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor.telaGray5
        button.backgroundColor = UIColor.telaBlue
        button.setTitle("Start Conversation", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)
        button.layer.borderColor = UIColor.telaBlue.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 15
        button.setTitleColor(.telaWhite, for: .normal)
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
//        button.isEnabled = false
        return button
    }()
    
    
    
    
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}




extension UILabel {
  func addCharacterSpacing(kernValue: Double = 0) {
    if let labelText = text, labelText.count > 0 {
      let attributedString = NSMutableAttributedString(string: labelText)
      attributedString.addAttribute(.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
      attributedText = attributedString
    }
  }
}
