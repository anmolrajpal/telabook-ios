//
//  CallDetails+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 07/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension CallDetailsViewController {
    internal func commonInit() {
        title = "CALL DETAILS"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        configureTableView()
    }
}
