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
    
    // MARK: - Properties
    
    var dataSource:DataSource!
    let viewContext = PersistentContainer.shared.viewContext
    var fetchedResultsController:NSFetchedResultsController<ScheduledMessage>! = nil
    
    
    
    
    
    
    // MARK: - Computed Properties
    
    var scheduledMessages:[ScheduledMessage] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    
    
    
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchScheduledMessages()
    }
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
            fetchedResultsController.delegate = dataSource
        }
//        performFetch()
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
        tv.separatorColor = .telaGray6
        tv.tableFooterView = UIView(frame: .zero)
        return tv
    }()
}




