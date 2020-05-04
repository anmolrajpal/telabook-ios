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
    var diffableDataSource: UITableViewDiffableDataSource<Section, QuickResponse>?
    var snapshot: NSDiffableDataSourceSnapshot<Section, QuickResponse>!
    
    internal var isFetchedResultsAvailable:Bool {
        return fetchedResultsController.sections?.first?.numberOfObjects == 0 ? false : true
    }
    
    
    let userId:String
    let agent:Agent
    
    init(userId:String, agent:Agent) {
        self.userId = userId
        self.agent = agent
        super.init(nibName: nil, bundle: nil)
        self.initiateFetchQuickResponsesSequence(userId: userId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        view = subview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        hideKeyboardWhenTappedAround()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

/*
 extension QuickResponsesViewController: UITableViewDataSource {
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return self.quickResponses?.count ?? 0
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
 cell.selectionStyle = .none
 cell.backgroundColor = .clear
 cell.textLabel?.text = self.quickResponses?[indexPath.row].answer
 cell.textLabel?.textColor = UIColor.telaGray7
 cell.textLabel?.lineBreakMode = .byWordWrapping
 cell.textLabel?.numberOfLines = 0
 cell.textLabel?.font = UIFont(name: CustomFonts.gothamBook.rawValue, size: 16)
 return cell
 }
 
 
 }
 */
