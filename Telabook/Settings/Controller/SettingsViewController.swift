//
//  SettingsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class SettingsViewController: UIViewController {
    static let shared = SettingsViewController()
    internal var userProfile:UserProfileCodable? {
        didSet {
            guard let profile = userProfile else { return }
            print(profile.users?.first as Any)
            if let userDetails = profile.users?.first {
                self.setupData(details: userDetails)
            } else {
                fatalError("Fail TO unwrap user details")
            }
            if let dids = profile.dids {
                let arr = dids.map { $0.number }.compactMap { $0 }
                print(arr)
                let didStr = arr.joined(separator: ", ")
                assignedDIDs = didStr
            }
        }
    }
    internal var firstName:String? {
        didSet {
            if let text = firstName {
                self.firstNameTextField.text = text
            }
        }
    }
    internal var lastName:String? {
        didSet {
            if let text = lastName {
                self.lastNameTextField.text = text
            }
        }
    }
    internal var email:String? {
        didSet {
            if let text = email {
                self.emailTextField.text = text
            }
        }
    }
    internal var assignedDIDs:String? {
        didSet {
            if let text = assignedDIDs {
                self.assignDIDsTextField.text = text
            }
        }
    }
    internal var phoneNumber:String? {
        didSet {
            if let text = phoneNumber {
                self.phoneNumberTextField.text = text
            }
        }
    }
    internal var contactEmail:String? {
        didSet {
            if let text = contactEmail {
                self.contactEmailTextField.text = text
            }
        }
    }
    internal var address:String? {
        didSet {
            if let text = address {
                self.addressTextField.text = text
            }
        }
    }
    override func loadView() {
        super.loadView()
        setupViews()
//        setupConstraints()
    }
    let userId = UserDefaults.standard.currentSender.id
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpNavBarItems()
        
        hideKeyboardWhenTappedAround()
        setupTextFields()
        setupTextFieldsDelegates()
//        setupData()
        scrollView.delegate = self
        
        scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y), animated: true)
        self.initiateFetchUserProfileSequence(userId: userId)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    func setupData(details:UserProfileCodable.User) {
        let role = CustomUtils.shared.getUserRole()
        let first_name = details.name
        let last_name = details.lastName
        let initialsText = "\(first_name?.first?.uppercased() ?? "X")\(last_name?.first?.uppercased() ?? "D")"
    
    profileImageView.loadImageUsingCacheWithURLString(details.profileImageUrl, placeHolder: UIImage.placeholderInitialsImage(text: initialsText))
        userNameLabel.text = "\(first_name?.uppercased() ?? "") \(last_name?.uppercased() ?? "")"
        userDesignationLabel.text = "\(String(describing: role))  |"
        firstName = first_name
        lastName = last_name
        email = details.email
        phoneNumber = details.phoneNumber
        contactEmail = details.backupEmail
        address = details.address
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "SETTINGS"
        observeKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotificationsObservers()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setUpNavBarItems() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleRightBarButtonItem))
        let normalStateAttributes = [NSAttributedString.Key.font: UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)!,
                                     NSAttributedString.Key.foregroundColor: UIColor.telaRed]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(normalStateAttributes, for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(normalStateAttributes, for: .highlighted)
    }
    @objc func handleRightBarButtonItem() {
        let alertVC = UIAlertController.telaAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?")
        alertVC.addAction(UIAlertAction(title: "Log Out", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
            self.callSignOutSequence()
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    fileprivate func setupViews() {
        view.addSubview(placeholderLabel)
        view.addSubview(refreshButton)
        
        setupScrollViewSubviews()
        view.addSubview(scrollView)
    }
    fileprivate func setupConstraints() {
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive = true
        refreshButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        refreshButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        setupScrollViewSubviewsConstraints()
        
//        scrollView.subviews.forEach({ $0.widthAnchor.constraint(equalTo: self.view.widthAnchor).activate() })
    }
    
    private func signOut() {
        let loginViewController = LoginViewController()
        UserDefaults.standard.setIsLoggedIn(value: false)
        UserDefaults.clearUserData()
        DispatchQueue.main.async {
            guard let tbc = self.tabBarController as? TabBarController else {
                print("No Tab bar")
                return
            }
            tbc.isLoaded = false
            tbc.present(loginViewController, animated: true, completion: {
                tbc.selectedViewController?.view.isHidden = true
                tbc.viewControllers = nil
            })
        }
    }
    fileprivate func dumpCoreDataStorage() {
        do {
            
            let context = PersistenceService.shared.persistentContainer.viewContext
            let entityNames = [String(describing: ExternalConversation.self), String(describing: InternalConversation.self), String(describing: Permission.self), String(describing: UserObject.self)]
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                do {
                    let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                    _ = objects.map{$0.map{context.delete($0)}}
                    PersistenceService.shared.saveContext()
                } catch let error {
                    print("ERROR DELETING : \(error)")
                }
            }
        }
    }
    func callSignOutSequence() {
        print("Signing out")
        FirebaseAuthService.shared.signOut { (error) in
            guard error == nil else {
                UIAlertController.showTelaAlert(title: "Signout Failed", message: error?.localizedDescription ?? "Try again", controller: self)
                return
            }
            self.dumpCoreDataStorage()
            self.signOut()
        }
    }
    
    
    let placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Turn on Mobile Data or Wifi to Access Telabook"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    let refreshButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        button.addTarget(self, action: #selector(handleRefreshAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    @objc func handleRefreshAction() {
        self.placeholderLabel.isHidden = true
        self.refreshButton.isHidden = true
        self.initiateFetchUserProfileSequence(userId: userId) 
    }
    
    let scrollView:UIScrollView = {
        let view = UIScrollView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceHorizontal = false
        view.indicatorStyle = UIScrollView.IndicatorStyle.white
        view.isDirectionalLockEnabled = true
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    fileprivate func setupScrollViewSubviews() {
        setupTopContainerView()
        scrollView.addSubview(profileHeaderView)
        setupTextFieldContainerViews()
        scrollView.addSubview(updateButton)
    }
    fileprivate func setupScrollViewSubviewsConstraints() {
        setupTopContainerConstraints()
        profileHeaderView.anchor(top: topContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        setupTextFieldContainerViewsConstraints()
        updateButton.topAnchor.constraint(equalTo: addressTextFieldContainerView.bottomAnchor, constant: 40).activate()
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        updateButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).activate()
    }
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    let userNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)
        return label
    }()
    let userDesignationLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14.0)
        return label
    }()
    let changePasswordButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change Password", for: .normal)
        button.setTitleColor(.telaBlue, for: .normal)
        button.isEnabled = true
        button.addTarget(self, action: #selector(handleChangePassword), for: .touchUpInside)
        return button
    }()
    @objc fileprivate func handleChangePassword() {
        print("Change Password Called")
    }
    let topContainerView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.telaGray5.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        return view
    }()
    fileprivate func setupTopContainerView() {
        topContainerView.addSubview(profileImageView)
        topContainerView.addSubview(userNameLabel)
        topContainerView.addSubview(userDesignationLabel)
        topContainerView.addSubview(changePasswordButton)
        scrollView.addSubview(topContainerView)
    }
    fileprivate func setupTopContainerConstraints() {
        profileImageView.anchor(top: topContainerView.topAnchor, left: topContainerView.leftAnchor, bottom: topContainerView.bottomAnchor, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 20, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        userNameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: topContainerView.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -15).activate()
        userDesignationLabel.anchor(top: nil, left: userNameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        userDesignationLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 15).activate()
        changePasswordButton.anchor(top: nil, left: userDesignationLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        changePasswordButton.centerYAnchor.constraint(equalTo: userDesignationLabel.centerYAnchor).activate()
        topContainerView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 0)
        
    }
    
    fileprivate func setupTextFields() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .emailAddress
        emailTextField.isEnabled = false
        assignDIDsTextField.keyboardType = .phonePad
        assignDIDsTextField.textContentType = .telephoneNumber
        assignDIDsTextField.isEnabled = false
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.textContentType = .telephoneNumber
        contactEmailTextField.keyboardType = .emailAddress
        contactEmailTextField.textContentType = .emailAddress
    }
    fileprivate func setupTextFieldsDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        assignDIDsTextField.delegate = self
        phoneNumberTextField.delegate = self
        contactEmailTextField.delegate = self
        addressTextField.delegate = self
    }
    
    let firstNameTextField = createTextField(placeholder: "First Name")
    let lastNameTextField = createTextField(placeholder: "Last Name")
    let emailTextField = createTextField(placeholder: "Email")
    let assignDIDsTextField = createTextField(placeholder: "Assign DIDs")
    let phoneNumberTextField = createTextField(placeholder: "Phone Number")
    let contactEmailTextField = createTextField(placeholder: "Contact Email")
    let addressTextField = createTextField(placeholder: "Address")
    
    lazy var firstNameTextFieldContainerView = createTextFieldContainerView(labelTitle: "First Name", firstNameTextField)
    lazy var lastNameTextFieldContainerView = createTextFieldContainerView(labelTitle: "Last Name", lastNameTextField)
    lazy var emailTextFieldContainerView = createTextFieldContainerView(labelTitle: "Email", emailTextField)
    lazy var assignDIDsTextFieldContainerView = createTextFieldContainerView(labelTitle: "Assign DIDs", assignDIDsTextField)
    lazy var phoneNumberTextFieldContainerView = createTextFieldContainerView(labelTitle: "Phone Number", phoneNumberTextField)
    lazy var contactEmailTextFieldContainerView = createTextFieldContainerView(labelTitle: "Contact Email", contactEmailTextField)
    lazy var addressTextFieldContainerView = createTextFieldContainerView(labelTitle: "Address", addressTextField)
    
    
    
    
    fileprivate func setupTextFieldContainerViews() {
        scrollView.addSubview(firstNameTextFieldContainerView)
        scrollView.addSubview(lastNameTextFieldContainerView)
        scrollView.addSubview(emailTextFieldContainerView)
        scrollView.addSubview(assignDIDsTextFieldContainerView)
        scrollView.addSubview(phoneNumberTextFieldContainerView)
        scrollView.addSubview(contactEmailTextFieldContainerView)
        scrollView.addSubview(addressTextFieldContainerView)
    }
    fileprivate func setupTextFieldContainerViewsConstraints() {
        let width = self.view.frame.width
        let height:CGFloat = 50.0
        firstNameTextFieldContainerView.anchor(top: profileHeaderView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        lastNameTextFieldContainerView.anchor(top: firstNameTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        emailTextFieldContainerView.anchor(top: lastNameTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        assignDIDsTextFieldContainerView.anchor(top: emailTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        phoneNumberTextFieldContainerView.anchor(top: assignDIDsTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        contactEmailTextFieldContainerView.anchor(top: phoneNumberTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        addressTextFieldContainerView.anchor(top: contactEmailTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
    }
    
    let profileHeaderView = createHeaderView(title: "Profile")
    let updateButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Update", for: UIControl.State.normal)
        button.setTitleColor(.telaGray5, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.isEnabled = false
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.telaGray6
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc fileprivate func updateButtonTapped() {
        print("Updating...")
    }
    static func createTextField(placeholder:String? = nil) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        if let placeholderText = placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: UIColor.telaGray5])
        }
        textField.textColor = UIColor.telaGray7
        textField.textAlignment = .left
        textField.keyboardAppearance = .dark
        textField.borderStyle = .none
        return textField
    }
    

    func createTextFieldContainerView(labelTitle:String, _ textField:UITextField) -> UIView {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = labelTitle
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 13.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        
        let expectedTextSize = ("Phone Number" as NSString).size(withAttributes: [.font: label.font!])
        let width = expectedTextSize.width + 10
    
        let separator = Line()
        
        container.addSubview(label)
        container.addSubview(textField)
        container.addSubview(separator)
        
        label.anchor(top: nil, left: container.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: textField.centerYAnchor).activate()
        textField.anchor(top: container.topAnchor, left: label.rightAnchor, bottom: separator.topAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        separator.anchor(top: nil, left: textField.leftAnchor, bottom: container.bottomAnchor, right: textField.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        return container
    }
    static func createHeaderView(title:String) -> UIView {
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        label.anchor(top: nil, left: headerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        return headerView
    }
    
    
    
    
    
    
    var activeField:UITextField?
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    fileprivate func removeKeyboardNotificationsObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            let contentInsets: UIEdgeInsets = .zero
            
            self.scrollView.contentInset = contentInsets
            
            self.scrollView.scrollIndicatorInsets = contentInsets
            

//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    @objc func keyboardShow(notification:NSNotification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight:CGFloat = keyboardSize?.height ?? 280.0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + 50.0, right: 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
//            self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardHeight)
            
//            var frame: CGRect = self.view.frame
//            frame.size.height -= keyboardHeight
//            let activeFieldFrameOrigin:CGPoint = self.activeField!.frame.origin
//
//            if !frame.contains(activeFieldFrameOrigin) {
//                print("Positive")
//                self.scrollView.scrollRectToVisible(self.activeField!.frame, animated: true)
//
//            }
//            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -iPadKeyboardHeight : -keyboardHeight
//            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
}
extension SettingsViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        view.endEditing(true)
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//    }

}
extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeField = nil
        
    }
}






class Line:UIView {
    init(color: UIColor = UIColor.telaGray6) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = color
        self.layer.opacity = 0.5
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder hasn't been implemented.")
    }
}

