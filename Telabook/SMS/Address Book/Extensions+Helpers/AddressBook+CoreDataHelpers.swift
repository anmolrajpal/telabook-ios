//
//  AddressBook+CoreDataHelpers.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension AddressBookViewController {
   
   internal func configureFetchedResultsController() {
      let fetchRequest:NSFetchRequest<AddressBookContact> = AddressBookContact.fetchRequest()
      let agentPredicate = NSPredicate(format: "\(#keyPath(AddressBookContact.agent)) == %@", agent)
      if !currentSearchText.isEmpty {
         let filterPredicate = NSPredicate(format: "\(#keyPath(AddressBookContact.contactName)) CONTAINS[c] %@", currentSearchText)
         fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [agentPredicate, filterPredicate])
      } else {
         fetchRequest.predicate = agentPredicate
      }
      fetchRequest.sortDescriptors = [
//         NSSortDescriptor(keyPath: \AddressBookContact.firstLetter, ascending: true),
         NSSortDescriptor(keyPath: \AddressBookContact.contactName, ascending: true)
      ]
      
      guard let context = agent.managedObjectContext else {
         fatalError("### \(#function) : Unable to retrieve managed object context from agent object:\n\(agent)")
      }
      
      fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
      fetchedResultsController.delegate = self
      
      performFetch()
   }
   internal func performFetch() {
      do {
         try fetchedResultsController.performFetch()
      } catch {
         printAndLog(message: error.localizedDescription, log: .coredata, logType: .error)
         fatalError(error.localizedDescription)
      }
   }
}
extension AddressBookViewController: NSFetchedResultsControllerDelegate {
   func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
      updateUI(animating: false, reloadingData: false)
   }
}

