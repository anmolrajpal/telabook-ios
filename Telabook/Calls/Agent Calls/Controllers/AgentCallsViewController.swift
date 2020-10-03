//
//  AgentCallsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

class AgentCallsViewController: UITableViewController {
    
    struct GroupedCall: Hashable {
//        let identifier: UUID
        var recentCall: AgentCallProperties {
            return calls[0]
        }
        var calls: [AgentCallProperties]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(recentCall)
        }
        static func == (lhs: GroupedCall, rhs: GroupedCall) -> Bool {
            return lhs.recentCall == rhs.recentCall
        }
    }
    
    // MARK: - Properties
//    var groupedCalls = [GroupedCall]()
//    var agentCalls = [AgentCallProperties]()
    var offset = 0
    var limit = 50
    var dataSource: DataSource! = nil
    var isFetching = false
    var shouldFetchMore = true
    var sections = [SectionType]()
    
    // MARK: - Init
    
    let workerID: Int
    var worker: Agent!
    
    init(workerID: Int) {
        self.workerID = workerID
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\(self): Deinitialized")
    }
    
    
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    
    
    
    
    
    
    
    // MARK: - View Constructors
    
    lazy var placeholderLabel:UILabel = {
        let label = UILabel()
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
    lazy var footerSpinner: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .medium)
        aiView.backgroundColor = .clear
        aiView.hidesWhenStopped = true
        aiView.color = UIColor.white
        aiView.clipsToBounds = true
        return aiView
    }()
    lazy var tableViewRefreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.telaGray7
        return refreshControl
    }()
    
}
