//
//  SMSViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 27/05/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData
class SMSViewController: UIViewController {
    internal var filteredSearch:[InternalConversation] = []
    internal var searchController = UISearchController(searchResultsController: nil)
    internal var isSearching = false
    var externalConversations:[ExternalConversation]?
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "userId", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceService.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupTableView()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "SMS"
        self.preFetchData()
        self.updateTableContent()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    fileprivate func setupViews() {
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(placeholderLabel)
        view.addSubview(tryAgainButton)
    }
    fileprivate func setupConstraints() {
        placeholderLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive = true
        tryAgainButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        tryAgainButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    fileprivate func setupTableView() {
        tableView.register(SMSCell.self, forCellReuseIdentifier: NSStringFromClass(SMSCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
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
    
    lazy var spinner:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
        return indicator
    }()
    fileprivate func startOverlaySpinner() {
        OverlaySpinner.shared.spinner(mark: .Start)
    }
    fileprivate func stopOverlaySpinner() {
        OverlaySpinner.shared.spinner(mark: .Stop)
    }
    fileprivate func startSpinner() {
        self.spinner.startAnimating()
    }
    fileprivate func stopSpinner() {
        self.spinner.stopAnimating()
    }
    
    
    fileprivate func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search Agents"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        let attributes:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.telaRed,
            NSAttributedString.Key.font : UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
//            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    fileprivate func updateTableContent() {
        self.handlePreFetchViews()
        if let count = preFetchCount(),
            count == 0 {
            self.startSpinner()
        }
        self.fetchDataFromAPI()
    }
    func preFetchCount() -> Int? {
        return self.fetchedhResultController.sections?.first?.numberOfObjects
    }
    func handlePreFetchViews() {
        preFetchData()
        if let count = preFetchCount(),
            count == 0 {
            self.setViewsState(isHidden: true)
            self.setPlaceholdersViewsState(isHidden: false)
            self.placeholderLabel.text = "No Conversations"
        } else {
            self.setViewsState(isHidden: false)
            self.setPlaceholdersViewsState(isHidden: true)
        }
    }
    
    @objc func handleTryAgainAction() {
        self.setPlaceholdersViewsState(isHidden: true)
        self.setViewsState(isHidden: true)
        self.startSpinner()
        self.fetchDataFromAPI()
    }
    fileprivate func setPlaceholdersViewsState(isHidden:Bool) {
        self.placeholderLabel.isHidden = isHidden
        self.tryAgainButton.isHidden = isHidden
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
    let tryAgainButton:UIButton = {
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
        button.addTarget(self, action: #selector(handleTryAgainAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    fileprivate func preFetchData() {
        do {
            try self.fetchedhResultController.performFetch()
//            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?.first?.numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    fileprivate func fetchDataFromAPI() {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.stopSpinner()
//                    self.setViewsState(isHidden: true)
//                    self.setPlaceholdersViewsState(isHidden: false)
                }
            } else if let token = token {
                self.fetchInternalConversations(token: token)
            }
        }
    }
    fileprivate func fetchInternalConversations(token:String) {
        let companyId = UserDefaults.standard.getCompanyId()
        InternalConversationsAPI.shared.fetch(token: token, companyId: String(companyId)) { (data, serviceError, error) in
            if let serviceErr = serviceError {
                self.stopSpinner()
                print("Service Error: \(serviceErr.localizedDescription)")
            } else if let err = error {
                self.stopSpinner()
                print("Error: \(err.localizedDescription)")
            } else if let responseData = data {
                DispatchQueue.main.async {
//                    self.clearData()
                    self.saveToCoreData(data: responseData)
                }
            }
        }
    }
    fileprivate func saveToCoreData(data: Data) {
        do {
            //            guard let context = CodingUserInfoKey.context else {
            //                fatalError("Failed to retrieve managed object context")
            //            }
            let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
            //            let check = fetchSavedInternalConvos(context: managedObjectContext)
            //            print("check saved internal count => \(String(describing: check?.count))")
            let decoder = JSONDecoder()
            //            decoder.userInfo[context] = managedObjectContext
            let response = try decoder.decode([InternalConversationsCodable].self, from: data)
            //            let check1 = fetchSavedInternalConvos(context: managedObjectContext)
            //            print("check saved internal count => \(String(describing: check1?.count))")
            
            //            print(response.first?.personName ?? "nil")
            print(response)
            DispatchQueue.main.async {
                self.syncConversations(fetchedConvos: response, context: managedObjectContext)
                //                try managedObjectContext.save()
                self.loadExternalConvos(context: managedObjectContext)
                //                completion(response, nil, nil)
            }
        } catch let error {
            
            print("Error Processing Response Data: \(error)")
            DispatchQueue.main.async {
                self.stopSpinner()
                //                completion(nil, .Internal, error)
            }
        }
    }
    func syncConversations(fetchedConvos:[InternalConversationsCodable], context:NSManagedObjectContext) {
        context.performAndWait {
            let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
            let hmm = fetchSavedInternalConvos(context: context)
            print("Post post saved internal count => \(String(describing: hmm?.count))")
            let workerIds = fetchedConvos.map { $0.workerId }.compactMap { $0 }
            print("Internet fetched worker IDs => \(workerIds)")
            matchingRequest.predicate = NSPredicate(format: "workerId in %@", argumentArray: [workerIds])
            if let savedConvos = self.fetchSavedInternalConvos(context: context) {
                do {
                    print("Post post post saved internal count => \(savedConvos.count)")
                    if let savedFilteredConvos = try context.fetch(matchingRequest) as? [InternalConversation] {
                        print("Saved Filtered Count => \(savedFilteredConvos.count)")
                        self.stopSpinner()
                        self.deleteConvos(savedConvos, savedFilteredConvos, context)
                        self.updateConvos(fetchedConvos: fetchedConvos, savedFilteredConvos: savedFilteredConvos, context: context)
                        self.insertConvos(fetchedConvos: fetchedConvos, savedFilteredConvos: savedFilteredConvos, context: context)
                    }
                    
                } catch let error {
                    self.stopSpinner()
                    print("Bingo Error")
                    print(error.localizedDescription)
                }
            }
        }
    }
    func deleteConvos(_ savedConvos:[InternalConversation], _ savedFilteredConvos:[InternalConversation], _ context:NSManagedObjectContext) {
        let convosToDelete = savedConvos.filter({!savedFilteredConvos.contains($0)})
        print("Convos to delete: Count=> \(convosToDelete.count)")
        guard !convosToDelete.isEmpty else {
            print("No Convos to delete")
            return
        }
        let workerIds = convosToDelete.map { $0.workerId }.compactMap { $0 }
        print("Worker IDs to delete => \(workerIds)")
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
        matchingRequest.predicate = NSPredicate(format: "workerId in %@", argumentArray: [workerIds])
        //        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
        //        print(batchDeleteRequest)
        do {
            let objects  = try context.fetch(matchingRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
            //            PersistenceService.shared.saveContext()
            //            try context.execute(batchDeleteRequest)
            try context.save()
        } catch let error {
            print("Error deleting: \(error.localizedDescription)")
        }
        PersistenceService.shared.saveContext()
        handlePreFetchViews()
    }
    func updateConvos(fetchedConvos:[InternalConversationsCodable], savedFilteredConvos:[InternalConversation], context:NSManagedObjectContext) {
        
        let toUpateWorkerIds = savedFilteredConvos.map { $0.workerId }.compactMap { $0 }
        print("To update worker IDs => \(toUpateWorkerIds)")
        guard !toUpateWorkerIds.isEmpty else {
            print("No Convos to update")
            return
        }
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
        matchingRequest.predicate = NSPredicate(format: "workerId in %@", argumentArray: [toUpateWorkerIds])
        do {
            let convosToUpdate = try context.fetch(matchingRequest) as! [InternalConversation]
            convosToUpdate.forEach { (convo) in
                convo.update(conversation: convo, context: context, internalConversation: fetchedConvos.first(where: { (con) -> Bool in
                    con.workerId == Int(convo.workerId)
                })!)
            }
//            for fetchedConvo in fetchedConvos {
//                convosToUpdate.forEach({ Int($0.workerId) == fetchedConvo.workerId ? $0.update(conversation: $0, context: context, internalConversation: fetchedConvo) : print("Unmatched worker ID => \($0.workerId)")})
//            }
        } catch let error {
            print("Error Updating Core Data Internal Conversations")
            print(error.localizedDescription)
        }
    }
    func insertConvos(fetchedConvos:[InternalConversationsCodable], savedFilteredConvos:[InternalConversation], context:NSManagedObjectContext) {
        let newConvos = fetchedConvos.filter { (coco) -> Bool in
            !savedFilteredConvos.contains(where: { Int($0.workerId) == coco.workerId })
        }
        print("New Convos: Count => \(newConvos.count)")
        guard !newConvos.isEmpty else {
            print("No Convos to insert")
            return
        }
        print("New Convos available to insert. Count => \(newConvos.count)")
        
        newConvos.forEach { (newConvo) in
            let entity =  NSEntityDescription.entity(forEntityName: String(describing: InternalConversation.self), in:context)!
            let convoObject = NSManagedObject(entity: entity, insertInto: context)
            InternalConversation.insert(conversation: convoObject, context: context, internalConversation: newConvo)
        }
        
        PersistenceService.shared.saveContext()
        handlePreFetchViews()
    }
    
    
    func fetchSavedInternalConvos(context:NSManagedObjectContext) -> [InternalConversation]? {
//        let context = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
        do {
            return try context.fetch(fetchRequest) as? [InternalConversation]
        } catch let error {
            print("Error=> \(error.localizedDescription)")
            return nil
        }
    }
    func loadExternalConvos(context:NSManagedObjectContext) {
        if let convos = fetchSavedInternalConvos(context: context) {
            self.externalConversations = [ExternalConversation]()
            for convo in convos {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "internal.workerId = %d", convo.workerId)
                fetchRequest.fetchLimit = 1
                do {
                let fetchedConvos = try context.fetch(fetchRequest) as? [ExternalConversation]
                self.externalConversations?.append(contentsOf: fetchedConvos!)
                } catch let error {
                    print("Error=> \(error.localizedDescription)")
                }
            }
        }
    }
    
    func clearData() {
        do {
            
            let context = PersistenceService.shared.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                PersistenceService.shared.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
