//
//  BlacklistedDetailsView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class BlacklistedDetailsView: UIView {
    // MARK: setup data
    struct Parameters:Equatable {
        let phoneNumber:String
        let blockingReason:String
        let blocker:String
        let date:String
    }
    var parameters: Parameters? {
        didSet {
            guard let parameters = parameters else { return }
            setupData(parameters: parameters)
        }
    }
    private func setupData(parameters:Parameters) {
        numberValueLabel.text = parameters.phoneNumber
        reasonValueLabel.text = parameters.blockingReason
        blockerValueLabel.text = parameters.blocker
        dateValueLabel.text = parameters.date
    }
    
    
    
    // MARK: init
    private func setupViews() {
        backgroundColor = .clear
        addSubview(blurredEffectView)
        addSubview(cancelButton)
        addSubview(headingLabel)
        addSubview(numberHeadingLabel)
        addSubview(numberValueLabel)
        addSubview(reasonHeadingLabel)
        addSubview(reasonValueLabel)
        addSubview(blockerHeadingLabel)
        addSubview(blockerValueLabel)
        addSubview(dateHeadingLabel)
        addSubview(dateValueLabel)
        addSubview(unblockButton)
        layoutConstraints()
    }
    private func layoutConstraints() {
        blurredEffectView.frame = bounds
        
        
        cancelButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 30, heightConstant: 30)
        
        
        headingLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).activate()
        headingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
        
        let leftGuideAnchor = safeAreaLayoutGuide.leftAnchor
        let rightGuideAnchor = safeAreaLayoutGuide.rightAnchor
        
        let headingLabelXMargin:CGFloat = 30
        let valueLabelXMargin:CGFloat = 26
        let headingValueSpacing:CGFloat = 8
        let spacing:CGFloat = 24
        
        
        numberHeadingLabel.anchor(top: headingLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: 40, leftConstant: headingLabelXMargin, bottomConstant: 0, rightConstant: headingLabelXMargin)
        numberValueLabel.anchor(top: numberHeadingLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: headingValueSpacing, leftConstant: valueLabelXMargin, bottomConstant: 0, rightConstant: valueLabelXMargin)
        
        
        reasonHeadingLabel.anchor(top: numberValueLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: spacing, leftConstant: headingLabelXMargin, bottomConstant: 0, rightConstant: headingLabelXMargin)
        reasonValueLabel.anchor(top: reasonHeadingLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: headingValueSpacing, leftConstant: valueLabelXMargin, bottomConstant: 0, rightConstant: valueLabelXMargin)
        
        
        
        blockerHeadingLabel.anchor(top: reasonValueLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: spacing, leftConstant: headingLabelXMargin, bottomConstant: 0, rightConstant: headingLabelXMargin)
        blockerValueLabel.anchor(top: blockerHeadingLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: headingValueSpacing, leftConstant: valueLabelXMargin, bottomConstant: 0, rightConstant: valueLabelXMargin)
        
        
        
        
        dateHeadingLabel.anchor(top: blockerValueLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: spacing, leftConstant: headingLabelXMargin, bottomConstant: 0, rightConstant: headingLabelXMargin)
        dateValueLabel.anchor(top: dateHeadingLabel.bottomAnchor, left: leftGuideAnchor, bottom: nil, right: rightGuideAnchor, topConstant: headingValueSpacing, leftConstant: valueLabelXMargin, bottomConstant: 0, rightConstant: valueLabelXMargin)
        
        
        unblockButton.topAnchor.constraint(equalTo: dateValueLabel.bottomAnchor, constant: 35).activate()
        unblockButton.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
    }
    
    
    // MARK: Constructors
    private lazy var blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.2)
        return button
    }()
    lazy var headingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "DETAILS"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 24)
        label.textColor = .telaBlue
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    
    private lazy var numberHeadingLabel = headingLabel(text: "Phone Number")
    private lazy var reasonHeadingLabel = headingLabel(text: "Blocking Reason")
    private lazy var blockerHeadingLabel = headingLabel(text: "Blocked By")
    private lazy var dateHeadingLabel = headingLabel(text: "Date")
    
    private lazy var numberValueLabel = valueLabel()
    private lazy var reasonValueLabel = valueLabel()
    private lazy var blockerValueLabel = valueLabel()
    private lazy var dateValueLabel = valueLabel()
    
    lazy var unblockButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.telaBlue
        button.setTitle("UNBLOCK", for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)!
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: Helpers
    
    private func valueLabel() -> UILabel {
        let label = InsetLabel(15, 15, 12, 12)
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        label.textColor = UIColor.telaGray7
        label.backgroundColor = UIColor.telaGray5
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }
    private func headingLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 11)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    
    
    
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
