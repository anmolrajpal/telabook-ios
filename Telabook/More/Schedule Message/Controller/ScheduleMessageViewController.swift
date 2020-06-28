//
//  ScheduleMessageViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

class ScheduleMessageViewController: UIViewController {
//    internal var scheduledMessages:[ScheduleMessagesCodable.ScheduleMessage]? {
//        didSet {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//            print("Damn")
//            if let messages = scheduledMessages {
//                print("Hola")
//                if messages.isEmpty {
//                    print("Cola")
//                    self.placeholderLabel.isHidden = false
//                    self.placeholderLabel.text = "No Scheduled Messages"
//                    self.tableView.isHidden = true
//                } else {
//                    self.placeholderLabel.isHidden = true
//                    self.tableView.isHidden = false
//                }
//            } else {
//                self.placeholderLabel.isHidden = false
//                self.placeholderLabel.text = "No Scheduled Messages"
//                self.tableView.isHidden = true
//            }
//        }
//    }
  
    
    
    // MARK: - Properties
    
    var dataSource:DataSource!
    let viewContext = PersistentContainer.shared.viewContext
    var fetchedResultsController:NSFetchedResultsController<ScheduledMessage>! = nil
    
    
    
    
    
    
    // MARK: - Computed Properties
    
    var scheduledMessages:[ScheduledMessage] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
   
    
    
    
    
    
    
    
    // MARK: - Methods
    
    /// Fetched Results Controller
    internal func configureFetchedResultsController() {
        if fetchedResultsController == nil {
            let fetchRequest:NSFetchRequest = ScheduledMessage.fetchRequest()
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ScheduledMessage.createdAt, ascending: false)]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: String(describing: self))
            fetchedResultsController.delegate = self
        }
        performFetch()
    }
    internal func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
        }
    }
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var spinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .large)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.white
        aiView.clipsToBounds = true
        aiView.translatesAutoresizingMaskIntoConstraints = false
        return aiView
    }()
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.bounces = true
        tv.alwaysBounceVertical = true
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 174
        tv.tableFooterView = UIView(frame: .zero)
        return tv
    }()
}



extension ScheduleMessageViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        updateUI()
    }
}
