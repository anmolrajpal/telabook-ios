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
//        updateTableContent()
        
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
    func upsertConvos(fetchedConvos:[InternalConversation], savedFilteredConvos:[InternalConversation], context:NSManagedObjectContext) {
        
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
            for fetchedConvo in fetchedConvos {
                convosToUpdate.forEach({$0.workerId == fetchedConvo.workerId ? $0.update(conversation: fetchedConvo, context: context) : print("Unmatched worker ID => \($0.workerId)")})
            }
            let newConvos = fetchedConvos.filter({!savedFilteredConvos.contains($0)})
            guard !newConvos.isEmpty else {
                print("No Convos to insert")
                return
            }
            print("New Convos available to insert")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: true)]
            fetchRequest.includesPendingChanges = false
            var res = try context.fetch(fetchRequest) as? [InternalConversation]
            res?.append(contentsOf: newConvos)
            try context.save()
        } catch let error {
            print("Error Updating Core Data Internal Conversations")
            print(error.localizedDescription)
        }
    }
    func deleteConvos(_ savedConvos:[InternalConversation], _ savedFilteredConvos:[InternalConversation], _ context:NSManagedObjectContext) {
        
        let convosToDelete = savedConvos.filter({!savedFilteredConvos.contains($0)})
//        print(cons)
        guard !convosToDelete.isEmpty else {
            print("No Convos to delete")
            return
        }
        let workerIds = convosToDelete.map { $0.workerId }.compactMap { $0 }
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: InternalConversation.self))
        matchingRequest.predicate = NSPredicate(format: "workerId in %@", argumentArray: [workerIds])
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch let error {
            print("Error deleting: \(error.localizedDescription)")
        }
    }
    func syncConversations(fetchedConvos:[InternalConversation], context:NSManagedObjectContext) {
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
                        self.deleteConvos(savedConvos, savedFilteredConvos, context)
                        self.upsertConvos(fetchedConvos: fetchedConvos, savedFilteredConvos: savedFilteredConvos, context: context)
                    }
                   
                } catch let error {
                    print("Bingo Error")
                    print(error.localizedDescription)
                }
            }
        }
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
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        if let convos = fetchSavedInternalConvos(context: context) {
            self.externalConversations = [ExternalConversation]()
            for convo in convos {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "internal.workerId = %d", convo.workerId)
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
//            let check = fetchSavedInternalConvos(context: managedObjectContext)
//            print("check saved internal count => \(String(describing: check?.count))")
            let decoder = JSONDecoder()
            decoder.userInfo[context] = managedObjectContext
            _ = try decoder.decode([InternalConversation].self, from: data)
//            let check1 = fetchSavedInternalConvos(context: managedObjectContext)
//            print("check saved internal count => \(String(describing: check1?.count))")
//            self.syncConversations(fetchedConvos: response, context: managedObjectContext)
            try managedObjectContext.save()
            loadExternalConvos(context: managedObjectContext)
//            print(response.first?.personName ?? "nil")
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
