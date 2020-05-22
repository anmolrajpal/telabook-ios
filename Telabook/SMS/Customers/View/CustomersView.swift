//
//  CustomersView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class CustomersView: UIView {

    
    private func setupViews() {
        addSubview(segmentedControl)
        addSubview(tableView)
        addSubview(inboxSpinner)
        addSubview(archivedSpinner)
        addSubview(inboxPlaceholderLabel)
        addSubview(archivedPlaceholderLabel)
        addSubview(refreshButton)
        layoutConstraints()
    }
    private func layoutConstraints() {
        segmentedControl.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 40)
        
        
        
        tableView.anchor(top: segmentedControl.bottomAnchor, left: segmentedControl.leftAnchor, bottom: bottomAnchor, right: segmentedControl.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        
        inboxSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        inboxSpinner.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        archivedSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        archivedSpinner.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        
        inboxPlaceholderLabel.anchor(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        inboxPlaceholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40).activate()
        
        archivedPlaceholderLabel.anchor(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        archivedPlaceholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40).activate()
        
        refreshButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 40).activate()
        refreshButton.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    }
    
    
    
    
    lazy var segmentedControl:UISegmentedControl = {
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
            ]
        let unselectedAttributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaGray7
        ]
        let control = UISegmentedControl(items: CustomersViewController.Segment.allCases.map { $0.stringValue })
        control.selectedSegmentIndex = CustomersViewController.Segment.Inbox.rawValue
        control.tintColor = .clear
        control.selectedSegmentTintColor = .telaGray6
        control.setTitleTextAttributes(attributes, for: UIControl.State.selected)
        control.setTitleTextAttributes(unselectedAttributes, for: UIControl.State.normal)
        control.backgroundColor = .telaGray3
        control.layer.cornerRadius = 0
        return control
    }()
    lazy var inboxSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var archivedSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    lazy var inboxPlaceholderLabel:UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var archivedPlaceholderLabel:UILabel = {
        let label = UILabel()
        label.text = "No Archived Conversations"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var refreshButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        return button
    }()
    
    
    
    
    // MARK: Alert Views
    lazy var reasonTextView:UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.isEditable = true
        textView.textAlignment = .left
        textView.isSelectable = true
        textView.backgroundColor = UIColor.telaGray4
        textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
        textView.textColor = UIColor.telaGray7
        textView.sizeToFit()
        textView.isScrollEnabled = true
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 7
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    lazy var characterCountLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Character limit: 70"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    
    
    
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


