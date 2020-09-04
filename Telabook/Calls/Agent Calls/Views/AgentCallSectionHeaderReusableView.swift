//
//  AgentCallSectionHeaderReusableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class AgentCallSectionHeaderReusableView: UICollectionReusableView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.gothamMedium(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .telaYellow
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(
            .defaultHigh, for: .horizontal)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(titleLabel)
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: 5),
                titleLabel.trailingAnchor.constraint(
                    lessThanOrEqualTo: trailingAnchor,
                    constant: -5)])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(
                    equalTo: readableContentGuide.leadingAnchor),
                titleLabel.trailingAnchor.constraint(
                    lessThanOrEqualTo: readableContentGuide.trailingAnchor)
            ])
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 10),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

