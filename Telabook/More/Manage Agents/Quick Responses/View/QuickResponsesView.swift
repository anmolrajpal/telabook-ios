//
//  QuickResponsesView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class QuickResponsesView: UIView {
    
    // MARK: Setup Views
    fileprivate func setupViews() {
        addSubview(doneButton)
        addSubview(headingLabel)
        addSubview(addResponseHeadingLabel)
        addSubview(responseTextView)
        addSubview(characterCountLabel)
        addSubview(saveResponseButton)
        addSubview(spinner)
        addSubview(manageResponsesHeaderView)
        addSubview(tableView)
        addSubview(placeholderLabel)
        layoutConstraints()
    }
    
    
    // MARK: Layout Methods for views
    fileprivate func layoutConstraints() {
        doneButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20)
        
        headingLabel.anchor(top: doneButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        
        addResponseHeadingLabel.anchor(top: headingLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        
        responseTextView.anchor(top: addResponseHeadingLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 5, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 60)
        
        characterCountLabel.anchor(top: responseTextView.bottomAnchor, left: nil, bottom: nil, right: responseTextView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        saveResponseButton.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 20).activate()
        saveResponseButton.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
        spinner.centerXAnchor.constraint(equalTo: saveResponseButton.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: saveResponseButton.centerYAnchor).activate()
        
        manageResponsesHeaderView.anchor(top: saveResponseButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
        tableView.anchor(top: manageResponsesHeaderView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        placeholderLabel.anchor(top: manageResponsesHeaderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 100, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
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
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Turn on Mobile Data or Wifi to Access Telabook"
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var doneButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setAttributedTitle(NSAttributedString(string: "Done", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14.0)!,
            .foregroundColor: UIColor.telaBlue
        ]), for: .normal)
        return button
    }()
    
    lazy var headingLabel:UILabel = {
        let label = UILabel()
        label.text = "Quick Responses"
        label.textColor = UIColor.telaBlue
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 20)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    lazy var addResponseHeadingLabel:UILabel = {
        let label = UILabel()
        label.text = "Write a quick response and add into the template"
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    lazy var responseTextView:UITextView = {
        let textView = UITextView()
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
        return textView
    }()
    lazy var characterCountLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Max Character: 70"
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    lazy var saveResponseButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Add", for: UIControl.State.normal)
        button.setTitleColor(.telaGray5, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.isEnabled = false
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.telaGray6
        button.clipsToBounds = true
        return button
    }()
    lazy var manageResponsesHeaderView = createHeaderView(title: "Manage Quick Responses")
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    private func createHeaderView(title:String) -> UIView {
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
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
    
    
    
    
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        responseTextView.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension QuickResponsesView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textCount = textView.text.count
        saveResponseButton.isEnabled = textCount > 0
        saveResponseButton.backgroundColor = textCount > 0 ? .telaBlue : .telaGray6
        characterCountLabel.text = "Charaters left: \(70 - textCount)"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 70
    }
}
