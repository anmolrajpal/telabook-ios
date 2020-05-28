//
//  ManageAgentsCellView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class ManageAgentsCellView: UIView {
    // MARK:: Setup Views Data
    struct Parameters:Equatable {
        let name:String
        let initials:String
        let role:AppUserRole
        let profileImageURLString:String?
        let lowPriorityCheck:Bool
        let mediumPriorityCheck:Bool
        let highPriorityCheck:Bool
    }
    var parameters: Parameters? {
        didSet {
            if oldValue != parameters {
                updateContents(resetExisting: true)
            }
        }
    }
    
    private func updateContents(resetExisting: Bool = false) {
        queue.cancelAllOperations()
        
        if resetExisting || parameters == nil {
            setupData(parameters: nil, animated: false)
        }
        
        guard let parameters = parameters else { return }
        let operation = BlockOperation()
        
        operation.addExecutionBlock() { [weak self, weak operation] in
            guard let self = self, let operation = operation, !operation.isCancelled else {
                return
            }
            DispatchQueue.main.async() {
                guard !operation.isCancelled else { return }
                
                self.setupData(parameters: parameters, animated: true)
            }
        }
        
        queue.addOperation(operation)
    }
    private func setupData(parameters:Parameters?, animated:Bool) {
        agentNameLabel.text = parameters?.name
        agentDesignationLabel.text = parameters?.role.stringValue
        if parameters?.lowPriorityCheck == true { stackView.addArrangedSubview(lowPriorityImageView) }
        if parameters?.mediumPriorityCheck == true { stackView.addArrangedSubview(mediumPriorityImageView) }
        if parameters?.highPriorityCheck == true { stackView.addArrangedSubview(highPriorityImageView) }
        if let urlStr = parameters?.profileImageURLString {
            self.profileImageView.loadImageUsingCache(with: urlStr, placeHolder: UIImage.placeholderInitialsImage(text: parameters?.initials ?? "NN"))
        } else {
            self.profileImageView.loadImageUsingCache(with: nil, placeHolder: UIImage.placeholderInitialsImage(text: parameters?.initials ?? "NN"))
        }
        guard !animated else {
            self.alpha = 0.1
            UIView.transition(with: self,
                              duration: 0.2,
                              options: [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
                                self.alpha = 1.0
            }, completion: nil)
            return
        }
    }
    
    
    
    
    // MARK: init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutConstraints()
        updateContents()
    }
//    override func updateConstraints() {
//        layoutConstraints()
//        super.updateConstraints()
//    }
    
    
    
    
    // MARK: Setup views
    fileprivate func setupViews() {
        addSubview(profileImageView)
        addSubview(containerView)
        containerView.addSubview(agentNameLabel)
        containerView.addSubview(agentDesignationLabel)
        containerView.addSubview(stackView)
    }
    
    
    
    
    // MARK: Layout Constraints
    fileprivate func layoutConstraints() {
        let imageViewHeight:CGFloat = 60
        profileImageView.anchor(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: imageViewHeight, heightConstant: imageViewHeight)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        
        containerView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10)
        
        
        agentNameLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.centerYAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 8, rightConstant: 10)
        
        agentDesignationLabel.anchor(top: containerView.centerYAnchor, left: agentNameLabel.leftAnchor, bottom: nil, right: agentNameLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).activate()
        stackView.centerYAnchor.constraint(equalTo: agentDesignationLabel.centerYAnchor).activate()
    }
    
    
    
    
    
    
    // MARK: Constructors
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var agentNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)
        return label
    }()
    lazy var agentDesignationLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12.0)
        return label
    }()
    lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = NSLayoutConstraint.Axis.horizontal
        view.alignment = UIStackView.Alignment.center
        view.distribution = UIStackView.Distribution.equalSpacing
        return view
    }()
    lazy var lowPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var mediumPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_medium_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var highPriorityImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_small_high")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
}
