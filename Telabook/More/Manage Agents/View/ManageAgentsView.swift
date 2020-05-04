//
//  ManageAgentsView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class ManageAgentsView: UIView {
    
    
    // MARK: Setup Views
    fileprivate func setupViews() {
        addSubview(tableView)
        addSubview(spinner)
        addSubview(placeholderLabel)
        layoutConstraints()
    }
    
    
    // MARK: Layout Methods for views
    fileprivate func layoutConstraints() {
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40).activate()
    }
    
    
    // MARK: Constructors
    
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
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
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray7
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.telaGray7
        return refreshControl
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
