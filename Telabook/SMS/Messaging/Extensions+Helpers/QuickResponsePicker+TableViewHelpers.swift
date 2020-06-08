//
//  QuickResponsePicker+TableViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 31/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit




extension QuickResponsePickerController {
    internal func commonInit() {
        setupTableView()
//        setUpNavBar()
        
        configureNavBarAppearance()
        setupNavBarItems()
        handleViewState()
    }
    private func handleViewState() {
        subview.placeholderLabel.isHidden = !quickResponses.isEmpty
    }
    private func configureNavBarAppearance() {
        if let navigationBar = navigationController?.navigationBar {
            
            let transparentAppearance = UINavigationBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            navigationBar.scrollEdgeAppearance = transparentAppearance
            
            let defaultAppearance = UINavigationBarAppearance()
            defaultAppearance.configureWithDefaultBackground()
            
            navigationBar.standardAppearance = defaultAppearance
            navigationBar.compactAppearance = defaultAppearance

            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    private func setupNavBarItems() {
        let manageButton = UIBarButtonItem(title: "Manage", style: UIBarButtonItem.Style.plain, target: self, action: #selector(manageButtonDidTap))
        manageButton.setTitleTextAttributes([
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
            .foregroundColor: UIColor.telaBlue
        ], for: .normal)
        manageButton.setBackgroundVerticalPositionAdjustment(-10, for: .default)
        navigationItem.leftBarButtonItems = [manageButton]
        
        let cancelButtonImage = SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)).image(scaledTo: .init(width: 28, height: 28))
        let cancelButton = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: self, action: #selector(cancelButtonDidTap))
        cancelButton.tintColor = UIColor.white.withAlphaComponent(0.2)
        navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    @objc
    private func cancelButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func manageButtonDidTap() {
        self.dismiss(animated: true) {
            self.delegate?.manageButtonDidTap()
        }
//        let vc = QuickResponsesViewController(userID: Int(agent.userID), agent: agent)
//        navigationController?.pushViewController(vc, animated: true)
    }
}
