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
    more
    
    
    private var imageName:String {
        switch self {
            case .wifi: return "wifi"
            case .noWifi: return "wifi.slash"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .more: return "ellipsis"
        }
    }
    
    var image:UIImage {
        UIImage(systemName: self.imageName)!
    }
}
