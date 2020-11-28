//
//  BlacklistedDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
protocol BlacklistedDetailsDelegate {
    func unblockButton(didTapFor blockedUser:BlockedUser)
}
class BlacklistedDetailsViewController: UIViewController {
    
    var delegate:BlacklistedDetailsDelegate?
    
    lazy private(set) var subview: BlacklistedDetailsView = {
        return BlacklistedDetailsView(frame: UIScreen.main.bounds)
    }()
    
    
    let blockedUser:BlockedUser
    init(selectedBlockedUser:BlockedUser) {
        self.blockedUser = selectedBlockedUser
        super.init(nibName: nil, bundle: nil)
        let phoneNumber = blockedUser.phoneNumber ?? ""
        let number:String = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
        /*
        if let formattedPhoneNumber = phoneNumber.getE164FormattedNumber() {
            number = formattedPhoneNumber
        } else {
            number = phoneNumber
        }
        */
        let parameters = BlacklistedDetailsView.Parameters(phoneNumber: number,
                                                           blockingReason: blockedUser.blockingReason ?? "",
                                                           blocker: blockedUser.blockedBy ?? "",
                                                           date: blockedUser.updatedAt != nil ? Date.getStringFromDate(date: blockedUser.updatedAt!, dateFormat: "MMMM d, yyyy | h:mm a") : "")
        subview.parameters = parameters
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Lifecycle
    
    override func loadView() {
        super.loadView()
        view.addSubview(subview)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        subview.frame = view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    private func commonInit() {
        setupTargetActions()
    }
    private func setupTargetActions() {
        subview.cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        subview.unblockButton.addTarget(self, action: #selector(unblockButtonDidTap), for: .touchUpInside)
    }
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func unblockButtonDidTap() {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.delegate?.unblockButton(didTapFor: self.blockedUser)
            }
        }
    }
}
