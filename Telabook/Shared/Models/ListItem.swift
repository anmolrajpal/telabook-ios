//
//  ListItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

typealias ListItemHandler = (ListItem) -> Void
struct ListItem: Hashable {
    let title:String
    let subtitle:String?
    let isSelected:Bool
    let isDisabled:Bool
    let identifier:UUID
    private(set) var handler:ListItemHandler
    
    init(identifier:UUID = UUID(), title:String, subtitle:String? = nil, isSelected:Bool = false, isDisabled:Bool = false, handler: @escaping ListItemHandler) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.handler = handler
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
