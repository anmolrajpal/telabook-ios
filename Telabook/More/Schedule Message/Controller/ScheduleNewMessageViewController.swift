//
//  ScheduleNewMessageViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ScheduleNewMessageViewController: UIViewController {
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
        
    }
    @objc func agentFieldTapped() {
        print("Select Agent")
    }
    @objc func customerFieldTapped() {
        print("Select Customer")
    }
    let datePicker:UIDatePicker = UIDatePicker()
    fileprivate func setupDateTimePickerTextField() {
        dateTimeTextField.keyboardAppearance = .default
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        toolbar.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dateTimeTextField.inputAccessoryView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dateTimeTextField.inputAccessoryView = toolbar
        dateTimeTextField.inputView = datePicker
        
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
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let formatter = DateFormatter()
//        let weekDay = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: sender.date) - 1]
        let currentDate = Date()
        datePicker.minimumDate = currentDate.add(minutes: 1)
        datePicker.maximumDate = currentDate.add(days: 7)
        if Date.isDateSame(date1: currentDate, date2: sender.date) {
            formatter.dateFormat = CustomDateFormat.hmma.rawValue
            dateTimeTextField.text = "Today, \(formatter.string(from: sender.date))"
        } else {
            formatter.dateFormat = CustomDateFormat.dateTimeType2.rawValue
            dateTimeTextField.text = formatter.string(from: sender.date)
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
