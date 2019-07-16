//
//  CallGroupsCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 16/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
protocol CallGroupsCellDelegate {
    func didToggleSwitch(forGroupWithID groupId:String)
}
class CallGroupsCell: UITableViewCell {
    var delegate:CallGroupsCellDelegate?
    var callGroup:CallGroupsCodable.Group? {
        didSet {
            guard let group = callGroup else { return }
            setupCell(group: group)
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        contentView.addSubview(groupNameLabel)
        contentView.addSubview(involvedInLabel)
        contentView.addSubview(toggleSwitch)
    }
    fileprivate func setupConstraints() {
        groupNameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: toggleSwitch.leftAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        involvedInLabel.anchor(top: groupNameLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        toggleSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).activate()
        toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).activate()
    }
    fileprivate func setupCell(group: CallGroupsCodable.Group) {
        groupNameLabel.text = group.name
        toggleSwitch.isOn = group.status == 1
    }
    
    let groupNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        label.textColor = UIColor.telaWhite
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    let involvedInLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Involved in"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        label.textColor = UIColor.telaGray6
        label.numberOfLines = 1
        return label
    }()
    lazy var toggleSwitch:UISwitch = {
        let switchButton = UISwitch()
        switchButton.tintColor = UIColor.telaGray5
        switchButton.thumbTintColor = UIColor.telaWhite
        switchButton.onTintColor = UIColor.telaBlue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.set(width: 40, height: 25)
        switchButton.addTarget(self, action: #selector(handleToggle), for: .valueChanged)
        return switchButton
    }()
    @objc fileprivate func handleToggle() {
        if let group = callGroup,
            let id = group.id,
            id != 0 {
            delegate?.didToggleSwitch(forGroupWithID: String(id))
        } else { print("Failed to unwrap call group data") }
    }
}
