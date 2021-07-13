//
//  ContactDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UITableViewController {
 
   // MARK: - Stored Properties / Declarations
   let contact: AddressBookContact
   var dataSource:DataSource! = nil
   
   // MARK: - Init / Deinit
   
   init(contact: AddressBookContact) {
      self.contact = contact
      super.init(style: .insetGrouped)
   }
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   deinit {
      print("\(self): Deinitialized")
   }
}
