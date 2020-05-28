//
//  BlacklistCellView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class BlacklistCellView: UIView {
    // MARK:: Setup Views Data
    struct Parameters:Equatable {
        let phoneNumber:String
        let date:String
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
        phoneNumberLabel.text = parameters?.phoneNumber
        dateLabel.text = parameters?.date
        
        guard !animated else {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 1.0)
            UIView.transition(with: self,
                              duration: 0.3,
                              options: [.curveLinear, .beginFromCurrentState, .allowUserInteraction],
                              animations: {
                                self.transform = .identity
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
    
    
    
    // MARK: init
    fileprivate func setupViews() {
        addSubview(phoneNumberLabel)
        addSubview(dateLabel)
    }
    
    
    
    
    // MARK: Layout Constraints
    fileprivate func layoutConstraints() {
        phoneNumberLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 14, leftConstant: 24, bottomConstant: 0, rightConstant: 24)
        dateLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 24, bottomConstant: 14, rightConstant: 24)
    }
    
    
    
    
    
    
    // MARK: Constructors
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    lazy private var phoneNumberLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.telaBlue
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13.0)
        return label
    }()
    lazy private var dateLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12.0)
        return label
    }()
}
