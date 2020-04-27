//
//  SelectCompanyView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/04/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class SelectCompanyView: UIView {
    
    fileprivate func setupViews() {
        addSubview(spinner)
        addSubview(titleLabel)
        addSubview(companiesTableView)
        addSubview(selectButton)
        layoutConstraints()
    }
    fileprivate func layoutConstraints() {
        layoutSpinner()
        layoutCompaniesTableView()
        layoutTitleLabel()
        layoutSelectButton()
    }
    
    
    // MARK: Layout Methods for views
    
    fileprivate func layoutSpinner() {
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    }
    fileprivate func layoutTitleLabel() {
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: companiesTableView.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 22, bottomConstant: 24, rightConstant: 22)
    }
    fileprivate func layoutCompaniesTableView() {
        companiesTableView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: frame.width / 10, bottomConstant: 0, rightConstant: frame.width / 10, heightConstant: frame.height / 3.5)
        companiesTableView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    }
    fileprivate func layoutSelectButton() {
        selectButton.anchor(top: nil, left: companiesTableView.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: companiesTableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, heightConstant: 50)
    }
    
    
    // MARK: Constructors
    
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray6
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.text = "SELECT A COMPANY"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 24)
        label.textColor = UIColor.telaBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    lazy var companiesTableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.telaBlue.cgColor
        tableView.layer.cornerRadius = 7
        tableView.bounces = true
        tableView.alwaysBounceVertical = true
        tableView.clipsToBounds = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.isHidden = true
        return tableView
    }()
    lazy var selectButton:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.telaBlue
        button.setTitle("SELECT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 18)
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        return button
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
