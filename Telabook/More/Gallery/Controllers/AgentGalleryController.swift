//
//  AgentGalleryController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 21/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import Firebase
import CoreData

protocol AgentGalleryImagePickerDelegate {
    func agentGalleryController(controller: AgentGalleryController, didPickImage image:UIImage, forGalleryItem item:AgentGalleryItem, at indexPath:IndexPath)
    func agentGalleryController(controller: AgentGalleryController, didFinishCancelled cancelled:Bool)
}
class AgentGalleryController:UIViewController {
    
    
    
    // MARK: - Properties
    var delegate:AgentGalleryImagePickerDelegate?
    let operations = PendingOperations()
    var uploadTask:StorageUploadTask!
    var dataSource:DataSource!
    let agent:Agent
    let viewContext:NSManagedObjectContext
    var fetchedResultsController:NSFetchedResultsController<AgentGalleryItem>! = nil
    
    
    
    //MARK: - init
    init(agent:Agent) {
        self.agent = agent
        self.viewContext = PersistentContainer.shared.viewContext
        super.init(nibName: nil, bundle: nil)
        configureFetchedResultsController()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    // MARK: - Computed Properties
    var galleryItems:[AgentGalleryItem] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    var validGalleryItems:[AgentGalleryItem] {
        return galleryItems.filter({ $0.uuid != nil && $0.getImage() != nil })
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
    
    
    lazy var progressAlert:UIAlertController = {
        let alert = UIAlertController.telaAlertController(title: "Uploading...")
        return alert
    }()
    lazy var progressTitleLabel:UILabel = {
        let label = UILabel()
        let margin:CGFloat = 8.0
        let alertWidth:CGFloat = 270.0
        let frame = CGRect(x: margin, y: 50.0, width: alertWidth - margin * 2.0 , height: 20)
        label.frame = frame
        label.textAlignment = .center
        label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 13)
        label.text = "0 %"
        label.textColor = UIColor.white
        return label
    }()
    lazy var progressBar:UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        let margin:CGFloat = 8.0
        let alertWidth:CGFloat = 270.0
        let frame = CGRect(x: margin, y: 80.0, width: alertWidth - margin * 2.0 , height: 2.0)
        view.frame = frame
        view.progressTintColor = UIColor.telaBlue
        view.setProgress(0, animated: false)
        return view
    }()
    lazy var progressAlertSpinner:CircularSpinner = {
        let spinner = CircularSpinner()
        spinner.layer.lineWidth = 2
        return spinner
    }()
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else {
            // Nothing to do. The caller didn't change the editing flag value.
            return
        }
        
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing
        clearSelectedItems(animated: true)
        updateNavigationBarLeftButton()
        updateNavigationBarAddButton()
        updateToolBar()
    }
    
  

    
    
    
    // MARK: - Methods
    
    /// Fetched Results Controller
    private func configureFetchedResultsController() {
        if fetchedResultsController == nil {
            let fetchRequest:NSFetchRequest = AgentGalleryItem.fetchRequest()
            let agentPredicate = NSPredicate(format: "\(#keyPath(AgentGalleryItem.agent)) == %@", self.agent)
            fetchRequest.predicate = agentPredicate
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AgentGalleryItem.date, ascending: false)]
            
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


extension AgentGalleryController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        updateUI()
    }
}





