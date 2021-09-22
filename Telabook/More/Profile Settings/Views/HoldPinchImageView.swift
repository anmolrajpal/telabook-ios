//
//  HoldPinchImageView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class HoldPinchImageView: UIImageView, UIGestureRecognizerDelegate {
    var isZooming = false
    var originalImageCenter:CGPoint?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: self.superview)
        }
    }
    
    @objc func pinch(sender:UIPinchGestureRecognizer) {
        
        if sender.state == .began {
            let currentScale = self.frame.size.width / self.bounds.size.width
            let newScale = currentScale*sender.scale
            
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            
            guard let view = sender.view else {return}
            
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            let currentScale = self.frame.size.width / self.bounds.size.width
            var newScale = currentScale*sender.scale
            
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
            
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            
            guard let center = self.originalImageCenter else {return}
            
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform.identity
                self.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
        
    }
    private func setupPinchGesture() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
    }
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    private func configureGestures() {
        setupPinchGesture()
        setupPanGesture()
    }
    
    private func configureImageView() {
        self.contentMode = .scaleAspectFit
    }
    
    
    
    
    
//    override init(image: UIImage?) {
//        super.init(image: image)
//        configureImageView()
//        configureGestures()
//    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureGestures()
//    }
    
    required init(image:UIImage) {
        super.init(image: image)
        configureImageView()
        configureGestures()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
