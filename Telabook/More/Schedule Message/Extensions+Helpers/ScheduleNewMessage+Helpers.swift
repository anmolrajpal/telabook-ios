//
//  ScheduleNewMessage+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ScheduleNewMessageViewController {
    internal func commonInit() {
        configureNavigationBarItems()
        configureNavigationBarAppearance()
        configureHierarchy()
        configureTextFields()
        configureMessageTextView()
        configureTargetActions()
        fireTimerForValidation()
    }
    private func configureHierarchy() {
        view.backgroundColor = .telaGray1
        view.addSubview(agentContainerView)
        view.addSubview(customerContainerView)
        view.addSubview(dateTimeContainerView)
        messageTextView.addSubview(placeholderLabel)
        view.addSubview(messageTextView)
        view.addSubview(characterCountLabel)
        view.addSubview(scheduleButton)
        view.addSubview(spinner)
        layoutConstraints()
    }
    private func layoutConstraints() {
        let height:CGFloat = 44.0
        
        agentContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: height)
        
        customerContainerView.anchor(top: agentContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: height)
        
        dateTimeContainerView.anchor(top: customerContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: height)
        
        messageTextView.anchor(top: dateTimeContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, heightConstant: 100)
        
        characterCountLabel.anchor(top: messageTextView.bottomAnchor, left: nil, bottom: nil, right: messageTextView.rightAnchor, topConstant: 6, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        scheduleButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 40).activate()
        scheduleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        
        spinner.centerXAnchor.constraint(equalTo: scheduleButton.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor).activate()
    }
    
    func startSpinner() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.scheduleButton.isHidden = true
            TapticEngine.generateFeedback(ofType: .Medium)
        }
    }
    func stopSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.scheduleButton.isHidden = false
        }
    }
    
    
    
    private func configureTextFields() {
        
        agentTextField.isEnabled = false
        agentTextField.setIcon(#imageLiteral(resourceName: "front_arrow"), frame: CGRect(x: 0, y: 0, width: 20, height: 20), position: .Right)
        agentContainerView.isUserInteractionEnabled = true
        agentContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(agentFieldDidTap)))
        
        customerTextField.isEnabled = false
        customerTextField.setIcon(#imageLiteral(resourceName: "front_arrow"), frame: CGRect(x: 0, y: 0, width: 20, height: 20), position: .Right)
        customerContainerView.isUserInteractionEnabled = true
        customerContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customerFieldDidTap)))
        
        configureDateTimePickerTextField()
    }
//    fileprivate func setupMessageTextField() {
//        messageTextField.addTarget(self, action: #selector(didChangeMessageTextField), for: .editingChanged)
//    }
//    @objc fileprivate func didChangeMessageTextField(textField:UITextField) {
//        if let text = textField.text {
//            if text.isEmpty {
//                self.disableScheduleButton()
//            } else {
//                self.validateFields()
//            }
//        }
//    }
    @objc
    private func agentFieldDidTap() {
        let vc = AgentsViewController()
        vc.pickerDelegate = self
        if let _ = selectedAgent,
            let indexPath = selectedAgentIndexPath {
            vc.selectedIndexPath = indexPath
        }
        self.show(vc, sender: self)
    }
    @objc
    private func customerFieldDidTap() {
        guard let agent = selectedAgent, agent.workerID != 0 else {
            agentTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        let vc = CustomersViewController(agent: agent)
        vc.pickerDelegate = self
        if let customer = selectedCustomer,
            let indexPath = selectedCustomerIndexPath {
            vc.selectedCustomer = customer
            vc.selectedIndexPath = indexPath
        }
        self.show(vc, sender: self)
    }
    
    
    private func configureNavigationBarItems() {
        title = "NEW MESSAGE"
        let cancelButtonImage = SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)).image(scaledTo: .init(width: 28, height: 28))
        let cancelButton = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: self, action: #selector(cancelButtonDidTap))
        cancelButton.tintColor = UIColor.white.withAlphaComponent(0.2)
        navigationItem.rightBarButtonItems = [cancelButton]
    }
    @objc
    private func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    private func configureTargetActions() {
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
    }
    @objc
    private func scheduleButtonTapped() {
        scheduleMessage()
    }
    private func scheduleMessage() {
        guard let workerId = selectedAgent?.workerID, workerId != 0 else {
            agentTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard let customerId = selectedCustomer?.customerID, customerId != 0 else {
            customerTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard isDatePickerDateValid else {
            dateTimeTextField.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        guard let text = messageTextView.text, !text.isBlank else {
            messageTextView.shake(withFeedbackTypeOf: .Heavy)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let deliveryTime = formatter.string(from: datePicker.date)
        print("Delivery time: \(deliveryTime)")
        scheduleNewMessage(textMessage: text, deliveryTime: deliveryTime, customerID: Int(customerId), workerID: Int(workerId))
    }
    
    
    func configureDateTimePickerTextField() {
        setupDatePickerRange()
        setupDefaultDate()
        dateTimeTextField.setIcon(#imageLiteral(resourceName: "error").withRenderingMode(.alwaysTemplate), frame: CGRect(x: 0, y: 0, width: 20, height: 20), position: .Right, tintColor: UIColor.telaRed)
        dateTimeTextField.keyboardAppearance = .default
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.backgroundColor = UIColor.clear
        
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(datePickerDidTapCancel));
        
        cancelButton.setTitleTextAttributes([
            .font: UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)!,
            .foregroundColor: UIColor.telaBlue
        ], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(datePickerDidTapDone));
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
    @objc func datePickerDidTapDone(){
        self.view.endEditing(true)
    }
    @objc func datePickerDidTapCancel(){
        view.endEditing(true)
    }
    private func setupDatePickerRange() {
        let currentDate = Date()
        datePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)
    }
    private func setupDefaultDate() {
        let formatter = DateFormatter()
        let defaultDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
        datePicker.date = defaultDate
        formatter.dateFormat = CustomDateFormat.hmma.rawValue
        dateTimeTextField.text = "Today, \(formatter.string(from: defaultDate))"
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        setupDatePickerRange()
        let isToday = Calendar.current.isDateInToday(sender.date)
        let isTomorrow = Calendar.current.isDateInTomorrow(sender.date)
        let isYesterday = Calendar.current.isDateInYesterday(sender.date)
        let dateStr:String
        let timeStr = Date.getStringFromDate(date: sender.date, dateFormat: .hmma)
        switch true {
            case isToday: dateStr = "Today, \(timeStr)"
            case isTomorrow: dateStr = "Tomorrow, \(timeStr)"
            case isYesterday: dateStr = "Yesterday, \(timeStr)"
            default: dateStr = Date.getStringFromDate(date: sender.date, dateFormat: .dateTimeType2)
        }
        dateTimeTextField.text = dateStr
    }
    private func fireTimerForValidation() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(validateDatePicker), userInfo: nil, repeats: true)
    }
    @objc
    private func validateDatePicker() {
        dateTimeTextField.rightView?.isHidden = isDatePickerDateValid
    }
    
    
    private func configureMessageTextView() {
        messageTextView.delegate = self
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (messageTextView.font?.pointSize)! - 1)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 13, y: 7)
        placeholderLabel.isHidden = !messageTextView.text.isEmpty
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
        
        let expectedTextSize = ("Customer" as NSString).size(withAttributes: [.font: label.font!])
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



extension ScheduleNewMessageViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textCount = textView.text.count
        placeholderLabel.isHidden = textCount > 0
        characterCountLabel.text = "Charaters left: \(1000 - textCount)"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return textView.resignFirstResponder()
        } else {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars <= 1000
        }
    }
}

