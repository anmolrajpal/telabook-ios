//
//  BotMessageCell.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import MessageKit

open class BotMessageCell: UICollectionViewCell {
    
    let label = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    open func setupSubviews() {
        contentView.addSubview(label)
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        // Do stuff
        switch message.kind {
        case .custom(let data):
            guard let systemMessage = data as? NSAttributedString else { return }
            label.attributedText = systemMessage
        default:
            break
        }
    }
    
}
