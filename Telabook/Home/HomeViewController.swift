//
//  HomeViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
        setupCollectionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "HOME"
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SectionItemCell.self, forCellWithReuseIdentifier: NSStringFromClass(SectionItemCell.self))
    }
    private func setupViews() {
        view.addSubview(glanceLabel)
        view.addSubview(profileImageView)
        view.addSubview(operatorNameLabel)
        view.addSubview(operatorDesignationLabel)
        view.addSubview(collectionView)
    }
    private func setupConstraints() {
        glanceLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        let calculatedWidth:CGFloat = self.view.frame.width / 7
        profileImageView.anchor(top: glanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 50, leftConstant: self.view.frame.width / 4, bottomConstant: 0, rightConstant: 0, widthConstant: calculatedWidth, heightConstant: calculatedWidth)
        operatorNameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        operatorDesignationLabel.anchor(top: operatorNameLabel.bottomAnchor, left: operatorNameLabel.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        collectionView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 50, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    let sectionItems:[SectionItem] = [
        SectionItem(image: #imageLiteral(resourceName: "landing_reminder"), title: "REMINDERS", subTitle: "5 Reminders"),
        SectionItem(image: #imageLiteral(resourceName: "landing_followup"), title: "FOLLOW UP", subTitle: "5 Users to Follow Up"),
        SectionItem(image: #imageLiteral(resourceName: "landing_callgroup"), title: "CALL GROUPS", subTitle: "2 Groups"),
        SectionItem(image: #imageLiteral(resourceName: "landing_operators"), title: "USERS ONLINE", subTitle: "5 Online Users")
    ]
    let calculatedInset:CGFloat = 20
    let glanceLabel:UILabel = {
        let label = UILabel()
        label.text = "at a glance".uppercased()
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 30)
        label.textColor = UIColor.telaGray6
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "landing_operators")
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        //        imageView.layer.opacity = 0.5
        //        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let operatorNameLabel:UILabel = {
        let label = UILabel()
        label.text = "anmol rajpal".uppercased()
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let operatorDesignationLabel:UILabel = {
        let label = UILabel()
        label.text = "AIM Operator"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 12)
        label.textColor = UIColor.telaGray7
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.contentInsetAdjustmentBehavior = .always
        cv.clipsToBounds = true
//        cv.alwaysBounceVertical = true
        
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.isHidden = false
        return cv
    }()
}
extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(SectionItemCell.self), for: indexPath) as! SectionItemCell
        
        let sectionItem = self.sectionItems[indexPath.row]
        cell.configureCell(sectionItem: sectionItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let numOfItemsInRow = 2
//        let itemsCount = sectionItems.count
        let calculatedDimension:CGFloat = (collectionView.frame.width / 2) - (calculatedInset * 2)
//        print("Calculated Dimension : \(calculatedDimension)")
//        let ceil = itemsCount / numOfItemsInRow
//        let dimension = CGFloat(ceil) * (calculatedDimension)
        let dimension = calculatedDimension
//        print("Dimension : \(dimension)")
        let size = CGSize(width: dimension, height: dimension)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let halfInset = calculatedInset / 2
        return UIEdgeInsets(top: 0, left: calculatedInset + halfInset, bottom: 0, right: calculatedInset + halfInset)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return calculatedInset
    }
}
