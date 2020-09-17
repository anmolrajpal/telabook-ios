//
//  CallDetailsMetaDetailsCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 08/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class CallDetailsMetaDetailsCell: UITableViewCell {
    
    
    
    func configureCell(with callDetails: AgentCallProperties) {
        if let date = callDetails.timestampDate {
            let dateString = Date.getStringFromDate(date: date, dateFormat: .dMMMMyyyy)
            dateLabel.text = dateString
            
            let timeString = Date.getStringFromDate(date: date, dateFormat: .hmma)
            timeLabel.text = timeString
        }
        
        
        callStatusImageView.tintColor = callDetails.callStatus.tintColor
        
        callStatusLabel.text = callDetails.callStatus.displayValue
        
        durationLabel.text = (callDetails.duration ?? "--") + " seconds"
    }
    
    
    lazy var dateLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    lazy var callStatusImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = SFSymbol.arrow·down·left.image(withSymbolConfiguration: .init(textStyle: .caption1)).withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var callStatusLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var durationLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray7
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private func configureHierarchy() {
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(callStatusImageView)
        addSubview(callStatusLabel)
        addSubview(durationLabel)
        
        layoutConstraints()
    }
    private func layoutConstraints() {
        dateLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 16, leftConstant: 22, bottomConstant: 0, rightConstant: 22)
        
        timeLabel.anchor(top: dateLabel.bottomAnchor, left: dateLabel.leftAnchor, bottom: nil, right: nil, topConstant: 14, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        callStatusImageView.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 30).activate()
        callStatusImageView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).activate()
        
        callStatusLabel.leftAnchor.constraint(equalTo: callStatusImageView.rightAnchor, constant: 3).activate()
//        callStatusLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).activate()
        callStatusLabel.centerYAnchor.constraint(equalTo: callStatusImageView.centerYAnchor).activate()
        
        durationLabel.anchor(top: callStatusImageView.bottomAnchor, left: callStatusImageView.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 16, rightConstant: 22)
        
    }
    
    
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
