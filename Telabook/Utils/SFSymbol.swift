//
//  SFSymbol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import UIKit

public enum SFSymbol { case
    
    wifi,
    noWifi,
    cellular,
    more,
    person,
    circleSwitch,
    sendMessage,
    arrowUpRightSquare,
    pin,
    cancel
    
    private var imageName:String {
        switch self {
            case .wifi: return "wifi"
            case .noWifi: return "wifi.slash"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .more: return "ellipsis"
            case .person: return "person"
            case .circleSwitch: return "largecircle.fill.circle"
            case .sendMessage: return "paperplane"
            case .arrowUpRightSquare: return "arrow.up.right.square"
            case .pin: return "pin.fill"
            case .cancel: return "multiply.circle.fill"
        }
    }
    
    var image:UIImage { image() }
    
    func image(withSymbolConfiguration configuration:UIImage.SymbolConfiguration = .init(textStyle: UIFont.TextStyle.body)) -> UIImage {
        UIImage(systemName: self.imageName, withConfiguration: configuration)!
    }
}
