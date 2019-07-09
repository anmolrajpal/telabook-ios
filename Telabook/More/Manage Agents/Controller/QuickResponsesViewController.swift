//
//  QuickResponsesViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class QuickResponsesViewController: UIViewController {
    internal var quickResponses:[QuickResponsesCodable.Answer]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let responses = quickResponses {
                if responses.isEmpty {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Quick Responses"
                    self.tableView.isHidden = true
                } else {
                    self.placeholderLabel.isHidden = true
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    let userId:String
    init(userId:String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
        self.initiateFetchQuickResponsesSequence(userId: userId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        hideKeyboardWhenTappedAround()
        responseTextView.delegate = self
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setupViews() {
        view.addSubview(doneButton)
        view.addSubview(headingLabel)
        view.addSubview(addResponseHeadingLabel)
        view.addSubview(responseTextView)
        view.addSubview(characterCountLabel)
        view.addSubview(saveResponseButton)
        view.addSubview(manageResponsesHeaderView)
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
    }
    func setupConstraints() {
        doneButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        headingLabel.anchor(top: doneButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        addResponseHeadingLabel.anchor(top: headingLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        responseTextView.anchor(top: addResponseHeadingLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 60)
        characterCountLabel.anchor(top: responseTextView.bottomAnchor, left: nil, bottom: nil, right: responseTextView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        saveResponseButton.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 20).isActive = true
        saveResponseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        manageResponsesHeaderView.anchor(top: saveResponseButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        tableView.anchor(top: manageResponsesHeaderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: manageResponsesHeaderView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 100, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
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
    lazy var doneButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Done", attributes: [
            .font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 14.0)!,
            .foregroundColor: UIColor.telaBlue
            ]), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    let headingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Quick Responses"
        label.textColor = UIColor.telaBlue
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 20)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    let addResponseHeadingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Write a quick response and add into the template"
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    let responseTextView:UITextView = {
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
        return textView
    }()
    let characterCountLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Max Character: 70"
        label.textColor = UIColor.telaGray6
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    let saveResponseButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Add", for: UIControl.State.normal)
        button.setTitleColor(.telaGray5, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.isEnabled = false
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.telaGray6
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(saveResponseButtonTapped), for: .touchUpInside)
//        button.addAction(for: UIControl.Event.touchDragOutside, {
//            button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
//        })
//        button.addAction(for: UIControl.Event.touchDown, {
//            button.backgroundColor = AgentDetailsViewController.buttonSelectedColor
//        })
//        button.addAction(for: UIControl.Event.touchUpInside, {
//            button.backgroundColor = AgentDetailsViewController.buttonUnselectedColor
//        })
        return button
    }()
    @objc func saveResponseButtonTapped() {
        self.responseTextView.resignFirstResponder()
        self.responseTextView.endEditing(true)
        saveResponse()
    }
    func saveResponse() {
        if let response = self.responseTextView.text,
            !response.isEmpty {
            self.initiateAddQuickResponseSequence(userId: userId, answer: response)
        } else {
            fatalError("Unhandled case for Response text view")
        }
    }
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    let manageResponsesHeaderView = createHeaderView(title: "Manage Quick Responses")
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
    static func createHeaderView(title:String) -> UIView {
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.telaGray4.withAlphaComponent(0.5)
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
    fileprivate func showEditResponseDialogBox(responseId:String, response:String) {
        let alertVC = UIAlertController(title: "", message: "\n", preferredStyle: UIAlertController.Style.alert)
        let attributedTitle = NSAttributedString(string: "Update Response", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 12)!, //your font here
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
            ])
        let attributedMessage = NSAttributedString(string: "Max Characters: 70", attributes: [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 10)!, //your font here
            NSAttributedString.Key.foregroundColor : UIColor.telaGray7
            ])
        alertVC.setValue(attributedTitle, forKey: "attributedTitle")
        alertVC.setValue(attributedMessage, forKey: "attributedMessage")
        alertVC.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray5
        
        alertVC.view.tintColor = UIColor.telaBlue
        alertVC.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alertVC.view.subviews.first?.backgroundColor = .clear
        alertVC.addTextField { (textField) in
            textField.placeholder = "Add Quick Response"
            textField.text = response
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
            //            textField.layer.borderColor = UIColor.telaGray5.cgColor
            //            textField.layer.borderWidth = 1
            //            textField.layer.cornerRadius = 5
            //            textField.clipsToBounds = true
//            textField.keyboardType = UIKeyboardType.emailAddress
            textField.keyboardAppearance = UIKeyboardAppearance.dark
//            textField.textContentType = UITextContentType.emailAddress
            textField.returnKeyType = UIReturnKeyType.go
            
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        }
        
        
        //        alertVC.textFields?[0].tintColor = .yellow
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in })
        let submitAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) { (action) in
            let text = alertVC.textFields?[0].text
            if let answer = text,
                !answer.isEmpty {
                self.initiateUpdateQuickResponseSequence(userId: self.userId, answer: answer, responseId: responseId)
            }
        }
        submitAction.isEnabled = false
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
        self.present(alertVC, animated: true, completion: nil)
        alertVC.textFields?[0].superview?.backgroundColor = .telaGray5
    }
    @objc func alertTextFieldDidChange(textField: UITextField!) {
        let alertController = self.presentedViewController as? UIAlertController
        if let ac = alertController {
            let submitAction = ac.actions.last
            let textField = ac.textFields?.first
            submitAction?.isEnabled = textField?.text?.count ?? 0 <= 70 && !(textField?.text?.isEmpty ?? true)
        }
    }
}
extension QuickResponsesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textCount = textView.text.count
        saveResponseButton.isEnabled = textCount > 0
        saveResponseButton.backgroundColor = textCount > 0 ? .telaBlue : .telaGray6
        self.characterCountLabel.text = "Charaters left: \(70 - textCount)"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        return numberOfChars <= 70
    }
}
extension QuickResponsesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quickResponses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.textLabel?.text = self.quickResponses?[indexPath.row].answer
        cell.textLabel?.textColor = UIColor.telaGray7
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
        return cell
    }
    
    
}
extension QuickResponsesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction =  UIContextualAction(style: .normal, title: "Edit", handler: { (action,view,completion ) in
            if let quickResponse = self.quickResponses?[indexPath.row],
                let responseId = quickResponse.id,
                let response = quickResponse.answer,
                responseId != 0,
                !response.isEmpty {
                self.showEditResponseDialogBox(responseId: String(responseId), response: response)
                completion(true)
            } else {
                fatalError("Error unwrapping quick response values")
            }
        })
        editAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "edit"), text: "Edit").withRenderingMode(.alwaysOriginal)
        editAction.backgroundColor = UIColor.telaIndigo
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "Delete", handler: { (action,view,completion ) in
            self.initiateDeleteQuickResponseSequence(at: indexPath, completion: completion)
            
        })
        deleteAction.image = UIImage.textImage(image: #imageLiteral(resourceName: "delete_icon"), text: "Delete").withRenderingMode(.alwaysOriginal)
        deleteAction.backgroundColor = UIColor.telaRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}
