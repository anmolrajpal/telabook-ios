//
//  KeyValueCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
extension UITableViewCell {
    static var identifier:String {
        NSStringFromClass(self)
    }
}
class KeyValueCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.detailTextLabel?.textColor = UIColor.telaGray6
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
