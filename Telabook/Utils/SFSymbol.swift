//
//  SFSymbol.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/05/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
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
    cancel,
    info,
    copy,
    delete,
    forward,
    reply,
    speak,
    tag,
    checkmark,
    messageDeleted,
    downIndicator,
    errorSendingBadge,
    download,
    circle,
    checkmark·circle·fill,
    plus,
    plus·circle·fill,
    arrow·down·circle·fill,
    phone·fill,
    arrow·down·left,
    arrow·up·right,
    person·crop·circle,
    person·crop·circle·fill,
    multiply,
    speaker,
    mute,
    chevron·compact·down,
    chevron·down,
    keypad
    
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
        case .info: return "info.circle"
        case .copy: return "doc.on.doc"
        case .delete: return "trash"
        case .forward: return "arrowshape.turn.up.right"
        case .reply: return "arrowshape.turn.up.left"
        case .speak: return "captions.bubble"
        case .tag: return "tag"
        case .checkmark: return "checkmark"
        case .messageDeleted: return "nosign"
        case .downIndicator: return "chevron.down.circle"
        case .errorSendingBadge: return "exclamationmark.circle.fill"
        case .download: return "square.and.arrow.down"
        case .circle: return "circle"
        case .checkmark·circle·fill: return "checkmark.circle.fill"
        case .plus: return "plus"
        case .plus·circle·fill: return "plus.circle.fill"
        case .arrow·down·circle·fill: return "arrow.down.circle.fill"
        case .phone·fill: return "phone.fill"
        case .arrow·down·left: return "arrow.down.left"
        case .arrow·up·right: return "arrow.up.right"
        case .person·crop·circle: return "person.crop.circle"
        case .person·crop·circle·fill: return "person.crop.circle.fill"
        case .multiply: return "multiply"
        case .speaker: return "speaker.wave.3.fill"
        case .mute: return "mic.slash.fill"
        case .chevron·compact·down: return "chevron.compact.down"
        case .chevron·down: return "chevron.down"
        case .keypad: return "circle.grid.3x3.fill"
        }
    }
    
    var image:UIImage { image() }
    
    func image(withSymbolConfiguration configuration:UIImage.SymbolConfiguration = .init(textStyle: UIFont.TextStyle.body)) -> UIImage {
        UIImage(systemName: self.imageName, withConfiguration: configuration)!
    }
}
