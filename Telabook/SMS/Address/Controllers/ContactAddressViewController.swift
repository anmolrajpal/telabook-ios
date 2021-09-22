//
//  ContactAddressViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit
import GooglePlaces
protocol ContactAddressDelegate: AnyObject {
   func addressDidUpsert(address: AddressBookProperties.Address, controller: ContactAddressViewController)
}

class ContactAddressViewController: UITableViewController {
   
   // MARK: - Declarations / Properties
   var address = AddressBookProperties.Address()
   var existingAddresses:[AddressBookProperties.Address]!
   var dataSource:DataSource! = nil
//   var isCreatingNewAddress:Bool!
   var addressToUpdateIndex:Int?
   var viewDidAppear = false
   var gmsPlace: GMSPlace? {
      didSet {
         if let place = gmsPlace {
            address.mainAddress = place.mainAddress
            updateUI(animating: false)
         }
      }
   }
   weak var delegate: ContactAddressDelegate?

   // MARK: - initializers
   init() {
      super.init(style: .insetGrouped)
   }
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   deinit {
      print("\(self): Deinitialized")
   }
   
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
extension GMSPlace {
   var mainAddress: AddressBookProperties.Address.MainAddress {
      .init(gmsPlace: self)
   }
}
