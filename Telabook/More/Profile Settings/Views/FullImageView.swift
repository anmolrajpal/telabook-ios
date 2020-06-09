//
//  FullImageView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//


import UIKit
enum ImageZoomMode {
    case normal, holdPinch
}
class FullImageView: UIView {
    
    
    
    fileprivate func setupViews() {
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        addSubview(blurredEffectView)
        vibrancyEffectView.contentView.addSubview(backButton)
//        addSubview(photoImageView)
//        addSubview(holdPinchImageView)
//        addSubview(normalImageView)
        addSubview(photoView)
        layoutConstraints()
    }
    fileprivate func layoutConstraints() {
        layoutBlurredEffectView()
        layoutVibrancyEffectView()
        layoutBackButton()
        layoutPhotoView()
//        layoutPhotoImageView()
//        layoutHoldPinchImageView()
//        layoutNormalImageView()
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if backButton.frame.contains(point) {
            return backButton
        } else {
            return photoView
        }
    }
    
    
    lazy var backButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)), for: .normal)
        button.tintColor = .white
        let inset:CGFloat = -5
        button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        return button
    }()
    lazy var blurredEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var vibrancyEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let view = UIVisualEffectView(effect: vibrancyEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
//    lazy var photoImageView:UIImageView = {
//        let view = UIImageView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.contentMode = .scaleAspectFit
//        view.clipsToBounds = true
//        view.isUserInteractionEnabled = true
//        return view
//    }()
    
//    let normalImageView:ImageZoomView
//    let holdPinchImageView:HoldPinchImageView
    var photoView:UIView
    
    fileprivate func layoutBlurredEffectView() {
        blurredEffectView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    fileprivate func layoutVibrancyEffectView() {
        vibrancyEffectView.anchor(top: blurredEffectView.topAnchor, left: blurredEffectView.leftAnchor, bottom: blurredEffectView.bottomAnchor, right: blurredEffectView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    fileprivate func layoutBackButton() {
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 32, heightConstant: 32)
    }
    fileprivate func layoutPhotoView() {
        photoView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
//        photoView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    }
//    fileprivate func layoutPhotoImageView() {
//        photoImageView.anchor(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: bounds.width, heightConstant: bounds.width)
//        photoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
//    }
//    fileprivate func layoutNormalImageView() {
//        normalImageView.anchor(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: bounds.width, heightConstant: bounds.width)
//        normalImageView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
//    }
//    fileprivate func layoutHoldPinchImageView() {
//        holdPinchImageView.anchor(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: bounds.width, heightConstant: bounds.width)
//        holdPinchImageView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
//    }
    
//    private func handleZoomModeState(for mode:ImageZoomMode) {
//        switch mode {
//            case .normal:
//                self.photoView = ImageZoomView(image: image)
////                self.holdPinchImageView.isHidden = true
////                self.holdPinchImageView.isUserInteractionEnabled = false
////                self.normalImageView.isHidden = false
////                self.normalImageView.isUserInteractionEnabled = true
//            case .holdPinch:
//                self.photoView = HoldPinchImageView(image: image)
////                self.normalImageView.isHidden = true
////                self.normalImageView.isUserInteractionEnabled = false
////                self.holdPinchImageView.isHidden = false
////            self.holdPinchImageView.isUserInteractionEnabled = true
//        }
//    }
    let image:UIImage
//    var zoomMode:ImageZoomMode {
//        didSet {
//            self.handleZoomModeState(for: zoomMode)
//        }
//    }
    required init(image:UIImage, zoomMode:ImageZoomMode, frame:CGRect) {
        self.image = image
        
//        self.normalImageView = ImageZoomView(image: image)
//        self.holdPinchImageView = HoldPinchImageView(image: image)
//        self.zoomMode = zoomMode
        self.photoView = zoomMode == .normal ? ImageZoomView(image: image, frame: frame) : HoldPinchImageView(image: image)
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
