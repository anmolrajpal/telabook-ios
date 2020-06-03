//
//  Extensions.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}
extension UIScrollView {
    func scrollToBottom(_ animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}
extension ApplicationError: LocalizedError {
    public var localizedDescription: String? {
        switch self {
        case let .Internal(status, message): return "Error \(status), \(message)"
        }
    }
}
extension ServiceError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .FailedRequest:
            return NSLocalizedString("Failed to create request", comment: "Failed Request")
        case .Internal:
            return NSLocalizedString("An internal error caused by the application", comment: "Internal Error")
        case .InvalidResponse:
            return NSLocalizedString("Invalid response received", comment: "Invalid Response")
        case .Unknown: return NSLocalizedString("An Unknown Error occured", comment: "Unknown Error")
        }
    }
}
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return (navigation.visibleViewController?.topMostViewController())!
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}
extension UIApplication {
    static func currentViewController() -> UIViewController? {
        var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
            print("Current View Controller is: Navigation Controller")
        }
        if let tabBarController = rootViewController as? TabBarController {
            rootViewController = tabBarController.selectedViewController
            print("Current View Controller is: Tab Bar Controller")
        }
        return rootViewController
    }
}
extension UISwitch {
    
    func set(width: CGFloat, height: CGFloat) {
        
        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51
        
        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth
        
        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}
extension UIControl {
    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
extension URLSession {
    func constructURL(from string:String, withConcatenatingPath pathToJoin:String? = nil, parameters:[String:String]? = nil) -> URL? {
        var components = URLComponents(string: string)
        if let concatenatingPath = pathToJoin {
            components?.path = "/\(concatenatingPath)"
        }
        if let parameters = parameters {
            components?.setQueryItems(with: parameters)
        }
        
        return components?.url
    }
    
    func constructURL(scheme:String = Config.ServiceConfig.serviceURLScheme, host:String = Config.ServiceConfig.serviceHost, path:Config.ServiceConfig.ServiceTypePath, withConcatenatingPath pathToJoin:String? = nil, parameters:[String:String]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let concatenatingPath = pathToJoin {
            components.path = Config.ServiceConfig.getServiceURLPath(for: path) + "/\(concatenatingPath)"
        } else {
            components.path = Config.ServiceConfig.getServiceURLPath(for: path)
        }
        if let parameters = parameters {
            components.setQueryItems(with: parameters)
        }
        return components.url
    }
}
extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")
}
extension UITableView {
    func scrollToTopRow(animated:Bool = true) {
        let topRowIndexPath = IndexPath(row: 0, section: 0)
        self.scrollToRow(at: topRowIndexPath, at: .top, animated: animated)
    }
    
    func resetCheckmarks() {
        for i in 0 ..< self.numberOfSections {
            for j in 0 ..< self.numberOfRows(inSection: i) {
                if let cell = self.cellForRow(at: IndexPath(row: j, section: i)) {
                    cell.accessoryType = .none
                }
            }
        }
    }
    func reloadDataWithLayout() {
        self.reloadData()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.reloadData()
    }
    func reloadAndScrollToTop() {
        self.reloadData()
        self.layoutIfNeeded()
        //        self.contentOffset = CGPoint(x: 0, y: -self.contentInset.top)
        self.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    func scrollToTop() {
        self.contentOffset = .zero
    }
    func scrollToBottom(animated: Bool) {
        //        let y = contentSize.height - frame.size.height + contentInset.bottom
        setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: animated)
    }
}
extension NSLayoutConstraint {
    func withPriority(_ constant:Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(constant)
        return self
    }
    func activate() {
        self.isActive = true
    }
    func deactivate() {
        self.isActive = false
    }
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
    }
    internal func fillSuperview() {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    internal func centerInSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    internal func constraint(equalTo size: CGSize) {
        guard superview != nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
    
    
    
    func shake(for duration:CFTimeInterval = 0.07, repeatCount:Float = 3, translationX: CGFloat = 4.0, withFeedbackTypeOf feedback:TapticEngine.HapticFeedback? = nil) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - translationX, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + translationX, y: self.center.y)
        layer.add(animation, forKey: "position")
        if let feedback = feedback {
            TapticEngine.generateFeedback(ofType: feedback)
        }
    }
    
}
extension UIViewController {
//    func startSpinner() {
//        OverlaySpinner.shared.spinner(mark: .Start)
//    }
//    func stopSpinner() {
//        OverlaySpinner.shared.spinner(mark: .Stop)
//    }

    func setUpNavBar() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.telaBlue, .font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 15)!]
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = UIColor.telaGray3
        view.backgroundColor = UIColor.telaGray1
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setCustomBackBarButton(image: #imageLiteral(resourceName: "back_arrow").withRenderingMode(.alwaysOriginal), title: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.backBarButtonItem?.tintColor = .telaGray6
        extendedLayoutIncludesOpaqueBars = true
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
//            self.navigationBar.backItem?.backBarButtonItem?.tintColor = .red
            self.navigationBar.backIndicatorImage = image
            self.navigationBar.backIndicatorTransitionMaskImage = image
        }
        if let title = title {
            self.navigationBar.backItem?.title = title
        }
    }
}
extension UIColor {
//    static var telaBlue = UIColor.rgb(r: 16, g: 182, b: 230) // Old
    static var telaBlue = UIColor.rgb(r: 144, g: 202, b: 249)
//    static var telaYellow = UIColor.rgb(r: 255, g: 229, b: 11) // Old
    static var telaYellow = UIColor.rgb(r: 255, g: 245, b: 157)
//    static var telaRed = UIColor.rgb(r: 255, g: 45, b: 10) // Old
    static var telaRed = UIColor.rgb(r: 239, g: 83, b: 80)
    
    static var telaGreen = UIColor.rgb(r: 76, g: 175, b: 80)
    static var telaBlack = UIColor.rgb(r: 0, g: 0, b: 0)
    static var telaWhite = UIColor.rgb(r: 255, g: 255, b: 255)
    static var telaGray1 = UIColor.rgb(r: 9, g: 9, b: 9)
    static var telaGray2 = UIColor.rgb(r: 12, g: 12, b: 12)
    static var telaGray3 = UIColor.rgb(r: 20, g: 20, b: 20)
    static var telaGray4 = UIColor.rgb(r: 23, g: 23, b: 23)
    static var telaGray5 = UIColor.rgb(r: 63, g: 63, b: 63)
    static var telaGray6 = UIColor.rgb(r: 96, g: 96, b: 96)
    static var telaGray7 = UIColor.rgb(r: 131, g: 131, b: 131)
    static var telaIndigo = UIColor.rgb(r: 82, g: 142, b: 244)
    static var telaLightYellow = UIColor.rgb(r: 255, g: 245, b: 157)
    static var telaLightBlue = UIColor.rgb(r: 144, g: 202, b: 249)
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
    func setIcon(_ image: UIImage, position: TextFieldItemPosition) {
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
    func setIcon(_ image: UIImage, frame:CGRect = CGRect(x: 10, y: 10, width: 25, height: 25), position: TextFieldItemPosition, tintColor:UIColor? = nil) {
        let iconView = UIImageView(frame: frame)
        iconView.image = image
        iconView.tintColor = tintColor
//        let iconContainerView: UIView = UIView(frame:
//            CGRect(x: 10, y: 0, width: 45, height: 45))
//        iconContainerView.addSubview(iconView)
        if position == .Left {
            leftView = iconView
            leftViewMode = .always
        } else {
            rightView = iconView
            rightViewMode = .always
        }
    }
    func setDefault(string text:String, withFont font:UIFont = UIFont(name: CustomFonts.gothamBook.rawValue, size: 20.0)!, characterSpacing:Double = 0, withColor color:UIColor = UIColor.telaWhite, at position: TextFieldItemPosition, withLeftSpacing leftSpacing:CGFloat = 10, withRightSpacing rightSpacing:CGFloat = 10) {
        let calculatedSize = (text as NSString).size(withAttributes: [
            .font: font,
            .kern: characterSpacing
        ])
//        let label = UILabel(frame: CGRect(x: 10, y: 10, width: calculatedSize.width, height: calculatedSize.height))
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: font,
            .kern: characterSpacing,
            .foregroundColor: color
        ])
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: leftSpacing + calculatedSize.width + rightSpacing, height: self.frame.height))
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).activate()
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).activate()
        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: leftSpacing).activate()
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -rightSpacing).activate()
        if position == .Left {
            leftView = containerView
            leftViewMode = .always
        } else {
            rightView = containerView
            rightViewMode = .always
        }
    }
}
extension UIAlertController {
    static func showModalSpinner(with title:String = "Please wait...", controller:UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let alertMessageAttributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaWhite
            ])
        alert.setValue(alertMessageAttributedString, forKey: "attributedMessage")
        
    alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        alert.view.subviews.first?.backgroundColor = UIColor.clear
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        controller.present(alert, animated: true, completion: nil)
    }
    static func dismissModalSpinner(animated:Bool = true, controller:UIViewController, completion: (() -> Void)? = nil) {
        guard let alert = controller.presentedViewController as? UIAlertController else { return }
        alert.dismiss(animated: animated, completion: completion)
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
    static public func showTelaAlert(title:String, message: String, action:UIAlertAction = UIAlertAction(title: "Ok", style: .destructive, handler: nil), controller: UIViewController? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController.telaAlertController(title: title, message: message)
        alert.addAction(action)
        if let vc = controller {
            if let currentAlert = vc.presentedViewController as? UIAlertController {
                currentAlert.dismiss(animated: true) {
                    vc.present(alert, animated: true, completion: completion)
                }
            } else {
                vc.present(alert, animated: true, completion: completion)
            }
        } else {
            var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? TabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(alert, animated: true, completion: completion)
        }
    }
    static public func showModalTelaAlert(title:String, message: String, actions:UIAlertAction..., completion: (() -> Void)? = nil) {
        let alert = UIAlertController.telaAlertController(title: title, message: message)
        actions.forEach({ alert.addAction($0) })
        var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alert, animated: true, completion: completion)
    }
    static public func presentAlert(_ alert: UIAlertController, on vc: UIViewController? = nil, completion: (() -> Void)? = nil) {
        if let vc = vc {
            vc.present(alert, animated: true, completion: completion)
        } else {
            var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(alert, animated: true, completion: completion)
        }
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
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    static func emptyIfNil(_ optionalString: String?) -> String {
        let text: String
        if let unwrapped = optionalString {
            text = unwrapped
        } else {
            text = ""
        }
        return text
    }
    func isPhoneNumberLengthValid() -> Bool {
        let regex = "^[0-9]{10}"
        let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return regexTest.evaluate(with: self)
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
    
    
    func formatNumber(withMask mask:String = "(XXX) XXX-XXXX") -> String {
        let cleanPhoneNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for character in mask where index < cleanPhoneNumber.endIndex {
            if character == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(character)
            }
        }
        return result
    }
    var extractNumbers: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars.compactMap { pattern ~= $0 ? Character($0) : nil })
    }
    func getE164FormattedNumber() -> String? {
        guard self.count >= 10 else { return nil }
        let purePhoneNumber = String(self.suffix(10))
        let formattedPhoneNumber = purePhoneNumber.formatNumber()
        if self.count > 10 {
            let countryCode = self.padding(toLength: self.count - 10, withPad: purePhoneNumber, startingAt: -1)
            return "\(countryCode) \(formattedPhoneNumber)"
        }
        return formattedPhoneNumber
    }
}
let imageCache = NSCache<NSString, UIImage>()
extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
        
    func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
                            height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)
        
        UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
        self.draw(at: origin)
        
        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
    }

    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLength: CGFloat = 480
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    static func textImage(image:UIImage, text:String, textColor:UIColor = .white, font:UIFont = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)!) -> UIImage {
        let expectedTextSize = (text as NSString).size(withAttributes: [.font: font])
        let width = max(expectedTextSize.width, image.size.width)
        let height = image.size.height + expectedTextSize.height + 5
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
//            context.currentImage.withRenderingMode(.alwaysOriginal)
            let textX: CGFloat = expectedTextSize.width > image.size.width ? 0 : (image.size.width / 2) - (expectedTextSize.width / 2)
            let textY: CGFloat = image.size.height + 5
            
            let textPoint: CGPoint = CGPoint.init(x: textX, y: textY)
            text.draw(at: textPoint, withAttributes: [
                .font: font,
                .foregroundColor: textColor
                ])
            let imageX: CGFloat = expectedTextSize.width > image.size.width ? (expectedTextSize.width / 2) - (image.size.width / 2) : 0
            let rect = CGRect(x: imageX,
                              y: 0,
                              width: image.size.width,
                              height: image.size.height)
            
            image.draw(in: rect)
//            image.withRenderingMode(.alwaysOriginal)
        }
    }
    static func textEmbededImage(image: UIImage,
                            text: String,
                            isImageBeforeText: Bool,
                            segFont: UIFont? = nil) -> UIImage {
        let font = segFont ?? UIFont.systemFont(ofSize: 16)
        let expectedTextSize = (text as NSString).size(withAttributes: [.font: font])
        let width = expectedTextSize.width + image.size.width + 5
        let height = max(expectedTextSize.height, image.size.width)
        let size = CGSize(width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2
            let textOrigin: CGFloat = isImageBeforeText
                ? image.size.width + 5
                : 0
            let textPoint: CGPoint = CGPoint.init(x: textOrigin, y: fontTopPosition)
            text.draw(at: textPoint, withAttributes: [.font: font])
            let alignment: CGFloat = isImageBeforeText
                ? 0
                : expectedTextSize.width + 5
            let rect = CGRect(x: alignment,
                              y: (height - image.size.height) / 2,
                              width: image.size.width,
                              height: image.size.height)
//            image.withRenderingMode(.alwaysOriginal)
            image.draw(in: rect)
        }
    }
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
        guard let urlString = URLString?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("no url string")
            DispatchQueue.main.async {
                self.image = placeHolder
            }
            return
        }
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return
        } else {
            print("No cached image")
        }
        
        if let url = URLSession.shared.constructURL(from: urlString) {
            print("image URL String => \(urlString)")
            print("image URL => \(url)")
            print("image URL absolute string => \(url.absoluteString)")
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
               
                print("Image Fetch from URL Response: \(String(describing: response))")
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
                        } else {
                            print("Failed to unwrap downloaded image data")
                        }
                    } else {
                        print("Failed to unwrap image data")
                    }
                    
                }
            }).resume()
        } else {
            print("Failed to unwrap url")
        }
    }
}
extension UIImageView: APIProtocol {
    
    func loadImageUsingCache(with URLString: String?, placeHolder: UIImage? = #imageLiteral(resourceName: "placeholder.png")) {
        
        self.image = nil
        guard let urlString = URLString else {
            DispatchQueue.main.async {
                self.image = placeHolder
            }
            return
        }
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        } else {
            DispatchQueue.main.async {
                self.image = placeHolder
            }
        }
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                self.handleResponse(data: data, response: response, error: error, completion: { (responseStatus, data, serviceError, error) in
                    if let err = error {
                        DispatchQueue.main.async {
                            print("***Error Fetching Follow Image****\n\(err.localizedDescription)")
                            DispatchQueue.main.async {
                                self.image = placeHolder
                            }
                           
                        }
                    } else if let serviceErr = serviceError {
                        DispatchQueue.main.async {
                            print("***Error Fetching Image****\n\(serviceErr.localizedDescription)")
                            DispatchQueue.main.async {
                                self.image = placeHolder
                            }
                            
                        }
                    } else if let status = responseStatus {
                        guard status == .OK else {
                            DispatchQueue.main.async {
                                self.image = placeHolder
                            }
                            return
                        }
                        if let data = data {
                            if let downloadedImage = UIImage(data: data) {
                                imageCache.setObject(downloadedImage, forKey: NSString(string: urlString))
                                DispatchQueue.main.async {
                                    self.image = downloadedImage
                                }
                            } else {
                                print("Failed to create image from data")
                                DispatchQueue.main.async {
                                    self.image = placeHolder
                                }
                            }
                        } else {
                            print("Failed to unwrap image data")
                            DispatchQueue.main.async {
                                self.image = placeHolder
                            }
                        }
                    }
                })
            }).resume()
        } else {
            print("Failed to construct url from url string => \(urlString)")
            DispatchQueue.main.async {
                self.image = placeHolder
            }
        }
    }
}
extension Date {
    static func isDateSame(date1 lhs:Date, date2 rhs:Date) -> Bool {
        let lhsDay = Calendar.current.component(.day, from: lhs)
        let lhsMonth = Calendar.current.component(.month, from: lhs)
        let lhsYear = Calendar.current.component(.year, from: lhs)
        let rhsDay = Calendar.current.component(.day, from: rhs)
        let rhsMonth = Calendar.current.component(.month, from: rhs)
        let rhsYear = Calendar.current.component(.year, from: rhs)
        if (lhsDay == rhsDay && lhsMonth == rhsMonth && lhsYear == rhsYear) {
            return true
        } else {
            return false
        }
    }
    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
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
    static func getDateFromString(dateString:String?, dateFormat:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let string = dateString {
            let date:Date? = dateFormatter.date(from: string)
            return date
        }
        return nil
    }
    static func getStringFromDate(date:Date, dateFormat:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString:String = dateFormatter.string(from: date)
        return dateString
    }
}



extension Bundle {
    enum Identifiers {
        case version, build
        
        var keyIdentifier:String {
            switch self {
                case .version: return "CFBundleShortVersionString"
                case .build: return "CFBundleVersion"
            }
        }
    }
    static var versionNumber:String? {
        Bundle.main.infoDictionary?[Identifiers.version.keyIdentifier] as? String
    }
    static var buildNumber:String? {
        Bundle.main.infoDictionary?[Identifiers.build.keyIdentifier] as? String
    }
}


extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}
extension Int {
    var boolValue: Bool {
        return self != 0
    }
}



extension UIRefreshControl {

    func beginExplicitRefreshing() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: false)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }

}






extension FileManager {
    static var cacheDirectoryURL:URL {
        self.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    static var cacheDirectoryURLString:String {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
}

extension Data {
    func getDownsampledImage(to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(self as CFData, imageSourceOptions)!
        let maxDimensionInPixels = Swift.max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
}

extension URL {
    func getDownsampledImage(to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(self as CFURL, imageSourceOptions)!
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
}





extension Date {
    
    /// Retruns the milliseconds passed since 1970 (the epoch time)
    var milliSecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000).rounded())
    }
    
    
    /// Initializes the `Date` object from given milliseconds since 1970 (the epoch time)
    /// - Parameter milliSecondsSince1970: This parameter takes milliseconds which must be of 13 digits till next `267 years` from the time of coding this function.
    init(milliSecondsSince1970 value: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(value / 1000))
        self.addTimeInterval(TimeInterval(Double(value % 1000) / 1000 ))
    }
//    init(milliSecondsSince1970: TimeInterval) {
//        self = Date(timeIntervalSince1970: TimeInterval(milliSecondsSince1970 / 1000))
//        self.addTimeInterval(TimeInterval(Double(Int64(milliSecondsSince1970) % 1000) / 1000 ))
//    }
    
    
    /// This function adds the milliseconds from a custom microseconds formatted date string.
    /// - Parameter string: This value must be in a string format: `yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ`
    /// - Returns: An optional  `Date` object with added milliseconds.
    static func getDate(fromMicrosecondsFormattedDateString string:String) -> Date? {
        let groups = string.split(separator: ".")
        let datePart = String(groups[0])
        guard let date = Date.getDateFromString(dateString: datePart, dateFormat: "yyyy-MM-dd'T'HH:mm:ss") else { return nil }
        let microseconds = groups[1].replacingOccurrences(of: "Z", with: "")
        let milliseconds = Int(microseconds)! / 1000
        let timeIntervalToAdd:TimeInterval = TimeInterval((Double(milliseconds) / 1000.0))
        return date.addingTimeInterval(timeIntervalToAdd)
    }
    
    /// This function returns the Date object depending on the parameter which maybe is seconds or milliseconds.
    /// - Note: This  function is only valid for next `267` years till `Saturday, 20 November 2286 17:46:39.999`
    /// - Parameter value: Parameter value must be either `seconds` or `milliseconds` | `10 digits`  or `13 digits` respectively.
    /// - Returns: `Date` object calculted from timeInterval passed since 1970 or milliSeconds passed since 1970
    static func getDate(fromSecondsOrMilliseconds value:Int) -> Date? {
        if 11...13 ~= value.digitsCount {
            return Date(milliSecondsSince1970: Int64(value * (10 ~^ (13 - value.digitsCount))))
        } else if 6...10 ~= value.digitsCount {
            return Date(timeIntervalSince1970: TimeInterval(value * (10 ~^ (10 - value.digitsCount))))
        } else if value == 0 { return nil} else { return nil }
    }
}




extension String {
    var dateFromFormattedString:Date? {
        if self.contains("Z") && self.count == 27 {
            return .getDate(fromMicrosecondsFormattedDateString: self)
        } else {
            return .getDateFromString(dateString: self, dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
    }
    var boolFromPossibleStringValues:Bool {
        switch self {
            case "true", "TRUE", "True", "1", "yes", "YES", "Yes": return true
            case "false", "FALSE", "False", "0", "NO", "no", "No": return false
            default: return false
        }
    }
}

extension StringProtocol  {
    /// Returns an array of integer digits from called string integer.
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Numeric where Self: LosslessStringConvertible {
    /// Returns an array of integer digits from called integer.
    var digits: [Int] { string.digits }
    
    /// Returns count of array of integer digits from called integer.
    var digitsCount:Int { string.digits.count }
}
extension String {
  var isBlank: Bool { allSatisfy({ $0.isWhitespace }) }
}
extension Optional where Wrapped == String {
  var isBlank: Bool { self?.isBlank ?? true }
}



extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor? {
        
        guard let pixelData = self.cgImage?.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    /*
    What happens is this method will pick the pixel colour from the image's CGImage. So make sure you are picking from the right image. e.g. If you UIImage is 200x200, but the original image file from Imgaes.xcassets or wherever it came from, is 400x400, and you are picking point (100,100), you are actually picking the point on the upper left section of the image, instead of middle.

    Two Solutions:
    1, Use image from Imgaes.xcassets, and only put one @1x image in 1x field. Leave the @2x, @3x blank. Make sure you know the image size, and pick a point that is within the range.

    //Make sure only 1x image is set
    let image : UIImage = UIImage(named:"imageName")
    //Make sure point is within the image
    let color : UIColor = image.getPixelColor(CGPointMake(xValue, yValue))
    2, Scale you CGPoint up/down the proportion to match the UIImage. e.g. let point = CGPoint(100,100) in the example above,

    let xCoordinate : Float = Float(point.x) * (400.0/200.0)
    let yCoordinate : Float = Float(point.y) * (400.0/200.0)
    let newCoordinate : CGPoint = CGPointMake(CGFloat(xCoordinate), CGFloat(yCoordinate))
    let image : UIImage = largeImage
    let color : UIColor = image.getPixelColor(CGPointMake(xValue, yValue))
    I've only tested the first method, and I am using it to get a colour off a colour palette. Both should work. Happy coding :)

    */
 }
extension Array {
    @inlinable public var second: Element? {
        return count >= 2 ? self[1] : nil
    }
}
