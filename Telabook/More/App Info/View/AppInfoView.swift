//
//  AppInfoView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/04/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class AppInfoView: UIView {
    
    fileprivate func setupViews() {
        addSubview(appNameLabel)
        addSubview(appVersionLabel)
        addSubview(logoImageView)
        addSubview(bottomLabel)
        layoutConstraints()
    }
    fileprivate func layoutConstraints() {
       appNameLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: frame.height / 5, leftConstant: 32, bottomConstant: 0, rightConstant: 32)
       appVersionLabel.anchor(top: appNameLabel.bottomAnchor, left: appNameLabel.leftAnchor, bottom: nil, right: appNameLabel.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
       logoImageView.anchor(top: appVersionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 30, leftConstant: 40, bottomConstant: 0, rightConstant: 40)
       bottomLabel.anchor(top: logoImageView.bottomAnchor, left: appVersionLabel.leftAnchor, bottom: nil, right: appVersionLabel.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    
    // MARK: Constructors
    
    lazy var appNameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaWhite
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    lazy var appVersionLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    lazy var logoImageView:UIImageView = {
        let imageView = UIImageView()
        
        let logo = Config.environment == .mzp·production ? UIImage(named: "logo·mzp") : UIImage(named: "logo")
        imageView.image = logo
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }()
    lazy var bottomLabel:UILabel = {
        let label = UILabel()
        label.text = "All rights reserved."
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 2
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
