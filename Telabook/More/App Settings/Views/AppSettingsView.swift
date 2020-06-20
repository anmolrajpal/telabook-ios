//
//  AppSettingsView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class AppSettingsView: UIView {
    
    
    // MARK: - Methods
    private func setupViews() {
        addSubview(tableView)
        layoutConstraints()
    }
    private func layoutConstraints() {
        tableView.fillSuperview()
    }
    
    
    
    
    // MARK: - Constructors
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    
    
    
    
    
    // MARK: - Lifecycle
    
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
