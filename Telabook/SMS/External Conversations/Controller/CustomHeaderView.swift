//
//  CustomHeaderView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class CustomHeaderView: UITableViewHeaderFooterView {
    var headerTitle:String? {
        didSet {
            headerLabel.text = headerTitle ?? ""
        }
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let headerLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    fileprivate func setupViews() {
        contentView.backgroundColor = UIColor.telaGray4
        contentView.addSubview(headerLabel)
    }
    fileprivate func setupConstraints() {
        headerLabel.anchor(top: nil, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
