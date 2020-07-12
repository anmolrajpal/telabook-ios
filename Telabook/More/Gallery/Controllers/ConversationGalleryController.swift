//
//  ConversationGalleryController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 22/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

protocol ConversationGalleryImagePickerDelegate {
    func conversationGalleryController(controller:ConversationGalleryController, didPickImage image:UIImage, forMessage message:UserMessage, at indexPath:IndexPath)
    func conversationGalleryController(controller:ConversationGalleryController, didFinishCancelled cancelled:Bool)
}

class ConversationGalleryController: UIViewController {
    
    
    
    
    // MARK: - Properties
    var delegate:ConversationGalleryImagePickerDelegate?
    var fetchedResultsController:NSFetchedResultsController<UserMessage>! = nil
    var dataSource:DataSource!
    let conversation:Customer
    let viewContext:NSManagedObjectContext
    
    
    
    // MARK: - Computed Properties
    var galleryItems:[UserMessage] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    var validGalleryItems:[UserMessage] {
        return galleryItems.filter({
            $0.imageLocalURL() != nil && $0.getImage() != nil
        })
    }
    
    
    
    
    
    // MARK: - init
    init(conversation:Customer) {
        self.conversation = conversation
        self.viewContext = PersistentContainer.shared.viewContext
        super.init(nibName: nil, bundle: nil)
        configureFetchedResultsController()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    // MARK: - Constructors
    
    /// Collection View
    lazy var collectionView:UICollectionView = {
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: createLayout())
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.allowsSelection = true
        view.allowsMultipleSelection = false
        return view
    }()
    
    /// Spinner
    lazy var spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor.white
        spinner.backgroundColor = UIColor.clear
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        return spinner
    }()
    
    /// Message label
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
        label.textColor = UIColor.telaGray6
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    
    
    
    // MARK: - Methods
    
    /// Fetched Results Controller
    private func configureFetchedResultsController() {
        if fetchedResultsController == nil {
            let fetchRequest:NSFetchRequest = UserMessage.fetchRequest()
            let conversationPredicate = NSPredicate(format: "\(#keyPath(UserMessage.conversation)) == %@", self.conversation)
            let mmsPredicate = NSPredicate(format: "\(#keyPath(UserMessage.type)) == %@", MessageCategory.multimedia.rawValue)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conversationPredicate, mmsPredicate])
            fetchRequest.predicate = predicate
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserMessage.date, ascending: false)]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
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
}


extension ConversationGalleryController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        updateUI()
    }
}
