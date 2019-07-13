//
//  ScheduleMessageViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class ScheduleMessageViewController: UIViewController {
    internal var scheduledMessages:[ScheduleMessagesCodable.ScheduleMessage]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print("Damn")
            if let messages = scheduledMessages {
                print("Hola")
                if messages.isEmpty {
                    print("Cola")
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.text = "No Scheduled Messages"
                    self.tableView.isHidden = true
                } else {
                    self.placeholderLabel.isHidden = true
                    self.tableView.isHidden = false
                }
            } else {
                self.placeholderLabel.isHidden = false
                self.placeholderLabel.text = "No Scheduled Messages"
                self.tableView.isHidden = true
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Scheduled Messages"
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupNavBarItems()
        setupTableView()
        initiateFetchScheduledMessagesSequence()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupNavBarItems() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItems = [addButton]
    }
    @objc func addButtonTapped() {
        let vc = ScheduleNewMessageViewController()
        self.show(vc, sender: self)
        
//        vc.modalPresentationStyle = .overFullScreen
//        vc.view.backgroundColor = .telaGray1
//        self.present(vc, animated: true, completion: nil)
    }
    func setupViews() {
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
    }
    func setupConstraints() {
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 100, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}
