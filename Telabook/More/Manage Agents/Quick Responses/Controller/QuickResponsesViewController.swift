//
//  QuickResponsesViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Natovi. All rights reserved.
//

import UIKit
import CoreData

class QuickResponsesViewController: UIViewController {
    // MARK: Constructors
    lazy private(set) var subview: QuickResponsesView = {
        return QuickResponsesView(frame: UIScreen.main.bounds)
    }()
    //    internal var quickResponses:[QuickResponsesCodable.Answer]? {
    //        didSet {
    //            DispatchQueue.main.async {
    //                self.tableView.reloadData()
    //            }
    //            if let responses = quickResponses {
    //                if responses.isEmpty {
    //                    self.placeholderLabel.isHidden = false
    //                    self.placeholderLabel.text = "No Quick Responses"
    //                    self.tableView.isHidden = true
    //                } else {
    //                    self.placeholderLabel.isHidden = true
    //                    self.tableView.isHidden = false
    //                }
    //            }
    //        }
    //    }
    
    internal var fetchRequest: NSFetchRequest<QuickResponse>!
    internal var fetchedResultsController: NSFetchedResultsController<QuickResponse>!
    
    internal enum Section { case main }
    var diffableDataSource: QuickResponseDataSource?
    var snapshot: NSDiffableDataSourceSnapshot<Section, QuickResponse>!
    
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    
    
    let userID:Int
    let agent:Agent
    
    init(userID:Int, agent:Agent) {
        self.userID = userID
        self.agent = agent
        super.init(nibName: nil, bundle: nil)
//        self.initiateFetchQuickResponsesSequence(userId: userId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupTableView()
        hideKeyboardWhenTappedAround()
        setupTargetActions()
        fetchWithTimeLogic()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
