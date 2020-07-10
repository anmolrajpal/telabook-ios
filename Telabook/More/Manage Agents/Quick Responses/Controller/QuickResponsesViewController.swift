//
//  QuickResponsesViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData
protocol QuickResponsesModificationDelegate {
    func didExitQuickResponsesSettings()
}
class QuickResponsesViewController: UIViewController {
    var delegate:QuickResponsesModificationDelegate?
    
    
    
    // MARK: - Constructors
    
    lazy private(set) var subview: QuickResponsesView = {
        return QuickResponsesView(frame: UIScreen.main.bounds)
    }()
  
    
    var fetchedResultsController: NSFetchedResultsController<QuickResponse>! = nil
    
    
    var dataSource: DataSource! = nil
    
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    var quickResponses:[QuickResponse] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    
    
    
    
    
    // MARK: - Init
    
    let userID:Int
    let agent:Agent
    
    init(userID:Int, agent:Agent) {
        self.userID = userID
        self.agent = agent
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didExitQuickResponsesSettings()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
