//
//  AgentDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class AgentDetailsViewController: UIViewController {
 
    let agentDetails:InternalConversationsCodable
    init(agentDetails:InternalConversationsCodable) {
        self.agentDetails = agentDetails
        super.init(nibName: nil, bundle: nil)
        self.setupAgentDetails(details: agentDetails)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Agent Details"
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(agentNameLabel)
        view.addSubview(agentDesignationLabel)
        view.addSubview(responsesHeaderView)
        view.addSubview(stackView)
        view.addSubview(galleryHeaderView)
    }
    func setupConstraints() {
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 100)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        agentNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        agentDesignationLabel.anchor(top: agentNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        responsesHeaderView.anchor(top: agentDesignationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        stackView.anchor(top: responsesHeaderView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 25, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        galleryHeaderView.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
    }
    func setupAgentDetails(details:InternalConversationsCodable) {
        if let name = details.personName {
            self.agentNameLabel.text = name
            let initials = CustomUtils.shared.getInitials(from: name)
            self.profileImageView.loadImageUsingCacheWithURLString(details.profileImageUrl, placeHolder: UIImage.placeholderInitialsImage(text: initials))
        }
        if let roleId = details.roleId {
            let designation = UserRole.getRole(by: roleId)
            self.agentDesignationLabel.text = String(describing: designation)
        }
    }
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    let agentNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)
        return label
    }()
    let agentDesignationLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14.0)
        return label
    }()
    static let buttonInsets:UIEdgeInsets = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
    static let buttonSelectedColor = UIColor.telaBlue.withAlphaComponent(0.4)
    static let buttonUnselectedColor = UIColor.telaGray5.withAlphaComponent(0.4)
    let responsesHeaderView = createHeaderView(title: "Set Auto Responses")
    let firstTimeSMSButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "automsg_icon"), text: "First Time SMS", textColor: .telaBlue).withRenderingMode(.alwaysOriginal), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = buttonInsets
        
        button.layer.cornerRadius = 7
        button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(smsButtonTapped), for: .touchUpInside)
        button.addAction(for: UIControl.Event.touchDragOutside, {
            button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
        })
        button.addAction(for: UIControl.Event.touchDown, {
            button.backgroundColor = AgentDetailsViewController.buttonSelectedColor
        })
        button.addAction(for: UIControl.Event.touchUpInside, {
            button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
        })
        return button
    }()
    @objc func smsButtonTapped() {
        
    }
    let quickResponsesButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "autoresponse_icon"), text: "Quick Responses", textColor: .telaBlue).withRenderingMode(.alwaysOriginal), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = buttonInsets
        
        button.layer.cornerRadius = 7
        button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(quickResponsesButtonTapped), for: .touchUpInside)
        button.addAction(for: UIControl.Event.touchDragOutside, {
            button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
        })
        button.addAction(for: UIControl.Event.touchDown, {
            button.backgroundColor = AgentDetailsViewController.buttonSelectedColor
        })
        button.addAction(for: UIControl.Event.touchUpInside, {
            button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
        })
        return button
    }()
    @objc func quickResponsesButtonTapped() {
        if let userId = self.agentDetails.userId {
            print("User ID => \(userId)")
            let vc = QuickResponsesViewController(userId: String(userId))
            vc.modalPresentationStyle = .overFullScreen
            vc.view.backgroundColor = .telaGray1
            present(vc, animated: true, completion: nil)
        } else {
            fatalError("User ID not found")
        }
    }
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
    let galleryHeaderView = createHeaderView(title: "Gallery")
    static func createHeaderView(title:String) -> UIView {
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
}
