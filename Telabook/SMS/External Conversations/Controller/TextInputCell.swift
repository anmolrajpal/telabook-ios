//
//  TextInputCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class TextInputCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupViews() {
//        contentView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        contentView.addSubview(inputTextField)
    }
    fileprivate func setupConstraints() {
        inputTextField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 44)
    }
    let inputTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        textField.textColor = UIColor.telaGray7
        textField.textAlignment = .left
        textField.keyboardAppearance = .dark
        textField.borderStyle = .none
//        textField.tintColor = .telaGray7
        return textField
    }()
}
