//
//  AddressBookViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

class AddressBookViewController: UITableViewController {
   
   // MARK: - Stored Properties / Declarations
   
   let agent: Agent
   let searchController = UISearchController(searchResultsController: nil)
   var dataSource:DataSource! = nil
   var fetchedResultsController: NSFetchedResultsController<AddressBookContact>! = nil
   var isDownloading = false
   var currentSearchText = ""
   var viewDidAppear = false
   let tableFooterView = ContactsFooterView()
   
   // MARK: - Init / Deinit
   
   init(agent: Agent) {
      self.agent = agent
      super.init(nibName: nil, bundle: nil)
   }
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   deinit {
      print("\(self): Deinitialized")
   }
   
   // MARK: - Computed Properties
   
   internal var contacts:[AddressBookContact] {
      return fetchedResultsController.fetchedObjects ?? []
   }
   var frcSections: [NSFetchedResultsSectionInfo] {
      fetchedResultsController.sections ?? []
   }
//   var sections: [Section] {
//      return frcSections.map {(
//         SectionType(contacts: $0.objects as? [AddressBookContact] ?? [])
//      )}
//   }

   var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
   }
   var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
   }
   
   // MARK: - Lifecycle
   override func loadView() {
      super.loadView()
      view.frame = UIScreen.main.bounds
   }
   override func viewDidLoad() {
      super.viewDidLoad()
      commonInit()
   }
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      viewDidAppear = true
      synchronizeContacts()
   }
   
   
   // MARK: - View Constructors
   
   lazy var placeholderLabel:UILabel = {
      let label = UILabel()
      label.text = "This is some sort of bullshit"
      label.font = UIFont(name: CustomFonts.gothamMedium.rawValue, size: 16)
      label.textColor = UIColor.telaGray6
      label.textAlignment = .center
      label.numberOfLines = 0
      label.sizeToFit()
      label.isHidden = true
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }()
   lazy var spinner: UIActivityIndicatorView = {
      let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
      aiView.backgroundColor = .clear
      aiView.hidesWhenStopped = true
      aiView.color = UIColor.white
      aiView.clipsToBounds = true
      aiView.translatesAutoresizingMaskIntoConstraints = false
      return aiView
   }()
   lazy var tableViewRefreshControl:UIRefreshControl = {
      let refreshControl = UIRefreshControl()
      refreshControl.tintColor = UIColor.telaGray7
      return refreshControl
   }()
}
