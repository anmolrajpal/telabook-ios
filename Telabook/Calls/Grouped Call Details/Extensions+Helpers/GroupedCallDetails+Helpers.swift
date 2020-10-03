//
//  GroupedCallDetails+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 05/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension GroupedCallDetailsViewController {
    
    // MARK: - Common setup
    
    internal func commonInit() {
        title = "CALLS"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        configureTableView()
        configureDataSource()
        updateUI()
    }
}
