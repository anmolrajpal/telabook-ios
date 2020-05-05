//
//  AutoResponseView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class AutoResponseView: UIView {
    
    
    // MARK: Setup Views
    fileprivate func setupViews() {
        addSubview(cancelButton)
        addSubview(saveButton)
        addSubview(headingLabel)
        addSubview(autoResponseSettingsHeaderView)
        addSubview(callForwardingContainerView)
        addSubview(smsAutoReplyContainerView)
        addSubview(setAutoResponseHeaderView)
        addSubview(setAutoReplyHeadingLabel)
        addSubview(autoReplyTextView)
        //  addSubview(fillerView)
        layoutConstraints()
    }
    
    
    // MARK: Layout Methods for views
    fileprivate func layoutConstraints() {
        cancelButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0)
        saveButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20)
        headingLabel.anchor(top: cancelButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        autoResponseSettingsHeaderView.anchor(top: headingLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 20)
        callForwardingContainerView.anchor(top: autoResponseSettingsHeaderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 44)
        smsAutoReplyContainerView.anchor(top: callForwardingContainerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 44)
        setAutoResponseHeaderView.anchor(top: smsAutoReplyContainerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 20)
        setAutoReplyHeadingLabel.anchor(top: setAutoResponseHeaderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        autoReplyTextView.anchor(top: setAutoReplyHeadingLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, heightConstant: 80)
        //        fillerView.anchor(top: autoReplyTextView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 60, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    
    // MARK: Constructors
    lazy var callForwardingContainerView = createCallForwardingSwitchContainerView()
    lazy var smsAutoReplyContainerView = createSmsAutoReplySwitchContainerView()
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Turn on Mobile Data or Wifi to Access Telabook"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Close", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)!,
            .foregroundColor: UIColor.telaBlue
        ]), for: .normal)
        return button
    }()
    lazy var saveButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Save", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14.0)!,
            .foregroundColor: UIColor.telaBlue
        ]), for: .normal)
        return button
    }()
    lazy var headingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Auto Response"
        label.textColor = UIColor.telaBlue
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 20)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var autoResponseSettingsHeaderView = createHeaderView(title: "Auto Response Settings")
    
    lazy var setAutoResponseHeaderView = createHeaderView(title: "Set Auto Response")
    
    lazy var setAutoReplyHeadingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Write an auto response text to send at first time"
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    lazy var callForwardingSwitch:UISwitch = {
        let switchButton = UISwitch()
        switchButton.tintColor = UIColor.telaGray5
        switchButton.thumbTintColor = UIColor.telaWhite
        switchButton.onTintColor = UIColor.telaBlue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    lazy var smsAutoReplySwitch:UISwitch = {
        let switchButton = UISwitch()
        switchButton.tintColor = UIColor.telaGray5
        switchButton.thumbTintColor = UIColor.telaWhite
        switchButton.onTintColor = UIColor.telaBlue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    lazy var autoReplyTextView:UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.textAlignment = .left
        textView.isSelectable = true
        textView.backgroundColor = UIColor.telaGray4
        textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        textView.textColor = UIColor.telaGray7
        textView.sizeToFit()
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = .all
        textView.keyboardAppearance = .dark
        textView.layer.cornerRadius = 8
        return textView
    }()
    lazy var fillerView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.telaGray3.withAlphaComponent(0.8)
        return view
    }()
    
    
    // MARK: Methods
    func createSmsAutoReplySwitchContainerView() -> UIView {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Auto Reply Message"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        containerView.addSubview(smsAutoReplySwitch)
        label.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: smsAutoReplySwitch.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        smsAutoReplySwitch.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        smsAutoReplySwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
    func createHeaderView(title:String) -> UIView {
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        label.anchor(top: nil, left: headerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        return headerView
    }
    func createCallForwardingSwitchContainerView() -> UIView {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Call Forwarding"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        containerView.addSubview(callForwardingSwitch)
        label.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: callForwardingSwitch.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        callForwardingSwitch.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        callForwardingSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
    
    // MARK: init
    
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
