//
//  CustomerDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 20/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class CustomerDetailsViewController: UIViewController {
    var delegate:CustomerDetailsDelegate?
    var customerId = Int()
    var workerId = Int()
    var internalBook:InternalBookCodable.InternalBook? {
        didSet {
            guard let book = internalBook else {
                print("Internal Book value = nil")
                UIAlertController.showTelaAlert(title: "Error", message: "Internal Application Error", controller: self)
                return
            }
            self.setupData(internalBook: book)
        }
    }
    var updatedInternalBook:UpdatedInternalBookCodable? {
        didSet {
            guard let book = updatedInternalBook else {
                print("Updated Internal Book value = nil")
                UIAlertController.showTelaAlert(title: "Error", message: "Internal Application Error", controller: self)
                return
            }
            self.setupUpdatedData(internalBook: book)
        }
    }
    fileprivate func setupUpdatedData(internalBook:UpdatedInternalBookCodable) {
        self.firstName = internalBook.names
        self.lastName = internalBook.surnames
        self.addressOne = internalBook.addressOne
        self.addressTwo = internalBook.addressTwo
        self.customerDescription = internalBook.descriptionField
        self.classificationStar = Int(internalBook.star ?? "0")
        self.isNameActive = Int(internalBook.activeName ?? "0")
        self.isCustomer = Int(internalBook.isCustumer ?? "0")
    }
    fileprivate func setupData(internalBook:InternalBookCodable.InternalBook) {
        self.firstName = internalBook.names
        self.lastName = internalBook.surnames
        self.addressOne = internalBook.addressOne
        self.addressTwo = internalBook.addressTwo
        self.customerDescription = internalBook.descriptionField
        self.classificationStar = internalBook.star
        self.isNameActive = internalBook.activeName
        self.isCustomer = internalBook.isCustumer
    }
    
    var firstName:String? {
        didSet {
            firstNameTextField.text = firstName
        }
    }
    var lastName:String? {
        didSet {
            lastNameTextField.text = lastName
        }
    }
    var addressOne:String? {
        didSet {
            addressOneTextField.text = addressOne
        }
    }
    var addressTwo:String? {
        didSet {
            addressTwoTextField.text = addressTwo
        }
    }
    var customerDescription:String? {
        didSet {
            if let desc = customerDescription {
                if !desc.isEmpty {
                    descriptionLabel.text = desc
                } else {
                    descriptionLabel.text = "None"
                }
            } else {
                descriptionLabel.text = "None"
            }
        }
    }
    var classificationStar:Int? {
        didSet {
            starImageView.image = ConversationPriority.getImage(by: ConversationPriority.getPriority(by: classificationStar ?? 0))
        }
    }
    var isNameActive:Int? {
        didSet {
            if let check = isNameActive {
                if check == 0 {
                    isNameActiveSwitch.isOn = false
                } else if check == 1 {
                    isNameActiveSwitch.isOn = true
                }
            }
        }
    }
    var isCustomer:Int? {
        didSet {
            if let check = isCustomer {
                if check == 0 {
                    isCustomerSwitch.isOn = false
                } else if check == 1 {
                    isCustomerSwitch.isOn = true
                }
            }
        }
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
//        observeKeyboardNotifications()
        hideKeyboardWhenTappedAround()
        self.initiateFetchCustomerDetailsSequence()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(cancelButton)
        view.addSubview(saveButton)
        view.addSubview(headingLabel)
        view.addSubview(placeholderLabel)
        view.addSubview(tryAgainButton)
        
        setupSubviews()
//        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
    }
    fileprivate func setupConstraints() {
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top + 30).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.layoutMargins.left + 15).isActive = true
        saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top + 30).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.layoutMargins.right - 15).isActive = true
        headingLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20).isActive = true
        tryAgainButton.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 20).isActive = true
        tryAgainButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scrollView.anchor(top: headingLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        scrollView.subviews.forEach({ $0.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true })
        setupSubviewsConstraints()
        
    }
    
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Done", attributes: [
            .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 15.0)!,
            .foregroundColor: UIColor.telaBlue
            ]), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    lazy var saveButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Save", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)!,
            .foregroundColor: UIColor.telaBlue
            ]), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func saveButtonTapped() {
        self.initiateUpdateCustomerDetailsSequence()
    }
    let scrollView:UIScrollView = {
        let view = UIScrollView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.bounces = true
        return view
    }()
//    let containerView:UIView = {
//        let view = UIView(frame: CGRect.zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
//        return view
//    }()
    let nameHeaderView = createHeaderView(title: "Name")
    let addressHeaderView = createHeaderView(title: "Address")
    let descriptionHeaderView = createHeaderView(title: "Description")
    let settingsHeaderView = createHeaderView(title: "Settings")
    
    static let headerViewHeight:CGFloat = 25
    static let containerViewHeight:CGFloat = 44
    
    lazy var firstNameTextField = createTextField(placeholder: "First Name")
    lazy var lastNameTextField = createTextField(placeholder: "Last Name")
    lazy var addressOneTextField = createTextField(placeholder: "Address 1")
    lazy var addressTwoTextField = createTextField(placeholder: "Address 2")
    func setupDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        addressOneTextField.delegate = self
        addressTwoTextField.delegate = self
    }

    lazy var firstNameTFContainerView = createTextFieldContainerView(firstNameTextField)
    lazy var lastNameTFContainerView = createTextFieldContainerView(lastNameTextField)
    lazy var addressOneTFContainerView = createTextFieldContainerView(addressOneTextField)
    lazy var addressTwoTFContainerView = createTextFieldContainerView(addressTwoTextField)
    let descriptionLabel:UILabel = {
        let label = UILabel()
        label.text = "None"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    func createDescriptionContainerView() -> UIView {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "front_arrow")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(imageView)
        descriptionLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: imageView.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 40, widthConstant: 0, heightConstant: 0)
        descriptionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 20, heightConstant: 20)
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descriptionContainerTapped)))
        containerView.isUserInteractionEnabled = true
        return containerView
    }
    @objc func descriptionContainerTapped() {
        descriptionContainerView.backgroundColor = UIColor.telaGray6.withAlphaComponent(0.5)
        let descriptionInputVC = TextViewInputController(defaultText: self.customerDescription)
        descriptionInputVC.delegate = self
        descriptionInputVC.view.backgroundColor = UIColor.telaGray1
        descriptionInputVC.modalPresentationStyle = .overFullScreen
        self.present(descriptionInputVC, animated: true, completion: nil)
        UIView.animate(withDuration: 1.0) {
            self.descriptionContainerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        }
    }
    func createStarContainerView() -> UIView {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Classification Star"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let indicatorImageView = UIImageView()
        indicatorImageView.image = #imageLiteral(resourceName: "front_arrow")
        indicatorImageView.contentMode = .scaleAspectFill
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        indicatorImageView.clipsToBounds = true
        
    containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(starContainerTapped)))
        containerView.isUserInteractionEnabled = true
        containerView.addSubview(label)
        containerView.addSubview(starImageView)
        containerView.addSubview(indicatorImageView)
        label.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: starImageView.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        starImageView.anchor(top: nil, left: nil, bottom: nil, right: indicatorImageView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        starImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        indicatorImageView.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 20, heightConstant: 20)
        indicatorImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
    
    @objc func starContainerTapped() {
        starContainerView.backgroundColor = UIColor.telaGray6.withAlphaComponent(0.5)
        promptStarOptions()
        UIView.animate(withDuration: 1.0) {
            self.starContainerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        }
        
    }
    internal func promptStarOptions() {
        let alert = UIAlertController(title: "Select Classification Star", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let grayStar = UIAlertAction(title: "Low", style: UIAlertAction.Style.default, handler: { (action) in
            self.classificationStar = ConversationPriority.getPriorityCode(by: .Low)
        })
        
        let yellowStar = UIAlertAction(title: "Medium", style: UIAlertAction.Style.default, handler: { (action) in
            self.classificationStar = ConversationPriority.getPriorityCode(by: .Medium)
        })
        let redAction = UIAlertAction(title: "High", style: UIAlertAction.Style.default, handler: { (action) in
            self.classificationStar = ConversationPriority.getPriorityCode(by: .High)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(grayStar)
        alert.addAction(yellowStar)
        alert.addAction(redAction)
        alert.addAction(cancelAction)
    alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        
        alert.view.tintColor = UIColor.telaBlue
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alert.view.subviews.first?.backgroundColor = .clear
        self.present(alert, animated: true, completion: nil)
    }
    func createCustomerSwitchContainerView() -> UIView {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Mark as Customer"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        containerView.addSubview(isCustomerSwitch)
        label.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: isCustomerSwitch.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        isCustomerSwitch.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        isCustomerSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
    func createNameActiveSwitchContainerView() -> UIView {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Name Customized by Agent"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        containerView.addSubview(isNameActiveSwitch)
        label.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: isNameActiveSwitch.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        isNameActiveSwitch.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        isNameActiveSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
    let isCustomerSwitch:UISwitch = {
        let switchButton = UISwitch()
        switchButton.tintColor = UIColor.telaGray5
        switchButton.thumbTintColor = UIColor.telaWhite
        switchButton.onTintColor = UIColor.telaBlue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.addTarget(self, action: #selector(test(switchV:)), for: .allEvents)
        return switchButton
    }()
    @objc func test(switchV: UISwitch) {
        print(switchV.state)
        print("isON => \(switchV.isOn)")
    }
    let isNameActiveSwitch:UISwitch = {
        let switchButton = UISwitch()
        switchButton.tintColor = UIColor.telaGray5
        switchButton.thumbTintColor = UIColor.telaWhite
        switchButton.onTintColor = UIColor.telaBlue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    let starImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "followup_low")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    fileprivate func setupSubviews() {
        scrollView.addSubview(nameHeaderView)
        scrollView.addSubview(firstNameTFContainerView)
        scrollView.addSubview(lastNameTFContainerView)
        scrollView.addSubview(addressHeaderView)
        scrollView.addSubview(addressOneTFContainerView)
        scrollView.addSubview(addressTwoTFContainerView)
        scrollView.addSubview(descriptionHeaderView)
        scrollView.addSubview(descriptionContainerView)
        scrollView.addSubview(settingsHeaderView)
        scrollView.addSubview(starContainerView)
        scrollView.addSubview(isNameActiveContainerView)
        scrollView.addSubview(isCustomerContainerView)
    }
    fileprivate func setupNameSectionConstraints() {
        let headerHeight = CustomerDetailsViewController.headerViewHeight
        let containerHeight = CustomerDetailsViewController.containerViewHeight
        
        nameHeaderView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: headerHeight)
        firstNameTFContainerView.anchor(top: nameHeaderView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
        lastNameTFContainerView.anchor(top: firstNameTFContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
    }
    fileprivate func setupAddressSectionConstraints() {
        let headerHeight = CustomerDetailsViewController.headerViewHeight
        let containerHeight = CustomerDetailsViewController.containerViewHeight
        
        addressHeaderView.anchor(top: lastNameTFContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: headerHeight)
        addressOneTFContainerView.anchor(top: addressHeaderView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
        addressTwoTFContainerView.anchor(top: addressOneTFContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
    }
    fileprivate func setupDescriptionSectionConstraints() {
        let headerHeight = CustomerDetailsViewController.headerViewHeight
        let containerHeight = CustomerDetailsViewController.containerViewHeight
        
        descriptionHeaderView.anchor(top: addressTwoTFContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: headerHeight)
        descriptionContainerView.anchor(top: descriptionHeaderView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
    }
    fileprivate func setupSettingsSectionConstraints() {
        let headerHeight = CustomerDetailsViewController.headerViewHeight
        let containerHeight = CustomerDetailsViewController.containerViewHeight
        
        settingsHeaderView.anchor(top: descriptionContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: headerHeight)
        starContainerView.anchor(top: settingsHeaderView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
        isNameActiveContainerView.anchor(top: starContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
        isCustomerContainerView.anchor(top: isNameActiveContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerHeight)
    }
    fileprivate func setupSubviewsConstraints() {
        setupNameSectionConstraints()
        setupAddressSectionConstraints()
        setupDescriptionSectionConstraints()
        setupSettingsSectionConstraints()
    }
    lazy var descriptionContainerView = createDescriptionContainerView()
    lazy var starContainerView = createStarContainerView()
    lazy var isCustomerContainerView = createCustomerSwitchContainerView()
    lazy var isNameActiveContainerView = createNameActiveSwitchContainerView()
    
    func createTextFieldContainerView(_ textField:UITextField) -> UIView {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
        container.addSubview(textField)
        textField.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        return container
    }
    
    
    func createTextField(placeholder:String? = nil) -> UITextField {
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
        
//        textField.isEnabled = true
//        textField.isUserInteractionEnabled = true
        return textField
    }
    @objc func abc() {
        print("Touch")
    }
    let test:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        textField.placeholder = "Test Placeholder"
        textField.textColor = UIColor.telaGray7
        textField.textAlignment = .left
        textField.keyboardAppearance = .dark
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(abc), for: UIControl.Event.allTouchEvents)
        return textField
    }()
    static func createHeaderView(title:String) -> UIView {
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.telaGray4
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        label.anchor(top: nil, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        return headerView
    }
    let headingLabel:UILabel = {
        let label = UILabel()
        label.text = "Customer Details"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 20)
        label.textColor = .telaBlue
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
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
    lazy var tryAgainButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TRY AGAIN", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        button.addTarget(self, action: #selector(handleTryAgainAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    @objc func handleTryAgainAction() {
        self.setPlaceholdersViewsState(isHidden: true)
        self.setViewsState(isHidden: true)
        self.initiateFetchCustomerDetailsSequence()
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.tryAgainButton.isHidden = isHidden
    }
    fileprivate func setViewsState(isHidden: Bool) {
        
    }
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    @objc func keyboardShow() {
        let iPhoneKeyboardHeight:CGFloat = 100
        let iPadKeyboardHeight:CGFloat = 100
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -iPadKeyboardHeight : -iPhoneKeyboardHeight
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func startSpinner() {
        OverlaySpinner.shared.spinner(mark: .Start)
    }
    fileprivate func stopSpinner() {
        OverlaySpinner.shared.spinner(mark: .Stop)
    }
    fileprivate func initiateUpdateCustomerDetailsSequence() {
        DispatchQueue.main.async {
            self.startSpinner()
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.stopSpinner()
                    UIAlertController.showTelaAlert(title: "Error", message: err.localizedDescription, controller: self)
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    
                    self.updateCustomerDetails(token: token)
                }
            }
        }
    }
    fileprivate func updateCustomerDetails(token:String) {
      
        
    }
    
    
    
    
    fileprivate func initiateFetchCustomerDetailsSequence() {
        DispatchQueue.main.async {
            self.startSpinner()
        }
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.stopSpinner()
                    self.setPlaceholdersViewsState(isHidden: false)
                    self.setViewsState(isHidden: true)
                    self.placeholderLabel.text = err.localizedDescription
                }
            } else if let token = token {
                DispatchQueue.main.async {
                    print("Customer ID here => \(self.customerId)")
                    self.fetchCustomerDetails(token: token, customerId: String(self.customerId))
                }
            }
        }
    }
    
    
    fileprivate func fetchCustomerDetails(token:String, customerId:String) {
        
    }
}
extension CustomerDetailsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Begin")
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("End")
    }
}
extension CustomerDetailsViewController: CustomerDescriptionInputDelegate {
    func saveDescription(text: String) {
        self.customerDescription = text
    }
}
protocol CustomerDetailsDelegate {
    func triggerUpdate()
}



class TextViewInputController:UIViewController {
    var delegate:CustomerDescriptionInputDelegate?
    init(defaultText:String? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let text = defaultText {
            self.descriptionTextView.text = text
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.becomeFirstResponder()
//        observeKeyboardNotifications()
    }
    fileprivate func setupViews() {
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(descriptionTextView)
    }
    fileprivate func setupConstraints() {
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top + 30).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.layoutMargins.left + 15).isActive = true
        doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top + 30).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.layoutMargins.right - 15).isActive = true
        descriptionTextView.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor, bottom: view.centerYAnchor, right: view.rightAnchor, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [
            .font : UIFont(name: CustomFonts.gothamBook.rawValue, size: 15.0)!,
            .foregroundColor: UIColor.telaBlue
            ]), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    lazy var doneButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Save", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16.0)!,
            .foregroundColor: UIColor.telaBlue
            ]), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func doneButtonTapped() {
        self.delegate?.saveDescription(text: self.descriptionTextView.text)
        self.dismiss(animated: true, completion: nil)
    }
    let descriptionTextView:UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.textAlignment = .left
        textView.isSelectable = true
        textView.backgroundColor = UIColor.telaGray4
        textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        textView.textColor = UIColor.telaGray7
        textView.sizeToFit()
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = .all
        textView.keyboardAppearance = .dark
//        let fixedWidth = textView.frame.size.width
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        return textView
    }()
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    @objc func keyboardShow() {
        let iPhoneKeyboardHeight:CGFloat = 100
        let iPadKeyboardHeight:CGFloat = 100
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -iPadKeyboardHeight : -iPhoneKeyboardHeight
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
protocol CustomerDescriptionInputDelegate {
    func saveDescription(text:String)
}
