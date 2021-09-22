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
   typealias ItemType = String
   typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>
   
   class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {  
      override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         snapshot().sectionIdentifiers[section].title
      }
   }
   
   internal func configureTableView() {
      tableView.register(ContactDetailsTextFieldCell.self)
      tableView.register(ContactDetailsAddressCell.self)
      tableView.register(ContactDetailsCreateAddressCell.self)
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.delegate = self
   }
   
   internal func configureDataSource() {
      dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
         guard let self = self else { return nil }
         let contact = self.contact
         let tableViewCell: UITableViewCell
         switch indexPath.section {
         case 0:
            let cell = tableView.dequeueReusableCell(ContactDetailsTextFieldCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configureCell(with: contact.contactName, placeholder: Section.contactName.title)
            tableViewCell = cell
         case 1:
            let cell = tableView.dequeueReusableCell(ContactDetailsTextFieldCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configureCell(with: contact.contactGlobalName, placeholder: Section.globalContactName.title)
            tableViewCell = cell
         case 2:
            let cell = tableView.dequeueReusableCell(ContactDetailsTextFieldCell.self, for: indexPath)
            cell.selectionStyle = .none
            let phoneNumber = contact.contactPhoneNumber ?? ""
            let number = phoneNumber.getE164FormattedNumber(shouldPrefixCountryCode: false) ?? phoneNumber
            cell.configureCell(with: number, placeholder: "(123) 456-7890")
            cell.textField.delegate = self
            cell.textField.keyboardType = UIKeyboardType.numberPad
            cell.textField.isEnabled = self.isCreatingNewContact
            tableViewCell = cell
         case 3:
            if indexPath.row != contact.address!.count {
               let cell = tableView.dequeueReusableCell(ContactDetailsAddressCell.self, for: indexPath)
               cell.selectionStyle = .none
               cell.configureCell(with: contact.address![indexPath.row])
               tableViewCell = cell
            } else {
               let cell = tableView.dequeueReusableCell(ContactDetailsCreateAddressCell.self, for: indexPath)
               cell.selectionStyle = .none
               cell.delegate = self
               tableViewCell = cell
            }
         default: fatalError()
         }
         return tableViewCell
      })
      dataSource.defaultRowAnimation = .none
   }
   
   func updateUI(animating:Bool = false, reloadingData:Bool = false) {
      guard let snapshot = currentSnapshot(), dataSource != nil else { return }
      dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
         guard let self = self else { return }
         if reloadingData && self.viewDidAppear { self.tableView.reloadData() }
      })
   }
   
   func currentSnapshot() -> Snapshot? {
      var snapshot = Snapshot()
      snapshot.appendSections([.contactName, .globalContactName, .contactPhoneNumber, .addresses])
      snapshot.appendItems(["0"], toSection: .contactName)
      snapshot.appendItems(["1"], toSection: .globalContactName)
      snapshot.appendItems(["2"], toSection: .contactPhoneNumber)
      _ = contact.address!.map({
         snapshot.appendItems(["\($0.addressName ?? UUID().uuidString)"], toSection: .addresses)
      })
      snapshot.appendItems(["Create new address"], toSection: .addresses)
      return snapshot
   }
}
// MARK: - UITableViewDelegate Methods
extension ContactDetailsViewController {
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return indexPath.section != 3 ? ContactDetailsTextFieldCell.cellHeight : ContactDetailsAddressCell.cellHeight
   }
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let count = contact.address!.count
      if indexPath.section == 3 {
         if indexPath.row != count {
            let vc = ContactAddressViewController()
            vc.delegate = self
            var array = [AddressBookProperties.Address]()
            for index in 0..<count {
               if index != indexPath.row {
                  array.append(contact.address![index])
               }
            }
            vc.addressToUpdateIndex = indexPath.row
            vc.existingAddresses = array
            vc.address = contact.address![indexPath.row]
            let controller = UINavigationController(rootViewController: vc)
            present(controller, animated: true)
         }
      }
   }
}

extension ContactDetailsViewController: ContactDetailsCreateAddressCellDelegate {
   func createNewAddressDidTap() {
      let vc = ContactAddressViewController()
      vc.existingAddresses = contact.address ?? []
      vc.delegate = self
      let controller = UINavigationController(rootViewController: vc)
      present(controller, animated: true)
   }
}
extension ContactDetailsViewController: ContactAddressDelegate {
   func addressDidUpsert(address: AddressBookProperties.Address, controller: ContactAddressViewController) {
      if address.defaultAddress == true {
         for index in 0..<contact.address!.count {
            contact.address![index].defaultAddress = false
         }
      }
      controller.dismiss(animated: true) { [self] in
         if let index = controller.addressToUpdateIndex {
            contact.address![index] = address
         } else {
            contact.address!.append(address)
         }
      }
   }
}

extension ContactDetailsViewController: UITextFieldDelegate {
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      guard let text = textField.text else { return false }
      let newString = (text as NSString).replacingCharacters(in: range, with: string)
      textField.text = newString.replacingOccurrences(of: "+1", with: "").extractNumbers.formatNumber()
      return false
   }
}
