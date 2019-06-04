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
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageDatetime", ascending: true)]
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
        updateTableContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        updateTableContent()
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
        tableView.register(SMSDetailCell.self, forCellReuseIdentifier: NSStringFromClass(SMSDetailCell.self))
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
        self.preFetchData()
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
                self.fetchExternalConversations(token: token)
            }
        }
    }
    fileprivate func fetchExternalConversations(token:String) {
        let companyId = UserDefaults.standard.getCompanyId()
        print("Worker ID => \(String(self.workerId))")
        ExternalConversationsAPI.shared.fetch(token: token, companyId: String(companyId), workerId: String(workerId)) { (data, serviceError, error) in
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
    fileprivate func saveToCoreData(data: Data) {
        do {
            guard let context = CodingUserInfoKey.context else {
                fatalError("Failed to retrieve managed object context")
            }
            let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[context] = managedObjectContext
            let response = try decoder.decode([ExternalConversation].self, from: data)
            try managedObjectContext.save()
            print(response.first?.workerPerson ?? "nil")
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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ExternalConversation.self))
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
}
extension SMSDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SMSDetailCell.self), for: indexPath) as! SMSDetailCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
//        cell.accessoryType = .disclosureIndicator
        if let conversation = fetchedhResultController.object(at: indexPath) as? ExternalConversation {
            cell.externalConversation = conversation
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SMSDetailCell.cellHeight
    }
    
}
extension SMSDetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .top)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .bottom)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
