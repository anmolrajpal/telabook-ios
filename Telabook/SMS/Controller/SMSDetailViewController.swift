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
        
//        fetchRequest.predicate = NSPredicate(format: " = %@", workerId)
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
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
    }
    fileprivate func setupConstraints() {
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        tableView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
        
        return control
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
        ExternalConversationsAPI.shared.fetch(token: token, companyId: String(companyId), workerId: String(workerId), isArchived: false) { (data, serviceError, error) in
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
//            let abc = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "ExternalConversation", in: managedObjectContext)!, insertInto: managedObjectContext)
            
//            let item = abc.mutableSetValue(forKey: "parent")
//            item.addObjects(from: response)
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
    func showAlert(title:String, message:String) {
        let alertVC = UIAlertController.telaAlertController(title: title, message: message)
        alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    fileprivate func handleChatColorSequence(color:ConversationColor, indexPath:IndexPath) {
        FirebaseAuthService.shared.getCurrentToken { (token, error) in
            if let err = error {
                print("\n***Firebase Token Error***\n")
                print(err)
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: err.localizedDescription)
                }
            } else if let token = token {
                self.changeChatColor(token:token, color:color, indexPath: indexPath)
            }
        }
    }
    fileprivate func changeChatColor(token:String, color:ConversationColor, indexPath:IndexPath) {
        let companyId = UserDefaults.standard.getCompanyId()
        if let conversation = self.fetchedhResultController.object(at: indexPath) as? ExternalConversation {
            let conversationId = conversation.externalConversationId
            ExternalConversationsAPI.shared.setColor(token: token, companyId: String(companyId), conversationId: String(conversationId), colorCode: String(ConversationColor.getColorCodeBy(color: color))) { (responseStatus, data, serviceError, error) in
                if let err = error {
                    print("***Error Setting Color****\n\(err.localizedDescription)")
                    self.showAlert(title: "Error", message: err.localizedDescription)
                } else if let serviceErr = serviceError {
                    print("***Error Setting Color****\n\(serviceErr.localizedDescription)")
                    self.showAlert(title: "Error", message: serviceErr.localizedDescription)
                } else if let status = responseStatus {
                    guard status == .Created else {
                        print("***Error Setting Color****\nInvalid Response: \(status)")
                        self.showAlert(title: "\(status)", message: "Unable to change color. Please try again")
                        return
                    }
                    DispatchQueue.main.async {
                        self.updateTableContent()
                    }
                    if let data = data {
                        print("Data length => \(data.count)")
                        print("Data => \(data)")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                print("***Error Setting Color****\nCompany Id not found")
                self.showAlert(title: "Error", message: "Company ID not found. Unable to change color. Please try again")
            }
        }
        
    }
    fileprivate func promptChatColor(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Set Chat Color", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let defaultAction = UIAlertAction(title: "Default", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Default, indexPath: indexPath)
        })
        
        let yellowAction = UIAlertAction(title: "Yellow", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Yellow, indexPath: indexPath)
        })
        let greenAction = UIAlertAction(title: "Green", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Green, indexPath: indexPath)
        })
        let blueAction = UIAlertAction(title: "Blue", style: UIAlertAction.Style.default, handler: { (action) in
            self.handleChatColorSequence(color: .Blue, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(defaultAction)
        alert.addAction(yellowAction)
        alert.addAction(greenAction)
        alert.addAction(blueAction)
        alert.addAction(cancelAction)
    alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.telaGray6
        
        alert.view.tintColor = UIColor.telaBlue
        alert.view.subviews.first?.subviews.first?.backgroundColor = .clear
        alert.view.subviews.first?.backgroundColor = .clear
        self.present(alert, animated: true, completion: nil)
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
    
        
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let archiveAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Archive") { (action, view, completion) in
            completion(true)
        }
        archiveAction.image = #imageLiteral(resourceName: "archive")
        archiveAction.backgroundColor = .telaBlue
        let colorAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Chat Color") { (action, view, completion) in
            DispatchQueue.main.async {
                self.promptChatColor(indexPath: indexPath)
                completion(true)
            }
        }
        colorAction.image = #imageLiteral(resourceName: "edit")
        colorAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [archiveAction, colorAction])
        return configuration
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let blockAction =  UIContextualAction(style: .normal, title: "Block", handler: { (action,view,completionHandler ) in
            //do stuff
            completionHandler(true)
        })
        blockAction.image = #imageLiteral(resourceName: "unblock")
        blockAction.backgroundColor = .red
        
        let detailsAction =  UIContextualAction(style: .normal, title: "Details", handler: { (action,view,completionHandler ) in
            //do stuff
            completionHandler(true)
        })
        detailsAction.image = #imageLiteral(resourceName: "radio_active")
        detailsAction.backgroundColor = .orange
        
        let archiveAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Archive") { (action, view, completion) in
            completion(true)
        }
        archiveAction.image = #imageLiteral(resourceName: "archive")
        archiveAction.backgroundColor = .telaGray7
        let configuration = UISwipeActionsConfiguration(actions: [blockAction, detailsAction])
        
        return configuration
    }
}
extension SMSDetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .top)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .bottom)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
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
