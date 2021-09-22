//
//  AddressBook+Helpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

extension AddressBookViewController {
   
   // MARK: Common init ~ to be called in viewDidLoad()
   internal func commonInit() {
      title = "Contacts"
      view.backgroundColor = .telaGray1
      configureNavigationBarAppearance()
      configureNavigationBarItems()
      configureHierarchy()
      configureTableView()
      configureDataSource()
      configureFetchedResultsController()
      configureTargetActions()
      configureSearchController()
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
      let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.done, target: self, action: #selector(addButtonDidTap))
      navigationItem.leftBarButtonItems = [cancelButton]
      navigationItem.rightBarButtonItems = [addButton]
   }
   @objc
   private func cancelButtonDidTap() {
      self.dismiss(animated: true)
   }
   @objc
   private func addButtonDidTap() {
      let vc = ContactDetailsViewController()
      vc.agentMOC = agent
      vc.isCreatingNewContact = true
      navigationController?.pushViewController(vc, animated: true)
      viewDidAppear = false
   }
   
   /// Manages the UI state based on the fetched results available
   internal func handleState() {
      if contacts.isEmpty {
         DispatchQueue.main.async {
            self.placeholderLabel.text = "No Results"
            self.placeholderLabel.isHidden = false
         }
      } else {
         DispatchQueue.main.async {
            self.placeholderLabel.isHidden = true
         }
      }
   }
   internal func stopRefreshers() {
      DispatchQueue.main.async {
         self.spinner.stopAnimating()
         self.tableView.refreshControl?.endRefreshing()
      }
   }
   private func configureTargetActions() {
      tableViewRefreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
   }
   @objc private func refreshData(_ sender: Any) {
      fetchContacts()
   }
   
   
   internal func synchronizeContacts() {
      if !contacts.isEmpty {
         if let firstObject = contacts.randomElement(),
            let lastRefreshedAt = firstObject.locallyRefreshedAt {
            let thresholdRefreshTime = lastRefreshedAt.addingTimeInterval(180)
            Date() > thresholdRefreshTime ?
               initiateFetchContactsSequence(withRefreshMode: .refreshControl) :
               initiateFetchContactsSequence(withRefreshMode: .none)
         }
      } else {
         initiateFetchContactsSequence(withRefreshMode: .spinner)
      }
   }
   
   internal func initiateFetchContactsSequence(withRefreshMode refreshMode: RefreshMode) {
      isDownloading = true
      placeholderLabel.text = "Loading..."
      switch refreshMode {
      case .spinner:
         DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.fetchContacts()
         }
      case .refreshControl:
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.tableView.refreshControl?.beginExplicitRefreshing()
         }
      case .none:
         self.fetchContacts()
      }
   }
}
