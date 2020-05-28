//
//  Reachability+ViewHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

fileprivate let networkStatusLabel:UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .center
    label.textColor = .telaWhite
    label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)
    label.alpha = 0
    label.transform = CGAffineTransform(translationX: 0, y: -label.frame.height)
    return label
}()
fileprivate let noConnectionAttributedText:NSMutableAttributedString = {
    let attachment = NSTextAttachment()
    let icon = SFSymbol.noWifi.image.withTintColor(.telaWhite)
    attachment.image = icon
    attachment.bounds = CGRect(x: 0, y: -2.0, width: attachment.image!.size.width, height: attachment.image!.size.height)
    let attachmentString = NSAttributedString(attachment: attachment)
    let attributedText = NSMutableAttributedString(string: "")
    let prefix = NSAttributedString(string: "No Connection ")
    attributedText.append(prefix)
    attributedText.append(attachmentString)
    return attributedText
}()
fileprivate let wifiAttributedText:NSMutableAttributedString = {
    let wifiIconAttachment = NSTextAttachment()
    let wifiIcon = SFSymbol.wifi.image.withTintColor(.telaWhite)
    wifiIconAttachment.image = wifiIcon
    wifiIconAttachment.bounds = CGRect(x: 0, y: -2.0, width: wifiIconAttachment.image!.size.width, height: wifiIconAttachment.image!.size.height)
    let wifiAttachmentString = NSAttributedString(attachment: wifiIconAttachment)
    let attributedText = NSMutableAttributedString(string: "")
    let prefix = NSAttributedString(string: "Connected via ")
    attributedText.append(prefix)
    attributedText.append(wifiAttachmentString)
    return attributedText
}()
fileprivate let cellularAttributedText:NSMutableAttributedString = {
    let cellularIconAttachment = NSTextAttachment()
    let cellularIcon = SFSymbol.cellular.image.withTintColor(.telaWhite)
    cellularIconAttachment.image = cellularIcon
    cellularIconAttachment.bounds = CGRect(x: 0, y: -4.0, width: cellularIconAttachment.image!.size.width, height: cellularIconAttachment.image!.size.height)
    let cellularAttachmentString = NSAttributedString(attachment: cellularIconAttachment)
    let attributedText = NSMutableAttributedString(string: "")
    let prefix = NSAttributedString(string: "Connected via ")
    attributedText.append(prefix)
    attributedText.append(cellularAttachmentString)
    return attributedText
}()
fileprivate var isNetworkLastReachable:Bool = true


extension UIViewController {
    
    private func layoutReachabilityStatusViews() {
        if view.subviews.contains(networkStatusLabel) { networkStatusLabel.removeFromSuperview() }
        view.addSubview(networkStatusLabel)
        let guide = view.safeAreaLayoutGuide
        networkStatusLabel.anchor(top: guide.topAnchor, left: guide.leftAnchor, bottom: nil, right: guide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 40)
        networkStatusLabel.layoutIfNeeded()
    }
    func observeReachability(forcing:Bool = true) {
        guard forcing else { return }
        let reachability = NetworkManager.shared.reachability
        try! reachability.startNotifier()
        reachability.whenUnreachable = { reachability in
            isNetworkLastReachable = false
            self.showNetworkStatusLabel(connected: false, message: noConnectionAttributedText)
        }
        reachability.whenReachable = { reachability in
            if isNetworkLastReachable { return }
            if reachability.connection == .wifi {
                self.showNetworkStatusLabel(connected: true, message: wifiAttributedText)
            } else if reachability.connection == .cellular {
                self.showNetworkStatusLabel(connected: true, message: cellularAttributedText)
            }
        }
    }
    func stopObservingReachability() {
        NetworkManager.shared.removeObservers()
    }
    private func showNetworkStatusLabel(connected:Bool, message:NSMutableAttributedString) {
        layoutReachabilityStatusViews()
        networkStatusLabel.attributedText = message
        networkStatusLabel.backgroundColor = connected ? UIColor.systemGreen.withAlphaComponent(0.8) : UIColor.systemRed.withAlphaComponent(0.8)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            networkStatusLabel.alpha = 1.0
            networkStatusLabel.transform = .identity
            UIView.animate(withDuration: 0.3, delay: 2.6, options: .curveLinear, animations: {
                networkStatusLabel.transform = CGAffineTransform(translationX: 0, y: -networkStatusLabel.frame.height)
            }, completion: { _ in networkStatusLabel.alpha = 0})
        }, completion: nil)
    }
}
