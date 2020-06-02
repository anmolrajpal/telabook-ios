//
//  QuickResponsePickerView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 31/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class QuickResponsePickerView:UIView {
    
    // MARK: - init
    private func commonInit() {
        backgroundColor = .clear
        
        addSubview(blurredEffectView)
        blurredEffectView.frame = bounds
        
        
        addSubview(tableView)
        tableView.frame = bounds
    }
    
    
    
    // MARK: - Constructors
    private lazy var blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = false
        tv.tableFooterView = UIView(frame: CGRect.zero)
        tv.contentInset = UIEdgeInsets(top: 35, left: 0, bottom: 24, right: 0)
        tv.sectionHeaderHeight = .leastNonzeroMagnitude
        tv.sectionFooterHeight = .leastNonzeroMagnitude
        tv.rowHeight = 50.0
        tv.separatorStyle = .none
        return tv
    }()
    
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
//        blurredEffectView.frame = bounds
    }
}
