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
        setupTableView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        self.preFetchData()
        updateTableContent()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "SMS"
//        updateTableContent()
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
    }
    fileprivate func setupConstraints() {
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
    fileprivate func updateTableContent() {
        
        self.fetchDataFromAPI()
    }
    fileprivate func preFetchData() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?.first?.numberOfObjects))")
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
//                    self.stopSpinner()
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
                print("Service Error: \(serviceErr.localizedDescription)")
            } else if let err = error {
                print("Error: \(err.localizedDescription)")
            } else if let responseData = data {
                DispatchQueue.main.async {
                    self.clearData()
                    self.saveToCoreData(data: responseData)
                }
            }
        }
    }
    func updateConvos(savedFilteredConvos:[InternalConversation], context:NSManagedObjectContext) {
        do {
            
            try context.save()
        } catch let error {
            print("Error Updating Core Data Internal Conversations")
            print(error.localizedDescription)
        }
    }
    func deleteConvos(_ savedConvos:[InternalConversation], _ savedFilteredConvos:[InternalConversation], _ context:NSManagedObjectContext) {
        for i in savedConvos {
            for j in savedFilteredConvos {
                if i.workerId == j.workerId {
                    print("Match found = \(i.workerId)")
                } else {
                    _ = context.delete(i)
                }
            }
        }
        PersistenceService.shared.saveContext()
    }
    func syncConversations(fetchedConvos:[InternalConversation], context:NSManagedObjectContext) {
        context.performAndWait {
            let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
            let workerIds = fetchedConvos.map { $0.workerId }.compactMap { $0 }
            matchingRequest.predicate = NSPredicate(format: "workerId in %@", argumentArray: [workerIds])
            if let savedConvos = self.fetchSavedInternalConvos() {
                do {
                    if let savedFilteredConvos = try context.fetch(matchingRequest) as? [InternalConversation] {
                        self.deleteConvos(savedConvos, savedFilteredConvos, context)
                    }
                   
                } catch let error {
                    print("Bingo Error")
                    print(error.localizedDescription)
                }
            }
        }
    }
    func fetchSavedInternalConvos() -> [InternalConversation]? {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
        do {
            return try managedObjectContext.fetch(fetchRequest) as? [InternalConversation]
        } catch let error {
            print("Error=> \(error.localizedDescription)")
            return nil
        }
    }
    func loadExternalConvos() {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        if let convos = fetchSavedInternalConvos() {
            self.externalConversations = [ExternalConversation]()
            for convo in convos {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "internal.personName = %@", convo.personName!)
                fetchRequest.fetchLimit = 1
                do {
                let fetchedConvos = try managedObjectContext.fetch(fetchRequest) as? [ExternalConversation]
                    print(fetchedConvos as Any)
                self.externalConversations?.append(contentsOf: fetchedConvos!)
                    print("readhed here: count")
                    print(self.externalConversations?.count ?? -1)
                    print(self.externalConversations as Any)
                } catch let error {
                    print("Error=> \(error.localizedDescription)")
                }
            }
        }
    }
    fileprivate func saveToCoreData(data: Data) {
        do {
            guard let context = CodingUserInfoKey.context else {
                fatalError("Failed to retrieve managed object context")
            }
            let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[context] = managedObjectContext
            let response = try decoder.decode([InternalConversation].self, from: data)
//            self.syncConversations(fetchedConvos: response, context: managedObjectContext)
            try managedObjectContext.save()
            loadExternalConvos()
            print(response.first?.personName ?? "nil")
            DispatchQueue.main.async {
//                completion(response, nil, nil)
            }
        } catch let error {
            print("Error Processing Response Data: \(error)")
            DispatchQueue.main.async {
//                completion(nil, .Internal, error)
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
