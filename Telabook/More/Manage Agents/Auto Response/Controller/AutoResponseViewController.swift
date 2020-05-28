//
//  AutoResponseViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 10/07/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

class AutoResponseViewController: UIViewController {
    // MARK: Constructors
    lazy private(set) var subview: AutoResponseView = {
        return AutoResponseView(frame: UIScreen.main.bounds)
    }()
    
    internal var fetchRequest: NSFetchRequest<AutoResponse>!
    internal var fetchedResultsController: NSFetchedResultsController<AutoResponse>!
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.fetchedObjects?.isEmpty == true ? false : true
    }
    
    
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
    
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupFetchedResultsController()
        setupTargetActions()
        fetchWithTimeLogic()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    internal func updateSnapshot() {
        guard let autoResponse = self.fetchedResultsController.fetchedObjects?.first else {
            #if DEBUG
            print("Prefetched Auto Response Snapshot not available in Core Data")
            #endif
            return
        }
        subview.autoReplyTextView.text = autoResponse.smsReply
    }
    
}
