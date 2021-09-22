//
//  ContactDetailsViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit
import GooglePlaces

//extension MainAddressEntity {
//   func getGMSPlaceObject(from mainAddress: MainAddressEntity) -> GMSPlace {
//
//   }
//}
class ContactDetailsViewController: UITableViewController {
 
   // MARK: - Stored Properties / Declarations
   
   var contact = AddressBookProperties(address: []) {
      didSet {
         updateUI()
      }
   }
   var dataSource:DataSource! = nil
   var viewDidAppear = false
   var agentMOC:Agent!
   var isCreatingNewContact = false
//   var addressBookContact:AddressBookContact!
   
   // MARK: - Init / Deinit
   
   init() {
//      self.contact = contact
      super.init(style: .insetGrouped)
   }
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   deinit {
      print("\(self): Deinitialized")
   }
   
   // MARK: - Computed Properties
   
//   var addresses = [AddressBookProperties.Address]() {
//      didSet {
//         updateUI()
//      }
//   }


   // MARK: - Lifecycle
   
   override func viewDidLoad() {
      super.viewDidLoad()
      commonInit()
   }
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      viewDidAppear = true
   }
   override var isModalInPresentation: Bool {
       get {
           return true
       }
       set {
           super.isModalInPresentation = newValue
       }
   }
}
private extension String {
   var firstLetter: Self {
      self.uppercased().prefix(1).string
   }
}
private extension Optional where Wrapped == String {
   var firstLetter: String {
      self?.uppercased().prefix(1).string ?? ""
   }
}
