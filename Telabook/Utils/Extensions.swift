//
//  Extensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
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
//        navigationController?.navigationBar.tintColor = UIColor.telaYellow
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
    
    
    
    static var randomColor: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
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
    static public func showAlert(alertTitle:String, message: String, alertActionTitle:String, controller: UIViewController) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
extension String {
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
