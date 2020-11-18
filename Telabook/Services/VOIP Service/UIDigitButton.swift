//
//  UIDigitButton.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/11/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class UIDigitButton: UIButton {
    
    lazy var addressField:UITextField = {
        let textField = UITextField()
        return textField
    }()
    var digit:CChar = 0
    var dtmf:Bool
    
    // MARK: - Lifecycle Functions
    
    func configureTargetActions() {
        addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(touchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    override init(frame: CGRect) {
        self.dtmf = false
        super.init(frame: frame)
        configureTargetActions()
    }
    
    required init?(coder decoder: NSCoder) {
        self.dtmf = false
        super.init(coder: decoder)
        configureTargetActions()
    }
    
    // MARK: - Actions Functions
    @objc func touchDown(_ sender: Any?) {
        if !dtmf || !linphoneCore.inCall() {
            let newAddress = "\(addressField.text ?? "")\(digit)"
            addressField.text = newAddress
            linphoneCore.playDtmf(dtmf: digit, durationMs: -1)
        } else {
            do {
                try linphoneCore.currentCall?.sendDtmf(dtmf: digit)
            } catch {
                print("Error sending dtmf: \(error.localizedDescription)")
            }
            linphoneCore.playDtmf(dtmf: digit, durationMs: 100)
        }
    }
    
    @objc func touchUp(_ sender: Any?) {
        linphoneCore.stopDtmf()
    }
}

