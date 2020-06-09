//
//  FullImage+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension FullImageViewController {
    internal func setupTargetActions() {
        subview.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        subview.blurredEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackButton)))
    }
    @objc internal func didTapBackButton() {
        deinitAnimations { _ in self.dismiss(animated: false, completion: nil) }
    }
    
    internal func observeViewNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    internal func removeViewNotificationsObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    @objc internal func handleEnterForeground() {
        initAnimations()
    }
    internal func initAnimations() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            self.subview.alpha = 0.5
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                self.subview.alpha = 1.0
                self.subview.photoView.transform = CGAffineTransform.identity
                UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.subview.backButton.transform = CGAffineTransform.identity
                })
            })
        })
    }
    internal func deinitAnimations(callback: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.7, animations: {
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                if let rect = self.fromRect {
                    let scale = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    let translate = CGAffineTransform(translationX: -(self.subview.frame.width / 2) + (rect.origin.x * 3), y: -(self.subview.frame.height / 2) + (rect.origin.y * 1.5))
                    self.subview.photoView.transform = scale.concatenating(translate)
                } else {
                    self.subview.photoView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                }
            })
            UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                self.subview.alpha = 0
            }, completion: callback)
        }, completion: nil)
    }
}
