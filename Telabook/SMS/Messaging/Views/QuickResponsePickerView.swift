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
        
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: tableView.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, topConstant: 200, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
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
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tv.sectionHeaderHeight = .leastNonzeroMagnitude
        tv.sectionFooterHeight = .leastNonzeroMagnitude
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70.0
        tv.separatorStyle = .none
        return tv
    }()
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.2)
        button.backgroundColor = .clear
        return button
    }()
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "You have no quick responses set. You can manage your quick responses in settings."
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        label.textColor = .telaGray7
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var manageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Manage", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)
        button.setTitleColor(.telaBlue, for: .normal)
        return button
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
