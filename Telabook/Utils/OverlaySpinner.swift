//
//  OverlaySpinner.swift
//  Telabook
//
//  Created by Anmol Rajpal on 17/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

final class OverlaySpinner {
    static let shared = OverlaySpinner()
    fileprivate var containerView = UIView()
    fileprivate var progressView = UIView()
    fileprivate var activityIndicator = UIActivityIndicatorView()
    internal enum SpinnerAction {
        case Start, Stop
    }
    func spinner(mark action:SpinnerAction) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        containerView.frame = window.frame
        containerView.center = window.center
        containerView.backgroundColor = UIColor.telaGray3.withAlphaComponent(0.5)
        progressView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        progressView.center = window.center
        progressView.backgroundColor = UIColor.telaGray5.withAlphaComponent(0.4)
        progressView.layer.cornerRadius = 10
        progressView.clipsToBounds = true
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicator.style = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        UIApplication.shared.keyWindow?.addSubview(containerView)
        switch action {
        case .Start: activityIndicator.startAnimating()
        case .Stop:
            activityIndicator.stopAnimating()
            containerView.removeFromSuperview()
        }
    }
}
