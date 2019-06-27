//
//  FollowUpViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class FollowUpViewController: UIViewController {
    internal var followUpsIndex:[FollowUpsIndexCodable]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let index = followUpsIndex {
                if index.isEmpty {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Users to Follow Up"
                    self.tableView.isHidden = true
                }
            }
        }
    }
    internal var lowPriorityFollowUps:[FollowUpsIndexCodable] = []
    internal var mediumPriorityFollowUps:[FollowUpsIndexCodable] = []
    internal var highPriorityFollowUps:[FollowUpsIndexCodable] = []
    internal var allPriorityFollowUps:[FollowUpsIndexCodable]? {
        didSet {
            if let index = allPriorityFollowUps {
                self.lowPriorityFollowUps = index.filter({ ConversationPriority.getPriority(by: $0.priority ?? 0) == ConversationPriority.Low })
                self.mediumPriorityFollowUps = index.filter({ ConversationPriority.getPriority(by: $0.priority ?? 0) == ConversationPriority.Medium })
                self.highPriorityFollowUps = index.filter({ ConversationPriority.getPriority(by: $0.priority ?? 0) == ConversationPriority.High })
            }
            self.handleSegmentControls(for: .All)
        }
    }
    
    
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        self.navigationItem.title = "FOLLOW UP"
        setupTableView()
        self.initiateFetchFollowUpsIndexSequence()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        view.addSubview(refreshButton)
    }
    fileprivate func setupConstraints() {
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        tableView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive = true
        refreshButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        refreshButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    fileprivate func setupTableView() {
        tableView.register(FollowUpCell.self, forCellReuseIdentifier: NSStringFromClass(FollowUpCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
    let tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.separatorColor = UIColor.telaWhite.withAlphaComponent(0.5)
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.clipsToBounds = true
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.tableFooterView = UIView(frame: CGRect.zero)
        return tv
    }()
    let segmentedControl:UISegmentedControl = {
        let options = ["All", "Low", "Medium", "High"]
        let control = UISegmentedControl()
        control.insertSegment(with: UIImage.textImage(image: #imageLiteral(resourceName: "followup_all"), text: "All").withRenderingMode(.alwaysOriginal), at: 0, animated: false)
        control.insertSegment(with: UIImage.textImage(image: #imageLiteral(resourceName: "followup_low"), text: "Low").withRenderingMode(.alwaysOriginal), at: 1, animated: false)
        control.insertSegment(with: UIImage.textImage(image: #imageLiteral(resourceName: "followup_medium"), text: "Medium").withRenderingMode(.alwaysOriginal), at: 2, animated: false)
        control.insertSegment(with: UIImage.textImage(image: #imageLiteral(resourceName: "followup_high"), text: "High").withRenderingMode(.alwaysOriginal), at: 3, animated: false)
        control.selectedSegmentIndex = 0
        control.tintColor = UIColor.telaGray1
        
//        control.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "followup_all"), text: "All").withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
//
//        control.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "followup_low"), text: "Low").withRenderingMode(.alwaysOriginal), forSegmentAt: 1)
//        control.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "followup_medium"), text: "Medium").withRenderingMode(.alwaysOriginal), forSegmentAt: 2)
//        control.setImage(UIImage.textImage(image: #imageLiteral(resourceName: "followup_high"), text: "High").withRenderingMode(.alwaysOriginal), forSegmentAt: 3)
        control.backgroundColor = .telaGray3
        control.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        return control
    }()
    @objc fileprivate func segmentDidChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: handleSegmentControls(for: .All)
        case 1: handleSegmentControls(for: .Low)
        case 2: handleSegmentControls(for: .Medium)
        case 3: handleSegmentControls(for: .High)
        default: fatalError("Invalid Segment")
        }
    }
    private enum SegmentType {
        case All
        case Low
        case Medium
        case High
    }
    private func handleSegmentControls(for type:SegmentType) {
        switch type {
        case .All:
            print("Segment - Followup All")
            self.followUpsIndex = self.allPriorityFollowUps
        case .Low:
            print("Segment - Followup Low")
            self.followUpsIndex = self.lowPriorityFollowUps
        case .Medium:
            print("Segment - Followup Medium")
            self.followUpsIndex = self.mediumPriorityFollowUps
        case .High:
            print("Segment - Followup High")
            self.followUpsIndex = self.highPriorityFollowUps
        }
    }
    
    @objc func handleRefreshAction() {
        self.setPlaceholdersViewsState(isHidden: true)
        self.setViewsState(isHidden: true)
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.refreshButton.isHidden = isHidden
    }
    fileprivate func setViewsState(isHidden: Bool) {
        self.tableView.isHidden = isHidden
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
    let refreshButton:UIButton = {
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
    
    
    
}


