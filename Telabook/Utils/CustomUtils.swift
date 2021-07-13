//
//  CustomUtils.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

final class CustomUtils {
    static let shared = CustomUtils()
    
    func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
    func downsample(imageFrom imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
    
    func presentAcknowledgementModal() {
        
    }
    func getSlashEncodedURL(from urlString:String?) -> String? {
        let firebaseUri = "https://firebasestorage.googleapis.com/v0/b/telebookchat.appspot.com/o/"
        if let string = urlString,
            let startRange:Range<String.Index> = string.range(of: firebaseUri) {
            let range = string.range(of: string[startRange.upperBound...])
            let url = string.replacingOccurrences(of: "/", with: "%2F", options: String.CompareOptions.regularExpression, range: range)
            return url
        }
        return nil
    }
    func getUserRole() -> UserRole {
        let roleId = AppData.roleId
        switch roleId {
        case 1: return .SuperUser
        case 2: return .Admin
        case 3: return .Receptionist
        case 4: return .Agent
        default: fatalError("Invalid Role ID: \(roleId)")
        }
    }
    func getInitials(from fullName:String) -> String {
        let groups = fullName.split(separator: " ")
        let firstName = groups.first
        let lastName = groups.last
        let initials:String = "\(String(firstName?.first ?? "*"))\(String(lastName?.first ?? "*"))"
        return initials
    }
}
class InsetLabel:UILabel {
    var textInsets:UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }
    init(textInsets: UIEdgeInsets) {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.textInsets = textInsets
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += textInsets.top + textInsets.bottom
        intrinsicSuperViewContentSize.width += textInsets.left + textInsets.right
        return intrinsicSuperViewContentSize
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/*
class InsetLabel: UILabel {

    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

}
*/
class DictionaryEncoder {
    private let jsonEncoder = JSONEncoder()

    /// Encodes given Encodable value into an array or dictionary
    func encode<T>(_ value: T) throws -> Any where T: Encodable {
        let jsonData = try jsonEncoder.encode(value)
        return try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    }
}

class DictionaryDecoder {
    private let jsonDecoder = JSONDecoder()
    
    /// Decodes given Decodable type from given array or dictionary
    func decode<T>(_ type: T.Type, from json: Any) throws -> T where T: Decodable {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try jsonDecoder.decode(type, from: jsonData)
    }
}

func showAlert(title:String = "Error", withErrorMessage errorMessage: String, actionCompletion: (() -> Void)? = nil, presentCompletion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindow.Level.alert + 1
        let title = NSLocalizedString(title, comment: "The Title of the Alert")
        let message = NSLocalizedString(errorMessage, comment: "The message to be displayed in the Alert")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                      style: .cancel,
                                      handler: {(_ action: UIAlertAction) -> Void in
                                        topWindow.isHidden = true // if you want to hide the topwindow then use this
                                        actionCompletion?()
                                      }))
        topWindow.makeKeyAndVisible()
        topWindow.rootViewController?.present(alert, animated: true, completion: presentCompletion)
    }   
}
