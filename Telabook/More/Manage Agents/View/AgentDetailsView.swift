//
//  AgentDetailsView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

class AgentDetailsView: UIView {
    // MARK: Setup View Data
    struct Parameters:Equatable {
        let name:String
        let initials:String
        let profileImageURLString:String?
        let designation:AppUserRole
    }
    var parameters: Parameters? {
        didSet {
            setupViewData(withParameters: parameters)
        }
    }
    private func setupViewData(withParameters parameters:Parameters?) {
        agentNameLabel.text = parameters?.name
        agentDesignationLabel.text = parameters?.designation.stringValue
        if let urlStr = parameters?.profileImageURLString {
            self.profileImageView.loadImageUsingCache(with: urlStr, placeHolder: UIImage.placeholderInitialsImage(text: parameters?.initials ?? "NN"))
        } else {
            self.profileImageView.loadImageUsingCache(with: nil, placeHolder: UIImage.placeholderInitialsImage(text: parameters?.initials ?? "NN"))
        }
    }
    
    
    
    
    // MARK: Setup Views
    fileprivate func setupViews() {
        addSubview(profileImageView)
        addSubview(agentNameLabel)
        addSubview(agentDesignationLabel)
        addSubview(responsesHeaderView)
        addSubview(stackView)
        addSubview(galleryHeaderView)
        layoutConstraints()
    }
    
    
    // MARK: Layout Methods for views
    fileprivate func layoutConstraints() {
        profileImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 100)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        agentNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        agentDesignationLabel.anchor(top: agentNameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        responsesHeaderView.anchor(top: agentDesignationLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        stackView.anchor(top: responsesHeaderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 25, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        galleryHeaderView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
    }
    
    
    // MARK: Constructors
    let buttonInsets:UIEdgeInsets = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
    let buttonSelectedColor = UIColor.telaBlue.withAlphaComponent(0.4)
    let buttonUnselectedColor = UIColor.telaGray5.withAlphaComponent(0.4)
    
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var agentNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)
        return label
    }()
    lazy var agentDesignationLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14.0)
        return label
    }()
    lazy var responsesHeaderView = createHeaderView(title: "Set Auto Responses")
    
    lazy var firstTimeSMSButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "automsg_icon"), text: "First Time SMS", textColor: .telaBlue).withRenderingMode(.alwaysOriginal), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = buttonInsets
        
        button.layer.cornerRadius = 7
        button.backgroundColor = buttonUnselectedColor
        button.clipsToBounds = true
        
        button.addAction(for: UIControl.Event.touchDragOutside, {
            button.backgroundColor = self.buttonUnselectedColor
        })
        button.addAction(for: UIControl.Event.touchDown, {
            button.backgroundColor = self.buttonSelectedColor
        })
        button.addAction(for: UIControl.Event.touchUpInside, {
            button.backgroundColor = self.buttonUnselectedColor
        })
        return button
    }()
    lazy var quickResponsesButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "autoresponse_icon"), text: "Quick Responses", textColor: .telaBlue).withRenderingMode(.alwaysOriginal), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = buttonInsets
        
        button.layer.cornerRadius = 7
        button.backgroundColor = buttonUnselectedColor
        button.clipsToBounds = true
        
        button.addAction(for: UIControl.Event.touchDragOutside, {
            button.backgroundColor = self.buttonUnselectedColor
        })
        button.addAction(for: UIControl.Event.touchDown, {
            button.backgroundColor = self.buttonSelectedColor
        })
        button.addAction(for: UIControl.Event.touchUpInside, {
            button.backgroundColor = self.buttonUnselectedColor
        })
        return button
    }()
    lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.alignment = UIStackView.Alignment.center
        view.distribution = UIStackView.Distribution.fillEqually
        view.spacing = 20
        view.addArrangedSubview(self.firstTimeSMSButton)
        view.addArrangedSubview(self.quickResponsesButton)
        return view
    }()
    lazy var galleryHeaderView = createHeaderView(title: "Gallery")
    
    
    
    /// Creates the Header View with specified title
    /// - Parameter title: The title of the header
    /// - Returns: Header View with Title
    func createHeaderView(title:String) -> UIView {
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        label.anchor(top: nil, left: headerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        return headerView
    }
    
    
    
    // MARK: common init
    
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
