//
//  ConversationGallery+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ConversationGalleryController {
    
    internal func commonInit() {
        title = "Conversation Gallery"
        configureNavigationBarAppearance()
        configureNavigationBarItems()
        configureHierarchy()
        configureCollectionView()
    }
    private func configureNavigationBarItems() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTap))
        doneButton.tintColor = .telaBlue
        navigationItem.rightBarButtonItems = [doneButton]
    }
    @objc
    private func doneButtonDidTap() {
        delegate == nil ? dismiss(animated: true) : delegate?.conversationGalleryController(controller: self, didFinishCancelled: true)
    }
    private func configureHierarchy() {
        view.backgroundColor = .telaGray1
        view.addSubview(collectionView)
        view.addSubview(spinner)
        view.addSubview(placeholderLabel)
        layoutConstraints()
    }
    private func layoutConstraints() {
        collectionView.fillSuperview()
        spinner.centerInSuperview()
        placeholderLabel.anchor(top: spinner.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 15, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
    }
}
