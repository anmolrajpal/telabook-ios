//
//  UserMessage+ImageItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
import MessageKit

struct ImageItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var imageUUID:UUID?
    var imageText:String?
    var attributedText:NSAttributedString?
    var placeholderImage: UIImage
    var size: CGSize
    var mediaSizeInBytes:Int?
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 270, height: 270)
        self.mediaSizeInBytes = 0
        self.placeholderImage = UIImage()
    }
    init(imageUrl: URL, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes:Int = 0) {
        self.url = imageUrl
        self.size = size
        self.placeholderImage = UIImage()
        self.mediaSizeInBytes = mediaSizeInBytes
    }
    init(imageUrl: URL, imageText:String, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes:Int = 0) {
        self.init(imageUrl: imageUrl, size: size, mediaSizeInBytes: mediaSizeInBytes)
        self.imageText = imageText
    }
    init(imageUrl: URL, attributedText:NSAttributedString, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes: Int = 0) {
        self.init(imageUrl: imageUrl, imageText: attributedText.string, size: size, mediaSizeInBytes: mediaSizeInBytes)
        self.attributedText = attributedText
    }
    init(imageUrl:URL, image:UIImage?, attributedText:NSAttributedString, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes: Int = 0) {
        self.init(imageUrl: imageUrl, attributedText: attributedText, size: size, mediaSizeInBytes: mediaSizeInBytes)
        self.image = image
    }
    init(imageUrl:URL, image:UIImage?, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes: Int = 0) {
        self.url = imageUrl
        self.image = image
        self.size = size
        self.placeholderImage = UIImage()
        self.mediaSizeInBytes = mediaSizeInBytes
        //        self.placeholderImage = size.width > size.height ? #imageLiteral(resourceName: "placeholder-image") : #imageLiteral(resourceName: "placeholder.png")
    }
    
    
    init(image:UIImage, imageUUID:UUID, uploadURL:URL?, imageText:String?, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes: Int = 0) {
        self.image = image
        self.imageText = imageText
        self.imageUUID = imageUUID
        self.url = uploadURL
        self.size = size
        self.placeholderImage = UIImage()
        self.mediaSizeInBytes = mediaSizeInBytes
    }
    init(image:UIImage, imageUUID:UUID, uploadURL:URL?, attributedText:NSAttributedString, size:CGSize = .init(width: 270, height: 270), mediaSizeInBytes: Int = 0) {
        self.init(image: image, imageUUID: imageUUID, uploadURL: uploadURL, imageText: attributedText.string, size: size, mediaSizeInBytes: mediaSizeInBytes)
        self.attributedText = attributedText
    }
}
