//
//  FollowUpViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class FollowUpViewController: UIViewController {
    
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
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
    }
    fileprivate func setupConstraints() {
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        tableView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
        case .All: print("Segment - Followup All")
        case .Low: print("Segment - Followup Low")
        case .Medium: print("Segment - Followup Medium")
        case .High: print("Segment - Followup High")
        }
    }
}
extension FollowUpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FollowUpCell.self), for: indexPath) as! FollowUpCell
        cell.backgroundColor = .clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.telaGray7.withAlphaComponent(0.2)
        cell.selectedBackgroundView  = backgroundView
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
}

extension FollowUpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FollowUpCell.cellHeight
    }
}


