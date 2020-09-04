//
//  AgentCalls+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 28/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AgentCallsViewController {
    
    // MARK: - Common setup
    
    internal func commonInit() {
        title = "CALLS"
        view.backgroundColor = .telaGray1
        configureNavigationBarAppearance()
        configureNavigationBarItems()
        configureHierarchy()
        configureTableView()
        configureDataSource()
        configureTargetActions()
        synchronizeAgentCalls()
    }
    
    
    
    
    
    // MARK: - Setup Views
    private func configureHierarchy() {
        view.addSubview(spinner)
        view.addSubview(placeholderLabel)
        layoutConstraints()
    }
    
    
    // MARK: - Layout Methods for views
    private func layoutConstraints() {
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).activate()
        
        placeholderLabel.widthAnchor.constraint(equalToConstant: view.frame.size.width - 40).activate()
        placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).activate()
    }
    
    
    private func configureNavigationBarItems() {
        let cancelButtonImage = SFSymbol.cancel.image(withSymbolConfiguration: .init(textStyle: .largeTitle)).image(scaledTo: .init(width: 28, height: 28))
        let cancelButton = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: self, action: #selector(cancelButtonDidTap))
        cancelButton.tintColor = UIColor.white.withAlphaComponent(0.2)
        //        if messageForwardingDelegate != nil {
        //            navigationItem.rightBarButtonItems = [cancelButton]
        //        }
    }
    @objc
    private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    
    /// Manages the UI state based on the fetched results available
    internal func handleState() {
        if sections.isEmpty {
            DispatchQueue.main.async {
                self.placeholderLabel.text = self.isFetching ? "Loading..." : "No Results"
                self.placeholderLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.placeholderLabel.isHidden = true
            }
        }
    }
    internal func stopLoaders() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    private func configureTargetActions() {
        tableViewRefreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    @objc private func refreshData(_ sender: Any) {
        fetchAgentCalls(limit: String(limit), offset: "0")
    }
    
    
    internal func synchronizeAgentCalls() {
        if !sections.isEmpty {
            initiateFetchAgentCallsSequence(withRefreshMode: .refreshControl)
        } else {
            initiateFetchAgentCallsSequence(withRefreshMode: .spinner)
        }
    }
    
    internal func initiateFetchAgentCallsSequence(withRefreshMode refreshMode: RefreshMode) {
        switch refreshMode {
        case .spinner:
            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            fetchAgentCalls(limit: String(limit), offset: "0")
        case .refreshControl:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.tableView.refreshControl?.beginExplicitRefreshing()
            }
        case .none:
            fetchAgentCalls(limit: String(limit), offset: "0")
        }
    }
}
