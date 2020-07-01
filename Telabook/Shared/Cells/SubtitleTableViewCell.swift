//
//  SubtitleTableViewCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//


import UIKit
class SubtitleTableViewCell: UITableViewCell {
    var spacingBetweenLabels:CGFloat = 5
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.detailTextLabel?.textColor = UIColor.telaGray6
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.origin.y -= spacingBetweenLabels
        detailTextLabel?.frame.origin.y += spacingBetweenLabels
    }
}
