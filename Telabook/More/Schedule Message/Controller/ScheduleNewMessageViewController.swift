//
//  ScheduleNewMessageViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ScheduleNewMessageViewController: UIViewController {
    var selectedAgent:InternalConversationsCodable? {
        didSet {
            guard let agent = selectedAgent else { return }
            self.selectedCustomer = nil
            self.selectedCustomerIndexPath = nil
            self.customerTextField.text = nil
            if let name = agent.personName,
                !name.isEmpty {
                self.agentTextField.text = "\(name) (\(agent.phoneNumber ?? ""))"
            }
        }
    }
    var selectedAgentIndexPath:IndexPath?
    var selectedCustomer:ExternalConversationsCodable? {
        didSet {
            guard let customer = selectedCustomer else { return }
            if let name = customer.internalAddressBookNames,
                !name.isEmpty {
                self.customerTextField.text = "\(name) (\(customer.customerPhoneNumber ?? ""))"
            } else {
                self.customerTextField.text = customer.customerPhoneNumber
            }
        }
    }
    var selectedCustomerIndexPath:IndexPath?
    var timer = Timer()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "New Message"
    }
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupTextFields()
        fireTimerForValidation()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setupViews() {
        setupSubviews()
        view.addSubview(scheduleButton)
    }
    func setupConstraints() {
        setupSubviewsConstraints()
        scheduleButton.topAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: 40).activate()
        scheduleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
    }
    
    fileprivate func setupSubviews() {
        view.addSubview(agentContainerView)
        view.addSubview(customerContainerView)
        view.addSubview(dateTimeContainerView)
        view.addSubview(messageContainerView)
    }
    fileprivate func setupSubviewsConstraints() {
        let height:CGFloat = 44.0
        agentContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
        customerContainerView.anchor(top: agentContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
        dateTimeContainerView.anchor(top: customerContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
        messageContainerView.anchor(top: dateTimeContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    let agentTextField = createTextField(placeholder: "Select Agent")
    let customerTextField = createTextField(placeholder: "Select Customer")
    let dateTimeTextField = createTextField(placeholder: "Set Time")
    let messageTextField = createTextField(placeholder: "Text Message")
    fileprivate func setupTextFields() {
        agentTextField.isEnabled = false
        agentTextField.setIcon(#imageLiteral(resourceName: "front_arrow"), frame: CGRect(x: 0, y: 0, width: 20, height: 20), position: .Right)
        customerTextField.isEnabled = false
        customerTextField.setIcon(#imageLiteral(resourceName: "front_arrow"), frame: CGRect(x: 0, y: 0, width: 20, height: 20), position: .Right)
        agentContainerView.isUserInteractionEnabled = true
        agentContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(agentFieldTapped)))
        customerContainerView.isUserInteractionEnabled = true
        customerContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customerFieldTapped)))
        setupDateTimePickerTextField()
        setupMessageTextField()
    }
    fileprivate func setupMessageTextField() {
        messageTextField.addTarget(self, action: #selector(didChangeMessageTextField), for: .editingChanged)
    }
    @objc fileprivate func didChangeMessageTextField(textField:UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                self.disableScheduleButton()
            } else {
                self.validateFields()
            }
        }
    }
    @objc func agentFieldTapped() {
        print("Select Agent")
        let vc = AgentPickerViewController()
        vc.delegate = self
        if let agent = self.selectedAgent,
            let indexPath = self.selectedAgentIndexPath {
            vc.selectedAgent = agent
            vc.selectedAgentIndexPath = indexPath
        }
        self.show(vc, sender: self)
    }
    @objc func customerFieldTapped() {
        print("Select Customer")
        guard let agent = selectedAgent,
            let workerId = agent.workerId,
            workerId != 0 else {
                return
        }
        let vc = CustomerPickerViewController(workerId: String(workerId), agent: agent)
        vc.delegate = self
        if let customer = self.selectedCustomer,
            let indexPath = self.selectedCustomerIndexPath {
            vc.selectedCustomer = customer
            vc.selectedCustomerIndexPath = indexPath
        }
        self.show(vc, sender: self)
    }
    let datePicker:UIDatePicker = UIDatePicker()
    fileprivate func setupDateTimePickerTextField() {
        setupDatePickerRange()
        setupDefaultDate()
        dateTimeTextField.keyboardAppearance = .default
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.backgroundColor = UIColor.clear

        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        cancelButton.setTitleTextAttributes([
                .font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)!,
                .foregroundColor: UIColor.telaBlue
            ], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        doneButton.setTitleTextAttributes([
            .font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)!,
            .foregroundColor: UIColor.telaBlue
            ], for: .normal)
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        toolbar.barTintColor = UIColor.black.withAlphaComponent(0.8)
        dateTimeTextField.inputAccessoryView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dateTimeTextField.inputAccessoryView = toolbar
        dateTimeTextField.inputView = datePicker
        dateTimeTextField.inputView?.backgroundColor = UIColor.telaGray4
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
    }
    @objc func doneDatePicker(){
        self.view.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = CustomDateFormat.dateWithTime.rawValue
        let dateStr = formatter.string(from: datePicker.date)
        print(dateStr)
        let components = Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)
        if let day = components.day, let month = components.month, let year = components.year {
            let date = "\(day).\(month).\(year)"
            print(date)
        }
    }
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    fileprivate func setupDatePickerRange() {
        let currentDate = Date()
        datePicker.minimumDate = currentDate.add(minutes: 1)
        datePicker.maximumDate = currentDate.add(days: 7)
    }
    fileprivate func setupDefaultDate() {
        let formatter = DateFormatter()
        let defaultDate = Date().add(minutes: 1)!
        datePicker.date = defaultDate
        formatter.dateFormat = CustomDateFormat.hmma.rawValue
        dateTimeTextField.text = "Today, \(formatter.string(from: defaultDate))"
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let formatter = DateFormatter()
//        let weekDay = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: sender.date) - 1]
        let currentDate = Date()
        setupDatePickerRange()
        if Date.isDateSame(date1: currentDate, date2: sender.date) {
            formatter.dateFormat = CustomDateFormat.hmma.rawValue
            dateTimeTextField.text = "Today, \(formatter.string(from: sender.date))"
        } else {
            formatter.dateFormat = CustomDateFormat.dateTimeType2.rawValue
            dateTimeTextField.text = formatter.string(from: sender.date)
        }
    }
    func fireTimerForValidation() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.validateDatePicker), userInfo: nil, repeats: true)
    }
    
    @objc func validateDatePicker(){
        if !isDatePickerDateValid() {
            dateTimeTextField.setIcon(#imageLiteral(resourceName: "error").withRenderingMode(.alwaysTemplate), frame: CGRect(x: 0, y: 0, width: 20, height: 20), position: .Right, tintColor: UIColor.telaRed)
            disableScheduleButton()
        } else {
            dateTimeTextField.rightView = nil
            validateFields()
        }
    }
    func isDatePickerDateValid() -> Bool {
        let currentTime = Date()
        return datePicker.date < currentTime ? false : true
    }
    fileprivate func isDataValid() -> Bool {
        guard selectedAgent != nil,
            selectedCustomer != nil,
            isDatePickerDateValid(),
            let text = messageTextField.text,
            !text.isEmpty else {
                return false
        }
        return true
    }
    fileprivate func validateFields() {
        if isDataValid() {
            enableScheduleButton()
        } else {
            disableScheduleButton()
        }
    }
    fileprivate func enableScheduleButton() {
        scheduleButton.isEnabled = true
        UIView.animate(withDuration: 0.4) {
            self.scheduleButton.backgroundColor = UIColor.telaBlue
        }
    }
    fileprivate func disableScheduleButton() {
        scheduleButton.isEnabled = false
        UIView.animate(withDuration: 0.4) {
            self.scheduleButton.backgroundColor = UIColor.telaGray6
        }
    }
    lazy var agentContainerView = self.createTextFieldContainerView(labelTitle: "Agent", self.agentTextField)
    lazy var customerContainerView = self.createTextFieldContainerView(labelTitle: "Customer", self.customerTextField)
    lazy var dateTimeContainerView = self.createTextFieldContainerView(labelTitle: "Time", self.dateTimeTextField)
    lazy var messageContainerView = self.createTextFieldContainerView(labelTitle: "Text Message", self.messageTextField)
    
    
    
    let scheduleButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Schedule", for: UIControl.State.normal)
        button.setTitleColor(.telaGray5, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.isEnabled = false
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.telaGray6
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc fileprivate func scheduleButtonTapped() {
        print("Scheduling...")
//        timer.invalidate()
        scheduleMessage()
    }
    fileprivate func scheduleMessage() {
        guard let workerId = self.selectedAgent?.workerId,
            let customerId = self.selectedCustomer?.customerId,
            let text = self.messageTextField.text,
            workerId != 0, customerId != 0, !text.isEmpty else {
                return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = CustomDateFormat.dateWithTime.rawValue
        let date = formatter.string(from: datePicker.date)
        self.initiateScheduleNewMessageSequence(workerId: String(workerId), customerId: String(customerId), date: date, text: text)
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
        
        let expectedTextSize = ("Text Message" as NSString).size(withAttributes: [.font: label.font!])
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
}
extension ScheduleNewMessageViewController: AgentPickerDelegate {
    func didSelectAgent(at indexPath: IndexPath, selectedAgent agent: InternalConversationsCodable) {
        self.selectedAgent = agent
        self.selectedAgentIndexPath = indexPath
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
extension ScheduleNewMessageViewController: CustomerPickerDelegate {
    func didSelectCustomer(at indexPath: IndexPath, selectedCustomer customer: ExternalConversationsCodable) {
        self.selectedCustomer = customer
        self.selectedCustomerIndexPath = indexPath
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
