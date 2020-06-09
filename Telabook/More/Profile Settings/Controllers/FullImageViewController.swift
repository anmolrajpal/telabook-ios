//
//  FullImageViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit


class FullImageViewController:UIViewController {
    
    typealias this = FullImageViewController
    private(set) var subview: FullImageView
    var fromRect:CGRect?
    
    
    required init(image:UIImage) {
        subview = FullImageView(image: image, zoomMode: .normal, frame: UIScreen.main.bounds)
        super.init(nibName: nil, bundle: nil)
    }
    convenience init(image:UIImage, fromRect:CGRect) {
        self.init(image:image)
        self.fromRect = fromRect
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        removeViewNotificationsObservers()
    }
    
    override func loadView() {
        view = subview
        subview.backgroundColor = .clear
        subview.alpha = 0.5
        self.subview.backButton.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi * 3)).scaledBy(x: 0.01, y: 0.01)
//        self.subview.backButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//        self.subview.holdPinchImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//        self.subview.normalImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        if let rect = fromRect  {
            print(rect)
            let scale = CGAffineTransform(scaleX: (rect.maxX - rect.minX) / subview.frame.width, y: (rect.maxY - rect.minY) / subview.frame.width)
            let translate = CGAffineTransform(translationX: -(subview.frame.width / 2) + (rect.origin.x * 3), y: -(subview.frame.height / 2) + (rect.origin.y * 1.5))
            self.subview.photoView.transform = scale.concatenating(translate)
            
        } else {
            self.subview.photoView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
        
        
//        self.subview.photoView.transform = CGAffineTransform(translationX: 100, y: 100)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initAnimations()
        setupTargetActions()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeViewNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeViewNotificationsObservers()
    }
  
    
}
