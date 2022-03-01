//
//  SettingsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    var uploadTask: StorageUploadTask!
    
    var userProfile: UserProperties? {
        didSet {
            guard let profile = userProfile else { return }
//            if let userDetails = profile.user {
                self.setupData(details: profile)
//            } else {
//                fatalError("Fail to unwrap user details")
//            }
            /*
            if let did = profile.did {
//                let arr = dids.map { $0.number }.compactMap { $0 }
                assignedDIDs = did.number
            }
             */
//            if let dids = profile.user?.did {
//                let arr = dids.map { $0.number }.compactMap { $0 }
//                #if !RELEASE
//                print("Assigned DIDs: \(arr)")
//                #endif
//                let didStr = arr.joined(separator: ", ")
//                assignedDIDs = didStr
//            }
        }
    }
    internal var profileImage:String?
    internal var profileImageUrl:String? {
        didSet {
            let initialsText = "\(firstName?.first?.uppercased() ?? "")\(lastName?.first?.uppercased() ?? "")"
            let placeholderImage = UIImage.placeholderInitialsImage(text: initialsText)
            if let urlStr = profileImageUrl {
                self.profileImageView.pin_setImage(from: URL(string: urlStr), placeholderImage: placeholderImage)
//                self.profileImageView.loadImageUsingCache(with: url, placeHolder: UIImage.placeholderInitialsImage(text: initialsText))
            } else {
                self.profileImageView.image = placeholderImage
//                self.profileImageView.loadImageUsingCache(with: nil, placeHolder: placeholderImage)
            }
//            validateFields()
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
    /*
    internal var assignedDIDs:String? {
        didSet {
            if let text = assignedDIDs {
                self.assignDIDsTextField.text = text
            }
        }
    }
    */
    internal var phoneNumber:String? {
        didSet {
            if let text = phoneNumber {
                self.phoneNumberTextField.text = text.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? text
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
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotificationsObservers()
    }
    
    var topBarHeight: CGFloat {
        return (UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    
    private func commonInit() {
        title = "SETTINGS"
        view.backgroundColor = .telaGray1
        configureHierarchy()
        configureNavigationBarAppearance()
        hideKeyboardWhenTappedAround()
        configureTextFields()
        
        scrollView.contentInset = UIEdgeInsets(top: topBarHeight, left: 0, bottom: 0, right: 0)
        setupTextFieldsDelegates()
        userProfile = AppData.userInfo
        fetchUserProfile()
        configureProgressAlert()
        configureProfileImageView()
    }
    private func configureProfileImageView() {
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageViewDidTap)))
    }
    @objc
    private func profileImageViewDidTap() {
        guard let image = profileImageView.image else { return }
        
        let frame = view.convert(profileImageView.frame, from: topContainerView)
        let vc = FullImageViewController(image: image, fromRect: frame)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
    
    func setupUserData(details:UserProfileCodable.User) {
        let role = CustomUtils.shared.getUserRole()
        let first_name = details.name
        let last_name = details.lastName
        profileImageUrl = details.profileImageUrl
        profileImage = details.profileImage
        userNameLabel.text = "\(first_name?.uppercased() ?? "") \(last_name?.uppercased() ?? "")"
        userDesignationLabel.text = "\(String(describing: role))  |"
        firstName = first_name
        lastName = last_name
        email = details.email
        phoneNumber = details.phoneNumber
        contactEmail = details.backupEmail
        address = details.address
    }
    
    func setupData(details: UserProperties) {
        let role = AppData.getUserRole()
        let first_name = details.name
        let last_name = details.lastName
        profileImageUrl = details.profileImageUrl
        profileImage = details.profileImage
        userNameLabel.text = "\(first_name?.uppercased() ?? "") \(last_name?.uppercased() ?? "")"
        userDesignationLabel.text = "\(String(describing: role))  |"
        firstName = first_name
        lastName = last_name
        email = details.email
        phoneNumber = details.phone
        contactEmail = details.contactEmail ?? ""
        address = details.address
    }
    
    
    fileprivate func configureHierarchy() {
        view.addSubview(placeholderLabel)
        view.addSubview(refreshButton)
        
        setupScrollViewSubviews()
        view.addSubview(scrollView)
    }
    fileprivate func setupConstraints() {
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        refreshButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setupScrollViewSubviewsConstraints()
        
//        scrollView.subviews.forEach({ $0.widthAnchor.constraint(equalTo: self.view.widthAnchor).activate() })
    }
    
    
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Turn on Mobile Data or Wifi to Access \(Config.appName)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var refreshButton:UIButton = {
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
        self.fetchUserProfile()
    }
    
    lazy var scrollView:UIScrollView = {
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
        scrollView.addSubview(spinner)
    }
    fileprivate func setupScrollViewSubviewsConstraints() {
        setupTopContainerConstraints()
        profileHeaderView.anchor(top: topContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        setupTextFieldContainerViewsConstraints()
        updateButton.topAnchor.constraint(equalTo: addressTextFieldContainerView.bottomAnchor, constant: 40).activate()
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        updateButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).activate()
        spinner.centerXAnchor.constraint(equalTo: updateButton.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: updateButton.centerYAnchor).activate()
    }
    

    
    lazy var progressAlert:UIAlertController = {
        let alert = UIAlertController.telaAlertController(title: "Uploading...")
        return alert
    }()
    lazy var progressTitleLabel:UILabel = {
        let label = UILabel()
        let margin:CGFloat = 8.0
        let alertWidth:CGFloat = 270.0
        let frame = CGRect(x: margin, y: 50.0, width: alertWidth - margin * 2.0 , height: 20)
        label.frame = frame
        label.textAlignment = .center
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)
        label.text = "0 %"
        label.textColor = UIColor.white
        return label
    }()
    lazy var progressBar:UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        let margin:CGFloat = 8.0
        let alertWidth:CGFloat = 270.0
        let frame = CGRect(x: margin, y: 80.0, width: alertWidth - margin * 2.0 , height: 2.0)
        view.frame = frame
        view.progressTintColor = UIColor.telaBlue
        view.setProgress(0, animated: false)
        return view
    }()
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.telaGray6
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "placeholder.png")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var cameraIconImageView:UIImageView = {
        let imageView = UIImageView()
        let inset:CGFloat = 2.0
        
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "camera_icon").withInsets(UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
        imageView.backgroundColor = UIColor.telaGray1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 14
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.telaGray6.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(camerIconTapped)))
//        imageView.clipsToBounds = true
//        imageView.layer.masksToBounds = true
        return imageView
    }()
    @objc fileprivate func camerIconTapped() {
        guard isDataValid() else {
            UIAlertController.showTelaAlert(title: "Missing Data", message: "Please fill up the required fields first.")
            return
        }
        promptPhotosPickerMenu()
    }
    lazy var userNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaWhite
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)
        return label
    }()
    lazy var userDesignationLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14.0)
        return label
    }()
    lazy var changePasswordButton:UIButton = {
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
        let vc = ChangePasswordViewController()
        self.show(vc, sender: self)
    }
    lazy var topContainerView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.telaGray5.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        return view
    }()
    fileprivate func setupTopContainerView() {
        topContainerView.isUserInteractionEnabled = true
        topContainerView.addSubview(cameraIconImageView)
        topContainerView.addSubview(profileImageView)
        topContainerView.bringSubviewToFront(cameraIconImageView)
        topContainerView.addSubview(userNameLabel)
        topContainerView.addSubview(userDesignationLabel)
        topContainerView.addSubview(changePasswordButton)
        scrollView.addSubview(topContainerView)
    }
    fileprivate func setupTopContainerConstraints() {
        profileImageView.anchor(top: topContainerView.topAnchor, left: topContainerView.leftAnchor, bottom: topContainerView.bottomAnchor, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 20, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        cameraIconImageView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).activate()
        cameraIconImageView.centerYAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5).activate()
        cameraIconImageView.widthAnchor.constraint(equalToConstant: 28).activate()
        cameraIconImageView.heightAnchor.constraint(equalToConstant: 28).activate()
        userNameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: topContainerView.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -15).activate()
        userDesignationLabel.anchor(top: nil, left: userNameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        userDesignationLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 15).activate()
        changePasswordButton.anchor(top: nil, left: userDesignationLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        changePasswordButton.centerYAnchor.constraint(equalTo: userDesignationLabel.centerYAnchor).activate()
        topContainerView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 0)
        
    }
    
    fileprivate func configureTextFields() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .emailAddress
        emailTextField.isEnabled = false
        emailTextField.textColor = .telaGray6
        
        /*
        assignDIDsTextField.keyboardType = .phonePad
        assignDIDsTextField.textContentType = .telephoneNumber
        assignDIDsTextField.isEnabled = false
        assignDIDsTextField.textColor = .telaGray6
        */
        
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.textContentType = .telephoneNumber
        
        contactEmailTextField.keyboardType = .emailAddress
        contactEmailTextField.textContentType = .emailAddress
        
        /*
        firstNameTextField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        contactEmailTextField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        */
    }
    /*
    @objc fileprivate func didChangeTextField(textField:UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                self.disableUpdateButton()
            } else {
                self.validateFields()
            }
        } else { self.disableUpdateButton() }
    }
    */
    func isDataValid() -> Bool {
        guard let first_name = self.firstNameTextField.text,
            let last_name = self.lastNameTextField.text,
            let phone_number = self.phoneNumberTextField.text,
            let backup_email = self.contactEmailTextField.text,
            let user_address = self.addressTextField.text,
            !first_name.isBlank,
            !last_name.isBlank,
            phone_number.extractNumbers.isPhoneNumberLengthValid(),
            backup_email.isValidEmailAddress(),
            !user_address.isBlank else {
                return false
            }
        return true
    }
    /*
    fileprivate func validateFields() {
        if isDataValid() {
            enableUpdateButton()
        } else {
            disableUpdateButton()
        }
    }
    
    internal func enableUpdateButton() {
        updateButton.isEnabled = true
        UIView.animate(withDuration: 0.4) {
            self.updateButton.backgroundColor = UIColor.telaBlue
        }
    }
    internal func disableUpdateButton() {
        updateButton.isEnabled = false
        UIView.animate(withDuration: 0.4) {
            self.updateButton.backgroundColor = UIColor.telaGray6
        }
    }
 */
    fileprivate func setupTextFieldsDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
//        assignDIDsTextField.delegate = self
        phoneNumberTextField.delegate = self
        contactEmailTextField.delegate = self
        addressTextField.delegate = self
    }
    
    lazy var firstNameTextField = createTextField(placeholder: "First Name")
    lazy var lastNameTextField = createTextField(placeholder: "Last Name")
    lazy var emailTextField = createTextField(placeholder: "Email")
//    lazy var assignDIDsTextField = createTextField(placeholder: "Assign DIDs")
//    lazy var phoneNumberTextField = createTextField(placeholder: "Phone Number")
    lazy var phoneNumberTextField:UITextField = {
        let textField = UITextField()
        let font = UIFont.systemFont(ofSize: 14)
        let spacing:Double = 1.5
        textField.attributedPlaceholder = NSAttributedString(string: "(123) 456-7890", attributes: [
            .font: font,
            .foregroundColor: UIColor.telaGray7,
            .kern: spacing
        ])
        textField.defaultTextAttributes = [
            .font: font,
            .kern: spacing,
            .foregroundColor: UIColor.white
        ]
        textField.tintColor = .white
        textField.setDefault(string: "+1", withFont: font, characterSpacing: spacing, at: .Left, withRightSpacing: 6)
        textField.keyboardType = UIKeyboardType.numberPad
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.textContentType = UITextContentType.telephoneNumber
        return textField
    }()
    lazy var contactEmailTextField = createTextField(placeholder: "Contact Email")
    lazy var addressTextField = createTextField(placeholder: "Address")
    
    lazy var firstNameTextFieldContainerView = createTextFieldContainerView(labelTitle: "First Name", firstNameTextField)
    lazy var lastNameTextFieldContainerView = createTextFieldContainerView(labelTitle: "Last Name", lastNameTextField)
    lazy var emailTextFieldContainerView = createTextFieldContainerView(labelTitle: "Email", emailTextField)
//    lazy var assignDIDsTextFieldContainerView = createTextFieldContainerView(labelTitle: "Assign DIDs", assignDIDsTextField)
    lazy var phoneNumberTextFieldContainerView = createTextFieldContainerView(labelTitle: "Phone Number", phoneNumberTextField)
    lazy var contactEmailTextFieldContainerView = createTextFieldContainerView(labelTitle: "Contact Email", contactEmailTextField)
    lazy var addressTextFieldContainerView = createTextFieldContainerView(labelTitle: "Address", addressTextField)
    
    
    
    
    fileprivate func setupTextFieldContainerViews() {
        scrollView.addSubview(firstNameTextFieldContainerView)
        scrollView.addSubview(lastNameTextFieldContainerView)
        scrollView.addSubview(emailTextFieldContainerView)
//        scrollView.addSubview(assignDIDsTextFieldContainerView)
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
//        assignDIDsTextFieldContainerView.anchor(top: emailTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        phoneNumberTextFieldContainerView.anchor(top: emailTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        contactEmailTextFieldContainerView.anchor(top: phoneNumberTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
        addressTextFieldContainerView.anchor(top: contactEmailTextFieldContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
    }
    
    lazy var profileHeaderView = createHeaderView(title: "PROFILE")
    lazy var updateButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Update", for: UIControl.State.normal)
        button.setTitleColor(.telaGray5, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.telaBlue
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc fileprivate func updateButtonTapped() {
        guard let first_name = self.firstNameTextField.text,
              !first_name.isBlank else {
            firstNameTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard let last_name = self.lastNameTextField.text,
              !last_name.isBlank else {
            lastNameTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard let phone_number = self.phoneNumberTextField.text,
              phone_number.extractNumbers.isPhoneNumberLengthValid() else {
            phoneNumberTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard let contact_email = self.contactEmailTextField.text,
              contact_email.isValidEmailAddress() else {
            contactEmailTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard let user_address = self.addressTextField.text,
              !user_address.isBlank else {
            addressTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        
        TapticEngine.generateFeedback(ofType: .Medium)
        self.updateUserProfile()
//        initiateUpdateUserProfileSequence()
    }
    func createTextField(placeholder:String? = nil) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 14)
        if let placeholderText = placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: UIColor.telaGray7])
        }
        textField.textColor = UIColor.white
        textField.tintColor = .white
        textField.textAlignment = .left
        textField.keyboardAppearance = .dark
        textField.borderStyle = .none
        return textField
    }
    

    func createTextFieldContainerView(labelTitle: String, _ textField: UITextField) -> UIView {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = labelTitle
        label.textColor = UIColor.secondaryLabel
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .left
        label.numberOfLines = 1
        
        let expectedTextSize = ("Phone Number" as NSString).size(withAttributes: [.font: label.font!])
        let width = expectedTextSize.width + 5
    
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
    func createHeaderView(title: String) -> UIView {
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
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: self.topBarHeight, left: 0, bottom: 0, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }, completion: nil)
    }
    @objc func keyboardShow(notification:NSNotification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight:CGFloat = keyboardSize?.height ?? 280.0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: self.topBarHeight, left: 0.0, bottom: keyboardHeight + 50.0, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }, completion: nil)
    }
    
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == phoneNumberTextField, let text = textField.text else { return true }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = newString.replacingOccurrences(of: "+1", with: "").extractNumbers.formatNumber()
        return false
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



