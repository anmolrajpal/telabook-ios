//
//  ScheduleNewMessageViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
protocol ScheduleNewMessageDelegate {
    func controllerDidScheduleNewMessage(controller:UIViewController)
}
class ScheduleNewMessageViewController: UIViewController {
    
    // MARK: - Properties
    var delegate:ScheduleNewMessageDelegate?
    var selectedAgent:Agent? {
        didSet {
            guard let agent = selectedAgent else { return }
            self.selectedCustomer = nil
            self.selectedCustomerIndexPath = nil
            self.customerTextField.text = nil
            let name = agent.personName
            let phoneNumber = agent.didNumber
            if !name.isBlank {
                self.agentTextField.text = "\(name ?? "") (\(phoneNumber ?? ""))"
            } else {
                self.agentTextField.text = phoneNumber
            }
        }
    }
    var selectedAgentIndexPath:IndexPath?
    var selectedCustomer:Customer? {
        didSet {
            guard let customer = selectedCustomer else { return }
            if let name = customer.addressBookName,
                !name.isBlank {
                self.customerTextField.text = "\(name) (\(customer.phoneNumber ?? ""))"
            } else {
                self.customerTextField.text = customer.phoneNumber
            }
        }
    }
    var selectedCustomerIndexPath:IndexPath?
    var timer = Timer()
    
    
    
    
    // MARK: - Computed Properties
    
    var isDatePickerDateValid:Bool {
        let assertionDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        return datePicker.date > assertionDate
    }
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    
    
    
    
    
    // MARK: - Views
    
    let datePicker:UIDatePicker = UIDatePicker()
    let agentTextField = createTextField(placeholder: "Select Agent")
    let customerTextField = createTextField(placeholder: "Select Customer")
    let dateTimeTextField = createTextField(placeholder: "Set Time")
//    let messageTextField = createTextField(placeholder: "Text Message")
    lazy var agentContainerView = createTextFieldContainerView(labelTitle: "Agent", agentTextField)
    lazy var customerContainerView = createTextFieldContainerView(labelTitle: "Customer", customerTextField)
    lazy var dateTimeContainerView = createTextFieldContainerView(labelTitle: "Time", dateTimeTextField)
//    lazy var messageContainerView = createTextFieldContainerView(labelTitle: "Text Message", messageTextField)
    
    lazy var scheduleButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Schedule", for: UIControl.State.normal)
        button.setTitleColor(.telaGray5, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.telaBlue
        button.clipsToBounds = true
        return button
    }()
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = .white
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var messageTextView:UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.isEditable = true
        textView.textAlignment = .left
        textView.isSelectable = true
        textView.backgroundColor = UIColor.telaGray4
        textView.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        textView.textColor = UIColor.telaGray7
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.sizeToFit()
        textView.isScrollEnabled = true
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 7
        textView.tintColor = .telaBlue
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    lazy var characterCountLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Character limit: 1000"
        label.textColor = UIColor.telaGray7
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Write your Message..."
        label.sizeToFit()
        label.textColor = UIColor.telaGray5
        return label
    }()
    
}


extension ScheduleNewMessageViewController: AgentPickerDelegate {
    func agentsController(didPick agent: Agent, at indexPath: IndexPath, controller: AgentsViewController) {
        selectedAgent = agent
        selectedAgentIndexPath = indexPath
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            controller.navigationController?.popViewController(animated: true)
        }
    }
}
extension ScheduleNewMessageViewController: CustomerPickerDelegate {
    func customersController(didPick customer: Customer, at indexPath: IndexPath, controller: UIViewController) {
        selectedCustomer = customer
        selectedCustomerIndexPath = indexPath
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            controller.navigationController?.popViewController(animated: true)
        }
    }
}
