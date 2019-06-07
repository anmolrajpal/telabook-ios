//
//  Extensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")
}
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
//        return anchors
    }
}
extension UIViewController {
    
    
    
    func setUpNavBar() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.telaBlue, .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 15)!]
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = UIColor.telaGray3
        view.backgroundColor = UIColor.telaGray1
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setCustomBackBarButton(image: #imageLiteral(resourceName: "back_arrow"), title: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .telaGray6
        self.extendedLayoutIncludesOpaqueBars = true
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        //        return topViewController?.preferredStatusBarStyle ?? .default
        if let topVC = viewControllers.last {
            return topVC.preferredStatusBarStyle
        }
        return .default
    }
    func setCustomBackBarButton(image:UIImage?, title:String?) {
        if let image = image {
            self.navigationBar.backItem?.backBarButtonItem?.tintColor = .red
            self.navigationBar.backIndicatorImage = image
            self.navigationBar.backIndicatorTransitionMaskImage = image
        }
        if let title = title {
            self.navigationBar.backItem?.title = title
        }
    }
}
extension UIColor {
    static var telaBlue = UIColor.rgb(r: 16, g: 182, b: 230)
    static var telaYellow = UIColor.rgb(r: 255, g: 229, b: 11)
    static var telaRed = UIColor.rgb(r: 255, g: 45, b: 10)
    static var telaBlack = UIColor.rgb(r: 0, g: 0, b: 0)
    static var telaWhite = UIColor.rgb(r: 255, g: 255, b: 255)
    static var telaGray1 = UIColor.rgb(r: 9, g: 9, b: 9)
    static var telaGray2 = UIColor.rgb(r: 12, g: 12, b: 12)
    static var telaGray3 = UIColor.rgb(r: 20, g: 20, b: 20)
    static var telaGray4 = UIColor.rgb(r: 23, g: 23, b: 23)
    static var telaGray5 = UIColor.rgb(r: 63, g: 63, b: 63)
    static var telaGray6 = UIColor.rgb(r: 96, g: 96, b: 96)
    static var telaGray7 = UIColor.rgb(r: 131, g: 131, b: 131)
    static var telaGreen = UIColor.rgb(r: 52, g: 225, b: 190)
    static var telaIndigo = UIColor.rgb(r: 82, g: 142, b: 244)
    
    
    static var randomColor: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    static func getConversationColor(color:ConversationColor) -> UIColor {
        switch color {
        case .Default: return UIColor.telaWhite
        case .Yellow: return UIColor.telaYellow
        case .Green: return UIColor.telaGreen
        case .Blue: return UIColor.telaIndigo
        }
    }
}
extension UITextField {
    func setIcon(_ image: UIImage, position: TextFieldIconPosition) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 10, width: 25, height: 25))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 10, y: 0, width: 45, height: 45))
        iconContainerView.addSubview(iconView)
        if position == .Left {
            leftView = iconContainerView
            leftViewMode = .always
        } else {
            rightView = iconContainerView
            rightViewMode = .always
        }
    }
}
extension UIAlertController {
    static func showModalSpinner(controller:UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let alertMessageAttributedString = NSAttributedString(string: "Please wait...", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaWhite
            ])
        alert.setValue(alertMessageAttributedString, forKey: "attributedMessage")
    alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        alert.view.subviews.first?.backgroundColor = UIColor.clear
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.white
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        controller.present(alert, animated: true, completion: nil)
    }
    static func dismissModalSpinner(controller:UIViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    static public func telaAlertController(title:String, message:String = "\n") -> UIAlertController {
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)
        let alertTitleAttributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 15)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
            ])
        let alertMessageAttributedString = NSAttributedString(string: "\n\(message)", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaWhite
            ])
        alertVC.setValue(alertTitleAttributedString, forKey: "attributedTitle")
        alertVC.setValue(alertMessageAttributedString, forKey: "attributedMessage")
    alertVC.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        
        alertVC.view.tintColor = UIColor.telaBlue
        alertVC.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alertVC.view.subviews.first?.backgroundColor = .clear
        return alertVC
    }
    static public func showAlert(alertTitle:String, message: String, alertActionTitle:String, controller: UIViewController) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
extension NSObject {
    static var propertyNames: [String] {
        var outCount: UInt32 = 0
        guard let ivars = class_copyIvarList(self, &outCount) else {
            return []
        }
        var result = [String]()
        let count = Int(outCount)
        for i in 0..<count {
            let pro: Ivar = ivars[i]
            guard let ivarName = ivar_getName(pro) else {
                continue
            }
            guard let name = String(utf8String: ivarName) else {
                continue
            }
            result.append(name)
        }
        return result
    }
}
extension String {
    static func emptyIfNil(_ optionalString: String?) -> String {
        let text: String
        if let unwrapped = optionalString {
            text = unwrapped
        } else {
            text = ""
        }
        return text
    }
    func isValidEmailAddress() -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}"
            + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
            + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
            + "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
            + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
            + "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
            + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
let imageCache = NSCache<NSString, UIImage>()
extension UIImage {
    static public func placeholderInitialsImage(text: String) -> UIImage? {
//        let image:UIImage = #imageLiteral(resourceName: "idle")
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let textColor = UIColor.white
        let textFont = UIFont(name: CustomFonts.gothamMedium.rawValue, size:18)!
        let initialsLabel = UILabel(frame: frame)
        initialsLabel.font = textFont
        initialsLabel.textColor = textColor
        initialsLabel.numberOfLines = 1
        initialsLabel.textAlignment = .center
        initialsLabel.backgroundColor = .telaGray5
        initialsLabel.text = text
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
       
        if let currentContext = UIGraphicsGetCurrentContext() {
            initialsLabel.layer.render(in: currentContext)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    func textToImage(drawText text: String, atPoint point: CGPoint) -> UIImage {
        let image:UIImage = #imageLiteral(resourceName: "idle")
        let textColor = UIColor.white
        let textFont = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 20)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
extension UIImageView {
    
    func loadImageUsingCacheWithURLString(_ URLString: String?, placeHolder: UIImage?) {
        
        self.image = nil
        guard let urlString = URLString else {
            DispatchQueue.main.async {
                self.image = placeHolder
            }
            return
        }
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: urlString))
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}
extension Date {
    static func getDateFromString(dateString:String?, dateFormat:CustomDateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        if let string = dateString {
            let date:Date? = dateFormatter.date(from: string)
            return date
        }
        return nil
    }
    static func getStringFromDate(date:Date, dateFormat:CustomDateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        let dateString:String = dateFormatter.string(from: date)
        return dateString
    }
}
