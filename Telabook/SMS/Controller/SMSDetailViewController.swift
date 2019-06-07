//
//  SMSDetailViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/06/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
class SMSDetailViewController: UIViewController {
    var workerId = Int()
    var internalConversation:InternalConversation? {
        didSet {
            if let conversation = internalConversation {
                self.navigationItem.title = "\(conversation.personName?.capitalized ?? "")"
            }
        }
    }
    var archivedConversations:[ExternalConversation]? {
        didSet {
            
        }
    }
    lazy var externalConversationsFRC: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: true)]
        fetchRequest.includesPendingChanges = false
       
        let workerIdPredicate = NSPredicate(format: "internal.workerId = %d", self.internalConversation!.workerId)
        let archiveCheckPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value:false))
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workerIdPredicate, archiveCheckPredicate])
        fetchRequest.predicate = andPredicate
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceService.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        print(frc)
        frc.delegate = self
        return frc
    }()
    
    lazy var archivedConversationsFRC: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: true)]
        let workerIdPredicate = NSPredicate(format: "internal.workerId = %d", self.internalConversation!.workerId)
        let archiveCheckPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value:true))
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workerIdPredicate, archiveCheckPredicate])
        fetchRequest.predicate = andPredicate
//        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.NSAndPredicateType, subpredicates: []
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceService.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        print("Archived FRC => \(frc)")
        frc.delegate = self
        return frc
    }()
//    lazy var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = {
//        return self.externalConversationsFRC
//    }()
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    
    
    
    func fetchSavedExternalConvos(isArchive:Bool?) -> [ExternalConversation]? {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        
        if let isArchive = isArchive {
            fetchRequest.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: isArchive))
        }
        fetchRequest.predicate = NSPredicate(format: "internal.workerId = %d", self.internalConversation!.workerId)
        do {
            return try managedObjectContext.fetch(fetchRequest) as? [ExternalConversation]
        } catch let error {
            print("Error=> \(error.localizedDescription)")
            return nil
        }
    }
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
        setupTableView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        
        fetchedResultsController = externalConversationsFRC
        self.preFetchData(isArchived: false)
        self.fetchDataFromAPI(isArchive: false)
//        segmentedControl.selectedSegmentIndex = 0
//        updateTableContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        updateTableContent()
        let abc = self.fetchSavedExternalConvos(isArchive: nil)
        //        print(abc as Any)
        if let a = abc {
            print("MARK: View Did Load")
            a.forEach({
                print("Internal Address Book Name => \($0.internalAddressBookName as Any)")
                print("isArchived => \($0.isArchived as Any)")
            })
        }
        let abcd = self.fetchSavedExternalConvos(isArchive: false)
        //        print(abc as Any)
        if let b = abcd {
            print("MARK: View Did Load")
            b.forEach({
                print("Internal Address Book Name => \($0.internalAddressBookName as Any)")
                print("isArchived => \($0.isArchived as Any)")
            })
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(spinner)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        view.addSubview(tryAgainButton)
    }
    fileprivate func setupConstraints() {
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        tableView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20).isActive = true
        tryAgainButton.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 20).isActive = true
        tryAgainButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    fileprivate func setupTableView() {
        tableView.register(SMSDetailCell.self, forCellReuseIdentifier: NSStringFromClass(SMSDetailCell.self))
        tableView.delegate = self
        tableView.dataSource = self
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
//        self.fetchUserData()
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.tryAgainButton.isHidden = isHidden
    }
    fileprivate func setViewsState(isHidden: Bool) {
        self.tableView.isHidden = isHidden
    }
    
    lazy var spinner:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
        //        indicator.backgroundColor = .black
        return indicator
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
    let segmentedControl:UISegmentedControl = {
        let options = ["Inbox", "Direct Message", "Archived"]
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaBlue
            ]
        let unselectedAttributes = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.telaGray7
        ]
        let control = UISegmentedControl(items: options)
        control.selectedSegmentIndex = 0
        control.tintColor = .clear
        control.setTitleTextAttributes(attributes, for: UIControl.State.selected)
        control.setTitleTextAttributes(unselectedAttributes, for: UIControl.State.normal)
        control.backgroundColor = .telaGray3
        control.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        return control
    }()
    @objc fileprivate func segmentDidChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: print("Segment 0")
//            self.startSpinner()
            self.fetchedResultsController = self.externalConversationsFRC
            self.preFetchData(isArchived: false)
            self.fetchDataFromAPI(isArchive: false)
        case 2: print("Segment 2")
//            startSpinner()
            self.fetchedResultsController = self.archivedConversationsFRC
            self.preFetchData(isArchived: true)
            self.fetchDataFromAPI(isArchive: true)
        default: break
        }
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
    }
    fileprivate func updateTableContent() {
//        self.preFetchData()
        self.fetchDataFromAPI(isArchive: false)
    }
    fileprivate func preFetchData(isArchived:Bool) {
        do {
            try self.fetchedResultsController?.performFetch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedResultsController?.sections?.first?.numberOfObjects))")
//            if !isArchived {
//                try self.fetchedResultController.performFetch()
//                print("COUNT FETCHED FIRST: \(String(describing: self.fetchedResultController.sections?.first?.numberOfObjects))")
//            } else {
//                try self.archivedFetchedResultController.performFetch()
//            }
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    
    fileprivate func fetchDataFromAPI(isArchive:Bool) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
//                    self.stopSpinner()
//                    self.setViewsState(isHidden: true)
//                    self.setPlaceholdersViewsState(isHidden: false)
                }
            } else if let token = token {
                self.fetchExternalConversations(token: token, isArchived: isArchive)
            }
        }
    }
    fileprivate func fetchArchivedConversations(token:String) {
        let companyId = UserDefaults.standard.getCompanyId()
        
        print("Worker ID => \(String(self.workerId))")
        ExternalConversationsAPI.shared.fetch(token: token, companyId: String(companyId), workerId: String(workerId), isArchived: true) { (responseStatus, data, serviceError, error) in
            if let err = error {
                DispatchQueue.main.async {
                    self.stopSpinner()
                    print("***Error Fetching Conversations****\n\(err.localizedDescription)")
                    self.showAlert(title: "Error", message: err.localizedDescription)
                }
            } else if let serviceErr = serviceError {
                DispatchQueue.main.async {
                    self.stopSpinner()
                    print("***Error Fetching Conversations****\n\(serviceErr.localizedDescription)")
                    self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                }
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            print("***No Archived Content****\nResponse Status => \(status)")
//                            self.setViewsState(isHidden: true)
//                            self.setPlaceholdersViewsState(isHidden: false)
                            self.placeholderLabel.text = "No Archived Conversations"
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.stopSpinner()
                            print("***Invalid Response****\nResponse Status => \(status)")
                            self.showAlert(title: "Error", message: "Unable to fetch conversations. Please try again.")
                        }
                    }
                    return
                }
                if let data = data {
                    print("Archived Conversations => \n\(data)")
                    DispatchQueue.main.async {
                        self.handleArchived(data: data)
                    }
//                    self.clearData()
//                    self.saveToCoreData(data: data)
                }
            }
        }
    }
    fileprivate func handleArchived(data:Data) {
        guard let context = CodingUserInfoKey.context else {
            fatalError("Failed to retrieve managed object context")
        }
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let decoder = JSONDecoder()
        decoder.userInfo[context] = managedObjectContext
        do {
            let response = try decoder.decode([ExternalConversation].self, from: data)
            print("Archived Messages : \n")
            print(response)
            response.forEach({
                $0.internal = self.internalConversation
                $0.isArchived = true
            })
//            self.archivedConversations = response
            try managedObjectContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
//        self.rowsToDisplay = self.archivedConversations
        DispatchQueue.main.async {
            self.stopSpinner()
        }
    }
    fileprivate func fetchExternalConversations(token:String, isArchived:Bool) {
        let companyId = UserDefaults.standard.getCompanyId()
        
        print("Worker ID => \(String(self.workerId))")
        ExternalConversationsAPI.shared.fetch(token: token, companyId: String(companyId), workerId: String(workerId), isArchived: isArchived) { (responseStatus, data, serviceError, error) in
            if let err = error {
                print("***Error Fetching Conversations****\n\(err.localizedDescription)")
                self.showAlert(title: "Error", message: err.localizedDescription)
            } else if let serviceErr = serviceError {
                print("***Error Fetching Conversations****\n\(serviceErr.localizedDescription)")
                self.showAlert(title: "Error", message: serviceErr.localizedDescription)
            } else if let status = responseStatus {
                guard status == .OK else {
                    if status == .NoContent {
                        DispatchQueue.main.async {
//                            self.stopSpinner()
                            print("***No Content****\nResponse Status => \(status)")
//                            self.setViewsState(isHidden: true)
//                            self.setPlaceholdersViewsState(isHidden: false)
                            self.placeholderLabel.text = "No Archived Conversations"
                        }
                    } else {
                        print("***Invalid Response****\nResponse Status => \(status)")
                        self.showAlert(title: "Error", message: "Unable to fetch conversations. Please try again.")
                    }
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.clearConversationData()
                        self.saveToCoreData(data: data, isArchived: isArchived)
                    }
                }
            }
        }
    }
    fileprivate func saveToCoreData(data: Data, isArchived:Bool) {
        guard let context = CodingUserInfoKey.context else {
            fatalError("Failed to retrieve managed object context")
        }
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let decoder = JSONDecoder()
        decoder.userInfo[context] = managedObjectContext
        do {
            let response = try decoder.decode([ExternalConversation].self, from: data)
            if !isArchived {
                response.forEach({$0.internal = self.internalConversation})
                try managedObjectContext.save()
            } else {
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
//                fetchRequest.predicate = NSPredicate(format: "isArchived = %d", false)
//                fetchRequest.predicate = NSPredicate(format: "internal.workerId = %d", self.internalConversation!.workerId)
                response.forEach({
                    $0.internal = self.internalConversation
                    $0.isArchived = true
                })
                var convos = self.fetchSavedExternalConvos(isArchive: nil)
                print("buggy")
                print(convos as Any)
                convos?.append(contentsOf: response)
                
                try managedObjectContext.save()
                
            }
        } catch let error {
            print("Error Processing Response Data: \(error)")
            DispatchQueue.main.async {
                
            }
        }
    }
    
    
    
    func clearConversationData() {
        do {
            
            let context = PersistenceService.shared.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
            fetchRequest.predicate = NSPredicate(format: "internal.workerId = %d", (internalConversation?.workerId)!)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                PersistenceService.shared.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    func clearStorage() {
        let isInMemoryStore = PersistenceService.shared.persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }
        
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            print("External Convos In Memory Store")
            do {
                let items = try managedObjectContext.fetch(fetchRequest)
                for item in items {
                    managedObjectContext.delete(item as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            print("External Convos Not In Memory Store")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
                PersistenceService.shared.saveContext()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    func showAlert(title:String, message:String) {
        let alertVC = UIAlertController.telaAlertController(title: title, message: message)
        alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
}
