//
//  CustomerDetailsController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class CustomerDetailsController: UIViewController {
    
    enum Segment:Int, CaseIterable { case Details, History ; var stringValue:String { String(describing: self).uppercased() } }
    
    // MARK: - Properties
    
    var dataSource: DataSource! = nil
    var lookupConversations = [LookupConversationProperties]()
    var currentPageIndex = 0
    var isFetching = false
    var limit = 20
    
    var selectedSegment: Segment = .Details {
        didSet {
            handleSegmentViewsState()
        }
    }
    
    
    // MARK: - Computed Properties
    
    var shouldFetchMore: Bool {
        return !isFetching && !lookupConversations.isEmpty && lookupConversations.count % limit == 0
    }
    
    
    
    // MARK: - Overriden Properties
    
    override var isModalInPresentation: Bool {
        get {
            return selectedSegment == .Details
        }
        set {
            super.isModalInPresentation = newValue
        }
    }
    
    
    // MARK: - Initialization
    
    let conversation: Customer
    let conversationID: Int
    let workerID: Int
    
    init(conversation: Customer) {
        self.conversation = conversation
        self.conversationID = Int(conversation.externalConversationID)
        self.workerID = Int(conversation.agent?.workerID ?? 0)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\(self) : Deinitialized")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotificationsObservers()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - View Constructors
   
    lazy var segmentedControl:UISegmentedControl = {
        let attributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.gothamMedium(forTextStyle: .footnote),
                .foregroundColor : UIColor.telaBlue
            ]
        let unselectedAttributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.gothamMedium(forTextStyle: .footnote),
                .foregroundColor : UIColor.telaGray7
        ]
        let control = UISegmentedControl(items: Segment.allCases.map { $0.stringValue })
        control.selectedSegmentIndex = Segment.Details.rawValue
        control.tintColor = .clear
        control.selectedSegmentTintColor = .telaGray6
        control.setTitleTextAttributes(attributes, for: UIControl.State.selected)
        control.setTitleTextAttributes(unselectedAttributes, for: UIControl.State.normal)
        control.backgroundColor = .telaGray3
        control.layer.cornerRadius = 0
        return control
    }()
    
    
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.backgroundColor = .clear
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    lazy var scrollViewContentView:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    lazy var phoneNumberLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.gothamMedium(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    lazy var agentOnlyNameHeaderLabel = headerLabel(text: "NAME (Only for this Agent)")
    lazy var agentOnlyNameTextField = textField(placeholderText: "Full Name")
    lazy var agentOnlyNameFooterLabel = footerLabel(text: "Leave empty to use the global name")
    lazy var globalNameHeaderLabel = headerLabel(text: "NAME (Global)")
    lazy var globalNameTextField = textField(placeholderText: "Full Name")
    
    lazy var detailsSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.white
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var historySpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.white
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var detailsPlaceholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Error loading customer details"
        label.font = UIFont.gothamMedium(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var historyPlaceholderLabel:UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.font = UIFont.gothamMedium(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var updateButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update", for: .normal)
        button.setTitleColor(.telaGray5, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 60, bottom: 8, right: 60)
        button.layer.cornerRadius = 7
        button.setBackgroundColor(color: .telaBlue, forState: .normal)
        button.setBackgroundColor(color: .telaGray6, forState: .disabled)
        button.clipsToBounds = true
        return button
    }()
    
    
    // MARK: - Helpers
    
    private func textField(placeholderText: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholderText
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: UIColor.telaGray5])
        textField.font = UIFont.gothamBook(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.quaternarySystemFill
        textField.layer.cornerRadius = 10
        textField.textAlignment = .left
        textField.keyboardAppearance = .dark
        textField.borderStyle = .none
        textField.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldDidReturn(_:)), for: .editingDidEndOnExit)
        return textField
    }
    @objc
    private func textFieldDidReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    private func headerLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.gothamBook(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray6
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    private func footerLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.gothamBook(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.telaGray6
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
}


