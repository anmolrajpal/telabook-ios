//
//  ContactDetails+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 13/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit

extension ContactDetailsViewController {
   enum Section {
      case contactName, globalContactName, contactPhoneNumber, addresses
      
      var title:String {
         switch self {
         case .contactName: return "Contact Name"
         case .globalContactName: return "Contact Nickname"
         case .contactPhoneNumber: return "Contact Phone Number"
         case .addresses: return "Addresses"
         }
      }
   }
   
   typealias SectionType = Section
   typealias ItemType = AddressBookContact
   typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>
   
   class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {  
      override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         snapshot().sectionIdentifiers[section].title
      }
   }
   
   internal func configureTableView() {
      tableView.register(UITableViewCell.self)
      tableView.delegate = self
   }
   
   internal func configureDataSource() {
      dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, contact) -> UITableViewCell? in
         guard self != nil else { return nil }
         let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
         cell.backgroundColor = .clear
         
         return cell
      })
      dataSource.defaultRowAnimation = .none
   }
}
