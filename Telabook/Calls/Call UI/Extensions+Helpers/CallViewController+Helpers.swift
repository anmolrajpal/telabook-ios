//
//  CallViewController+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 03/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import linphonesw
import CallKit

extension CallViewController {
    
    
  
    
    func commonInit() {
        view.layer.masksToBounds = true // to enable corner radius
        center = view.center
        configureHierarchy()
        configureTargetActions()
        configureGestureRecognizers()
        
    }
    
    private func configureTargetActions() {
        backButton.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(didTapDeclineButton(_:)), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(didTapAcceptButton(_:)), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(didTapMuteButton(_:)), for: .touchUpInside)
        keypadButton.addTarget(self, action: #selector(didTapKeypadButton(_:)), for: .touchUpInside)
        audioSourceButton.addTarget(self, action: #selector(didTapAudioSourceButton(_:)), for: .touchUpInside)
        hangupButton.addTarget(self, action: #selector(didTapHangupButton(_:)), for: .touchUpInside)
    }
    private func configureGestureRecognizers() {
        let dragndrop = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        dragndrop.minimumNumberOfTouches = 1
        view.addGestureRecognizer(dragndrop)
    }
    
    
    @objc
    private func didTapMuteButton(_ sender: UIButton) {
        print("### \(#function)")
        linphoneCore.micEnabled = false
    }
    @objc
    private func didTapKeypadButton(_ sender: UIButton) {
        print("### \(#function)")
    }
    @objc
    private func didTapAudioSourceButton(_ sender: UIButton) {
        print("### \(#function)")
    }
    @objc
    private func didTapHangupButton(_ sender: UIButton) {
        print("### \(#function)")
        callDescriptionLabel.text = "Ending..."
        setConnectedCallButtons(enabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            CallManager.instance().terminateCall(call: call.getCobject)
        }
//        DispatchQueue.main.async { [self] in
//            dismiss(animated: false) {
//
//            }
//        }
    }
    @objc
    private func didTapAcceptButton(_ sender: UIButton) {
        print("### \(#function)")
        callDescriptionLabel.text = "Connecting..."
        setIncomingCallButtons(enabled: false)
        
        CallManager.instance().acceptCallKitCall(call: call)
        
//        CallManager.instance().acceptCall(call: call, hasVideo: false)
        
    }
    @objc
    private func didTapDeclineButton(_ sender: UIButton) {
        print("### \(#function)")
        callDescriptionLabel.text = "Ending..."
        setIncomingCallButtons(enabled: false)
        
        CallManager.instance().endCallKitCall(call: call)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
//            CallManager.instance().terminateCall(call: call.getCobject)
//        }
    }
    @objc
    private func didTapBackButton(_ sender: UIButton) {
        print("### \(#function)")
        dismissAnimated()
    }
    /*
    // MARK: - Linphone methods to move view preview converted from obj-c to swift. Not using these anymore because it's ugly and I found something a lot better.
    @objc
    func movePreview(_ dragndrop: UIPanGestureRecognizer?) {
        guard let center = dragndrop?.location(in: view.superview) else {
            print("### \(#function) - Failed to unwrap pan gesture recognizer")
            fatalError()
        }
        view.center = center
        if dragndrop?.state == .ended {
            previewTouchLift()
        }
    }
    func coerce(_ value: CGFloat, betweenMin min: CGFloat, andMax max: CGFloat) -> CGFloat {
        return CGFloat.maximum(min, CGFloat.minimum(value, max))
    }
    func previewTouchLift() {
        var previewFrame = view.frame
        previewFrame.origin.x = coerce(previewFrame.origin.x, betweenMin: 0, andMax: (UIScreen.main.bounds.size.width - previewFrame.size.width))
        previewFrame.origin.y = coerce(previewFrame.origin.y, betweenMin: 0, andMax: (UIScreen.main.bounds.size.height - previewFrame.size.height))
        
        if !previewFrame.equalTo(view.frame) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = previewFrame
                })
            })
        }
    }
    */
    /*
    // MARK: - Optional method to scale view
    private func prepareForScaling() {
        self.center = self.view.center //we set the center of our CS to equal the center of the VC's view
        let frame = self.view.frame
        //the furthest distance in the CS is the diagonal, and we calculate it using pythagoras theorem
        self.maxLengthToCenter = (frame.width*frame.width + frame.height*frame.height).squareRoot()
    }
    private func scaledSize(for location: CGPoint) -> CGSize {
        let maxSize = UIScreen.main.bounds
        //calculate location x,y differences from the center
        let xDifference = location.x - self.center.x
        let yDifference = location.y - self.center.y

        //calculate the scale factor - note that this factor will be between 0.0(center) and 0.5(diagonal - furthest point)
        //It is due our measurement - from center to view's edge. Consider multiplying this factor with your custom constant.
        let scaleFactor = (xDifference*xDifference + yDifference*yDifference).squareRoot() / maxLengthToCenter
        //create scaled size with maxSize and current scale factor
        let scaledSize = CGSize.init(width: maxSize.width*(1-scaleFactor), height: maxSize.height*(1-scaleFactor))

        return scaledSize
    }
    */
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: view)
        guard let gestureView = gesture.view else {
            fatalError()
        }
        let newX = gestureView.center.x + translation.x
        let newY = gestureView.center.y + translation.y
        guard newY > center.y else {
            if gesture.state == .ended {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        gestureView.transform = CGAffineTransform.identity
                        gestureView.center = self.center
                        gestureView.alpha = 1.0
                        gestureView.layer.cornerRadius = 0
                    }
                }
            }
            return
        }
        
        gestureView.center = CGPoint(x: newX, y: newY)
    
        gesture.setTranslation(.zero, in: view.superview)
        
        let percentage = center.y / newY
        let safePercentage = min(percentage, 1.0)
        let scale = CGAffineTransform(scaleX: safePercentage, y: safePercentage)
        
        gestureView.transform = scale
        gestureView.alpha = safePercentage
        let cornerRadius = (1 - safePercentage) * 200
        gestureView.layer.cornerRadius = cornerRadius
        
        guard gesture.state == .ended else {
            return
        }
        
        
        let thresholdY = center.y + 200
        
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 700
        
        let slideFactor = 0.1 * slideMultiplier
        
        var finalPoint = CGPoint(
            x: view.center.x + (velocity.x * slideFactor),
            y: view.center.y + (velocity.y * slideFactor)
        )
        
        finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
        finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)
        
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            gestureView.center = finalPoint
        }) { [self] _ in
            if finalPoint.y < thresholdY {
                    UIView.animate(withDuration: 0.3, animations: {
                        gestureView.transform = CGAffineTransform.identity
                        gestureView.center = center
                        gestureView.alpha = 1.0
                        gestureView.layer.cornerRadius = 0
                    })
            } else {
                dismissAnimated()
            }
        }
        
    }
    func dismissAnimated(animated: Bool = true, dismissCompletionHandler: (() -> Void)? = nil) {
        if animated {
            runDismissAnimation { [self] _ in
                dismiss(animated: false, completion: dismissCompletionHandler)
            }
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: dismissCompletionHandler)
            }
        }
    }
    func runDismissAnimation(callback: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async { [self] in
            UIView.animate(withDuration: 0.2, animations: {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    let scale = CGAffineTransform(scaleX: 0.01, y: 0.01)
//                    let translate = CGAffineTransform(translationX: 0, y: -(view.frame.height - 40))
                    view.transform = scale
                })
                UIView.animate(withDuration: 0.2, delay: 0, animations: {
                    view.alpha = 0
                }, completion: callback)
            }, completion: nil)
        }
    }
    func showIncomingCallViews(animated: Bool) {
        setIncomingCallButtons(enabled: true)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.showHideTransitionViews) { [self] in
                incomingCallStackView.alpha = 1
            }
        }
    }
    func showConnectedCallViews(animated: Bool) {
        setConnectedCallButtons(enabled: true)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.showHideTransitionViews) { [self] in
                connectedCallStackView.alpha = 1
                hangupButton.alpha = 1
            }
        }
    }
    func hideIncomingCallViews(animated: Bool) {
        setIncomingCallButtons(enabled: false)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.showHideTransitionViews) { [self] in
                incomingCallStackView.alpha = 0
            }
        }
    }
    func hideConnectedCallViews(animated: Bool) {
        setConnectedCallButtons(enabled: false)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.showHideTransitionViews) { [self] in
                connectedCallStackView.alpha = 0
                hangupButton.alpha = 0
            }
        }
    }
    
    func setIncomingCallButtons(enabled: Bool) {
        acceptButton.isEnabled = enabled
        declineButton.isEnabled = enabled
    }
    func setConnectedCallButtons(enabled: Bool) {
        muteButton.isEnabled = enabled
        keypadButton.isEnabled = enabled
        audioSourceButton.isEnabled = enabled
        hangupButton.isEnabled = enabled
    }
    
    
    @objc
    func updateCallDuration() {        
        if let call = linphoneCore.currentCall {
            let duration = call.duration
            if duration > 0 {
                callDescriptionLabel.text = Date.getElapsedTimeFormattedString(fromSecondsPassed: duration)
            }
        }
    }
    
    
    
    
    
    
    func layoutButtons() {
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2.0
        declineButton.layer.cornerRadius = declineButton.frame.height / 2.0
        
        muteButton.layer.cornerRadius = muteButton.frame.height / 2.0
        keypadButton.layer.cornerRadius = keypadButton.frame.height / 2.0
        audioSourceButton.layer.cornerRadius = audioSourceButton.frame.height / 2.0
        hangupButton.layer.cornerRadius = hangupButton.frame.height / 2.0
    }
    private func configureHierarchy() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurredEffectView)
        
        view.addSubview(backButton)
        
        view.addSubview(logoImageView)
        view.addSubview(callerIdLabel)
        view.addSubview(callDescriptionLabel)
        
        
        declineCallContainerView.addSubview(declineButton)
        declineCallContainerView.addSubview(declineLabel)
        
        acceptCallContainerView.addSubview(acceptButton)
        acceptCallContainerView.addSubview(acceptLabel)
        
        incomingCallStackView.addArrangedSubview(declineCallContainerView)
        incomingCallStackView.addArrangedSubview(acceptCallContainerView)
        
        view.addSubview(incomingCallStackView)
        configureConnectedCallStackViewHierarchy()
        view.addSubview(connectedCallStackView)
        view.addSubview(hangupButton)
        layoutConstraints()
    }
    
    private func layoutConstraints() {
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        
        backgroundImageView.fillSuperview()
        blurredEffectView.fillSuperview()
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 22, leftConstant: 22, bottomConstant: 0, rightConstant: 0)
        
        callDescriptionLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.centerYAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 40, rightConstant: 20)
        callerIdLabel.anchor(top: nil, left: callDescriptionLabel.leftAnchor, bottom: callDescriptionLabel.topAnchor, right: callDescriptionLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0)
        let logoHeight = viewWidth / 3
        logoImageView.anchor(top: nil, left: nil, bottom: callerIdLabel.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: logoHeight, heightConstant: logoHeight)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        
        
        
        let buttonSize = viewWidth / 5
        
        incomingCallStackView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: viewHeight / 13.0, rightConstant: 0)
        
        declineButton.topAnchor.constraint(equalTo: declineCallContainerView.topAnchor).activate()
        declineButton.widthAnchor.constraint(equalToConstant: buttonSize).activate()
        declineButton.heightAnchor.constraint(equalTo: declineButton.widthAnchor).activate()
        declineButton.centerXAnchor.constraint(equalTo: declineCallContainerView.centerXAnchor).activate()
        
        declineLabel.anchor(top: declineButton.bottomAnchor, left: declineCallContainerView.leftAnchor, bottom: declineCallContainerView.bottomAnchor, right: declineCallContainerView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        declineLabel.centerXAnchor.constraint(equalTo: declineButton.centerXAnchor).activate()
        

        acceptButton.topAnchor.constraint(equalTo: acceptCallContainerView.topAnchor).activate()
        acceptButton.widthAnchor.constraint(equalToConstant: buttonSize).activate()
        acceptButton.heightAnchor.constraint(equalTo: acceptButton.widthAnchor).activate()
        acceptButton.centerXAnchor.constraint(equalTo: acceptCallContainerView.centerXAnchor).activate()
        
        acceptLabel.anchor(top: acceptButton.bottomAnchor, left: acceptCallContainerView.leftAnchor, bottom: acceptCallContainerView.bottomAnchor, right: acceptCallContainerView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        acceptLabel.centerXAnchor.constraint(equalTo: acceptButton.centerXAnchor).activate()
        
        
        
        let margin = acceptLabel.font.pointSize + 10 // 10 is vertical spacing between label and button
        
        
        hangupButton.widthAnchor.constraint(equalToConstant: buttonSize).activate()
        hangupButton.heightAnchor.constraint(equalTo: hangupButton.widthAnchor).activate()
        hangupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        hangupButton.bottomAnchor.constraint(equalTo: incomingCallStackView.bottomAnchor, constant: -(margin + 3)).activate() // 3 is approximage margin added because of this button not being in stackview
        

        connectedCallStackView.anchor(top: nil, left: incomingCallStackView.leftAnchor, bottom: hangupButton.topAnchor, right: incomingCallStackView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 40, rightConstant: 0)
        
        muteButton.widthAnchor.constraint(equalToConstant: buttonSize).activate()
        muteButton.heightAnchor.constraint(equalTo: muteButton.widthAnchor).activate()
        
        keypadButton.widthAnchor.constraint(equalToConstant: buttonSize).activate()
        keypadButton.heightAnchor.constraint(equalTo: keypadButton.widthAnchor).activate()
        
        audioSourceButton.widthAnchor.constraint(equalToConstant: buttonSize).activate()
        audioSourceButton.heightAnchor.constraint(equalTo: audioSourceButton.widthAnchor).activate()
        
        
        

        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    private func spacerView() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
//        v.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        return v
    }

    private func configureConnectedCallStackViewHierarchy() {
        let spacer1 = spacerView()
        let spacer2 = spacerView()
        let spacer3 = spacerView()
        let spacer4 = spacerView()
        
        
        connectedCallStackView.addArrangedSubview(spacer1)
        connectedCallStackView.addArrangedSubview(muteButton)
        connectedCallStackView.addArrangedSubview(spacer2)
        connectedCallStackView.addArrangedSubview(keypadButton)
        connectedCallStackView.addArrangedSubview(spacer3)
        connectedCallStackView.addArrangedSubview(audioSourceButton)
        connectedCallStackView.addArrangedSubview(spacer4)
        
        NSLayoutConstraint.activate([
            spacer2.widthAnchor.constraint(equalTo: spacer1.widthAnchor, multiplier: 1.0),
            spacer3.widthAnchor.constraint(equalTo: spacer1.widthAnchor, multiplier: 1.0),
            spacer4.widthAnchor.constraint(equalTo: spacer1.widthAnchor, multiplier: 1.0),
        ])
    }
    
}
/*
@objc func onPan(_ panGesture: UIPanGestureRecognizer) {

        func slideViewVerticallyTo(_ y: CGFloat) {
//               containerView.frame.origin = CGPoint(x: 0, y: y)
         let translate = CGAffineTransform(translationX: 0, y: y)
          containerView.transform = translate
        }

        switch panGesture.state {

        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: containerView)
            let y = max(0, translation.y)
            slideViewVerticallyTo(y)

        case .ended:
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: containerView)
            let velocity = panGesture.velocity(in: containerView)
         
            let closing = (translation.y > self.containerView.frame.size.height * minimumScreenRatioToHide) ||
                          (velocity.y > minimumVelocityToHide)

            if closing {
               dismissAnimated()
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    slideViewVerticallyTo(0)
                })
            }

        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                slideViewVerticallyTo(0)
            })

        }
}
*/
