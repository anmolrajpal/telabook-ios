//
//  EditDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class EditDetailsViewController: UIViewController {
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
        setupTableView()
        observeKeyboardNotifications()
        hideKeyboardWhenTappedAround()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(cancelButton)
        view.addSubview(saveButton)
        view.addSubview(headingLabel)
        view.addSubview(tableView)
    }
    fileprivate func setupConstraints() {
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top + 30).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.layoutMargins.left + 15).isActive = true
        saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top + 30).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.layoutMargins.right - 15).isActive = true
        headingLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 0)
        tableView.anchor(top: headingLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    fileprivate func setupTableView() {
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(CustomHeaderView.self))
        tableView.register(TextInputCell.self, forCellReuseIdentifier: NSStringFromClass(TextInputCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
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
        self.dismiss(animated: true, completion: nil)
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
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor.telaGray5.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
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
extension EditDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 1
        case 3: return 3
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextInputCell.self), for: indexPath) as! TextInputCell
            cell.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.inputTextField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [.foregroundColor: UIColor.telaGray5.withAlphaComponent(0.6)])
            } else {
                cell.inputTextField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [.foregroundColor: UIColor.telaGray5.withAlphaComponent(0.6)])
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextInputCell.self), for: indexPath) as! TextInputCell
            cell.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.inputTextField.attributedPlaceholder = NSAttributedString(string: "Address 1", attributes: [.foregroundColor: UIColor.telaGray5.withAlphaComponent(0.6)])
            } else {
                cell.inputTextField.attributedPlaceholder = NSAttributedString(string: "Address 2", attributes: [.foregroundColor: UIColor.telaGray5.withAlphaComponent(0.6)])
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
            cell.textLabel?.textColor = UIColor.telaGray7
            cell.textLabel?.text = "None"
            cell.accessoryType = .disclosureIndicator
            return cell
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
                cell.textLabel?.textColor = UIColor.telaGray7
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Classification Star"
                cell.imageView?.image = #imageLiteral(resourceName: "followup_high")
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
                cell.textLabel?.textColor = UIColor.telaGray7
                cell.textLabel?.text = "Name Customized by Agent"
                cell.selectionStyle = .none
                let switchButton = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
                switchButton.isOn = false
                switchButton.tintColor = UIColor.telaGray5
                switchButton.thumbTintColor = UIColor.telaWhite
                switchButton.onTintColor = UIColor.telaBlue
                cell.accessoryView = switchButton
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
                cell.textLabel?.textColor = UIColor.telaGray7
                cell.textLabel?.text = "Mark as Customer"
                cell.selectionStyle = .none
                let switchButton = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
                switchButton.isOn = false
                switchButton.tintColor = UIColor.telaGray5
                switchButton.thumbTintColor = UIColor.telaWhite
                switchButton.onTintColor = UIColor.telaBlue
                cell.accessoryView = switchButton
                return cell
            }
        default: break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(CustomHeaderView.self)) as! CustomHeaderView
        switch section {
            case 0: headerView.headerTitle = "Name"
            case 1: headerView.headerTitle = "Address"
            case 2: headerView.headerTitle = "Description"
            case 3: headerView.headerTitle = "Settings"
            default: headerView.headerTitle = nil
        }
        return headerView
    }
    
}
extension EditDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 40
        case 1: return 40
        case 2: return 40
        case 3: return 40
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .telaGray7
        view.tintColor = .telaGray7
    }
}
