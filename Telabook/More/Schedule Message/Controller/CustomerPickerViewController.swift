//
//  CustomerPickerViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
protocol CustomerPickerDelegate {
    func didSelectCustomer(at indexPath:IndexPath, selectedCustomer customer:ExternalConversationsCodable)
}
class CustomerPickerViewController: UIViewController {
    var delegate:CustomerPickerDelegate?
    var selectedCustomer:ExternalConversationsCodable?
    var selectedCustomerIndexPath:IndexPath?
    let workerId:String
    let agent:InternalConversationsCodable
    init(workerId:String, agent:InternalConversationsCodable) {
        self.workerId = workerId
        self.agent = agent
        super.init(nibName: nil, bundle: nil)
        self.initiateFetchAgentsSequence(workerId: workerId)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var customers:[ExternalConversationsCodable]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let customers = customers {
                if customers.isEmpty {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Customers"
                    self.tableView.isHidden = true
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Select Customer"
    }
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupTableView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setupViews() {
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
    }
    fileprivate func setupConstraints() {
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).activate()
        placeholderLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).activate()
        placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
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
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    fileprivate func setupTableView() {
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}
extension CustomerPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.resetCheckmarks()
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            if let customer = self.customers?[indexPath.row] {
                delegate?.didSelectCustomer(at: indexPath, selectedCustomer: customer)
            }
        }
    }
}
extension CustomerPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        cell?.textLabel?.textColor = UIColor.telaWhite
        cell?.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        cell?.detailTextLabel?.textColor = UIColor.telaGray7
        cell?.detailTextLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        let customer = self.customers?[indexPath.row]
        if let name = customer?.internalAddressBookNames,
            !name.isEmpty {
            cell?.textLabel?.text = name
            cell?.detailTextLabel?.text = customer?.customerPhoneNumber
        } else {
            cell?.textLabel?.text = customer?.customerPhoneNumber
            cell?.detailTextLabel?.text = nil
        }
        if indexPath == selectedCustomerIndexPath,
            selectedCustomerIndexPath != nil {
            cell?.accessoryType = .checkmark
        }
        return cell!
    }
    
    
}
