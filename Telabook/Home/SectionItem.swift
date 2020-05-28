//
//  SectionItem.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
public class SectionItem {
    public var sectionImage:UIImage
    public var sectionTitle:String
    public var sectionSubTitle:String
    
    public init(image:UIImage, title:String, subTitle:String) {
        self.sectionImage = image
        self.sectionTitle = title
        self.sectionSubTitle = subTitle
    }
}
