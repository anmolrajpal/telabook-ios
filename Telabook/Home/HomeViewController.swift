//
//  HomeViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import Firebase
import CoreData
class HomeViewController: UIViewController {
    var userInfo:UserInfoCodable? {
        didSet {
            if let u = userInfo {
                self.updateUserData(userInfoData: u)
                self.updateUICodable(user: u.user)
                self.stopSpinner()
                self.setViewsState(isHidden: false)
                self.setPlaceholdersViewsState(isHidden: true)
            }
        }
    }
    let sectionItems:[SectionItem] = [
        SectionItem(image: #imageLiteral(resourceName: "landing_reminder"), title: "REMINDERS", subTitle: "5 Reminders"),
        SectionItem(image: #imageLiteral(resourceName: "landing_followup"), title: "FOLLOW UP", subTitle: "5 Users to Follow Up"),
        SectionItem(image: #imageLiteral(resourceName: "landing_callgroup"), title: "CALL GROUPS", subTitle: "2 Groups"),
        SectionItem(image: #imageLiteral(resourceName: "landing_operators"), title: "USERS ONLINE", subTitle: "5 Online Users")
    ]
    let calculatedInset:CGFloat = 20
   
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
        setupCollectionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
//        setViewsState(isHidden: true)
//        startSpinner()
        preFetchUser()
//        fetchUserData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "HOME"
        fetchUserData()
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
        view.addSubview(spinner)
        view.addSubview(glanceLabel)
        view.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(operatorNameLabel)
        containerView.addSubview(operatorDesignationLabel)
        view.addSubview(placeholderLabel)
        view.addSubview(tryAgainButton)
        view.addSubview(collectionView)
    }
    private func setupConstraints() {
        glanceLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        
//        containerView.topAnchor.constraint(equalTo: glanceLabel.bottomAnchor, constant: 50).isActive = true
        containerView.anchor(top: glanceLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: view.frame.width / 5, bottomConstant: 0, rightConstant: view.frame.width / 5, widthConstant: 0, heightConstant: 0)
//        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    
        let calculatedWidth:CGFloat = self.view.frame.width / 6
        profileImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: calculatedWidth, heightConstant: calculatedWidth)
        operatorNameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        operatorNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -15).isActive = true
        
        operatorDesignationLabel.anchor(top: nil, left: operatorNameLabel.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        operatorDesignationLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 10).isActive = true
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20).isActive = true
        tryAgainButton.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 20).isActive = true
        tryAgainButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        collectionView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 50, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    lazy var spinner:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
//        indicator.backgroundColor = .black
        return indicator
    }()
    let glanceLabel:UILabel = {
        let label = UILabel()
        label.text = "AT A GLANCE"
        label.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 30)
        label.textColor = UIColor.telaGray6
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let containerView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.telaBlue.cgColor
        //        imageView.layer.opacity = 0.5
        //        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let operatorNameLabel:UILabel = {
        let label = UILabel()
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
    let tryAgainButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TRY AGAIN", for: UIControl.State.normal)
        button.setTitleColor(UIColor.telaGray6, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.telaGray6.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        button.addTarget(self, action: #selector(handleTryAgainAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    let settingsButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Settings", for: UIControl.State.normal)
        button.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        button.addTarget(self, action: #selector(launchSettings), for: UIControl.Event.touchUpInside)
        return button
    }()
    @objc func launchSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                
            })
        }
    }
    fileprivate func startSpinner() {
        self.spinner.startAnimating()
    }
    fileprivate func stopSpinner() {
        self.spinner.stopAnimating()
    }
    @objc func handleTryAgainAction() {
        self.setPlaceholdersViewsState(isHidden: true)
        self.setViewsState(isHidden: true)
        self.startSpinner()
        self.fetchUserData()
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.tryAgainButton.isHidden = isHidden
    }
    fileprivate func setViewsState(isHidden: Bool) {
        self.operatorNameLabel.isHidden = isHidden
        self.operatorDesignationLabel.isHidden = isHidden
        self.profileImageView.isHidden = isHidden
        self.collectionView.isHidden = isHidden
    }
    fileprivate func fetchUserData() {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.stopSpinner()
                    self.setViewsState(isHidden: true)
                    self.setPlaceholdersViewsState(isHidden: false)
                }
                self.placeholderLabel.text = err.localizedDescription
            } else if let token = token {
                self.fetchUserInfoByToken(token)
            }
            else {
                print("God damn")
            }
        }
    }
    fileprivate func fetchUserInfoByToken(_ token:String) {
        print("Token => \n\(token)")
        print("Company => \(UserDefaults.standard.getCompanyId()) & Worker ID => \(UserDefaults.standard.getWorkerId()) & Current Sender => \(String(describing: UserDefaults.standard.currentSender))")
        AuthenticationService.shared.authenticateViaToken(token: token) { (data, serviceError, error) in
            guard serviceError == nil else {
                if let err = serviceError {
                    print("\n***Error***\n")
                    print(err)
                    DispatchQueue.main.async {
                        self.stopSpinner()
                        self.setViewsState(isHidden: true)
                        self.setPlaceholdersViewsState(isHidden: false)
                    }
                    self.placeholderLabel.text = err.localizedDescription
                }
                return
            }
            guard data != nil else {
                print("Data nil")
                return
            }
            if let userInfoData = data {
                self.userInfo = userInfoData
                print(userInfoData.user!)
            }
        }
    }
    fileprivate func updateUserData(userInfoData:UserInfoCodable) {
        self.clearStorage()
        self.saveToCoreData(userInfo: userInfoData)
    }
    lazy var fetchedResultsController: NSFetchedResultsController<UserObject> = {
        let fetchRequest = NSFetchRequest<UserObject>(entityName:"UserObject")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: PersistenceService.shared.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    fileprivate func updateUICodable(user: UserInfoCodable.User?) {
        let role = CustomUtils.shared.getUserRole()
        let firstName = user?.name
        let lastName = user?.lastName
        self.operatorNameLabel.text = "\(firstName?.uppercased() ?? "") \(lastName?.uppercased() ?? "")"
        
        let initialsText = "\(firstName?.first?.uppercased() ?? "Z")\(lastName?.first?.uppercased() ?? "Z")"
        self.profileImageView.loadImageUsingCacheWithURLString(user?.profileImageUrl, placeHolder: UIImage.placeholderInitialsImage(text: initialsText))
        
        self.operatorDesignationLabel.text = String(describing: role)
    }
    fileprivate func updateUI(user: UserObject?) {
        let role = CustomUtils.shared.getUserRole()
        let firstName = user?.name
        let lastName = user?.lastName
        self.operatorNameLabel.text = "\(firstName?.uppercased() ?? "") \(lastName?.uppercased() ?? "")"
        
        let initialsText = "\(firstName?.first?.uppercased() ?? "X")\(lastName?.first?.uppercased() ?? "D")"
        self.profileImageView.loadImageUsingCacheWithURLString(user?.profileImageUrl, placeHolder: UIImage.placeholderInitialsImage(text: initialsText))
        
        self.operatorDesignationLabel.text = String(describing: role)
    }
    fileprivate func preFetchUser() {
        let user = fetchedResultsController.fetchedObjects?.first
        self.updateUI(user: user)
    }
    
    
    func saveToCoreData(userInfo:UserInfoCodable) {
        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.context else {
                fatalError("Failed to retrieve managed object context")
            }
            
            let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            let encoder = JSONEncoder()
            let data = try encoder.encode(userInfo.user)
            
            _ = try decoder.decode(UserObject.self, from: data)
            
//            try managedObjectContext.save()
            
            let permissionData = try encoder.encode(userInfo.permissions)
            _ = try decoder.decode([Permission].self, from: permissionData)
            try managedObjectContext.save()
            
        } catch let error {
            print(error)
            
        }
    }
    func clearStorage() {
        let isInMemoryStore = PersistenceService.shared.persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }
        
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserObject")
        let permissionsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Permission")
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            print("In Memory Store")
            do {
                let users = try managedObjectContext.fetch(fetchRequest)
                for user in users {
                    managedObjectContext.delete(user as! NSManagedObject)
                }
                let permissions = try managedObjectContext.fetch(permissionsFetchRequest)
                for permission in permissions {
                    managedObjectContext.delete(permission as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            print("Not In Memory Store")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let permissionsBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: permissionsFetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
                try managedObjectContext.execute(permissionsBatchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    func fetchPermissionsFromStorage() -> [Permission]? {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Permission>(entityName: "Permission")
        let sortDescriptor1 = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        do {
            let permissions = try managedObjectContext.fetch(fetchRequest)
            return permissions
        } catch let error {
            print(error)
            return nil
        }
    }
    func fetchFromStorage() -> UserObject? {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserObject>(entityName: "UserObject")
        let sortDescriptor1 = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]

        do {
            let user = try managedObjectContext.fetch(fetchRequest)
            return user.first
        } catch let error {
            print(error)
            return nil
        }
    }
   
    
    
}
extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Controller did change content")
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("did change an object")
//        tableView.reloadData()
    }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                let remindersViewController = RemindersViewController()
                self.show(remindersViewController, sender: self)
            case 1:
                let followUpViewController = FollowUpViewController()
                self.show(followUpViewController, sender: self)
            case 2:
                let callGroupsViewController = CallGroupsViewController()
                self.show(callGroupsViewController, sender: self)
            case 3:
                let onlineUsersViewController = OnlineUsersViewController()
                self.show(onlineUsersViewController, sender: self)
            default: break
        }
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
