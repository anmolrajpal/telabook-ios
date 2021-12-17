//
//  ContactAddress+TableView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 19/07/21.
//  Copyright © 2021 Anmol Rajpal. All rights reserved.
//

import UIKit
import GooglePlaces

extension ContactAddressViewController {
   enum Section {
      case addressName, mainAddress, additionalAddress, defaultAddress
      
      var title:String {
         switch self {
         case .addressName: return "Address Name"
         case .mainAddress: return "Main Address"
         case .additionalAddress: return "Additional Address"
         case .defaultAddress: return ""
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
      tableView.register(TextFieldTableViewCell.self)
      tableView.register(UITableViewCell.self)
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.delegate = self
//      placesDataSource.delegate = self
//      resultsController.tableView.delegate = placesDataSource
//      resultsController.tableView.dataSource = placesDataSource
      
   }
   
   internal func configureDataSource() {
      dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
         guard let self = self else { return nil }
         let tableViewCell: UITableViewCell
         switch indexPath.section {
         case 0:
            let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.textField.addTarget(self, action: #selector(self.addressNameTextFieldDidChange(_:)), for: .editingChanged)
            cell.configureCell(with: self.address.addressName, placeholder: Section.addressName.title)
            cell.textField.isEnabled = true
            tableViewCell = cell
         case 1:
            let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configureCell(with: self.address.mainAddress?.formattedAddress, placeholder: Section.mainAddress.title)
            cell.textField.isEnabled = false
            tableViewCell = cell
         case 2:
            let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.textField.addTarget(self, action: #selector(self.secondaryAddressTextFieldDidChange(_:)), for: .editingChanged)
            cell.configureCell(with: self.address.secondAddress, placeholder: Section.additionalAddress.title)
            cell.textField.isEnabled = true
            tableViewCell = cell
         case 3:
            let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
            cell.textLabel?.text = "Default Address"
            cell.selectionStyle = .none
            let switchButton = UISwitch()
            switchButton.tintColor = UIColor.telaGray5
            switchButton.thumbTintColor = UIColor.white
            switchButton.onTintColor = UIColor.telaBlue
            switchButton.isOn = self.address.defaultAddress ?? false
            switchButton.addTarget(self, action: #selector(self.defaultAddressSwitchStateDidChange(_:)), for: .valueChanged)
            cell.accessoryView = switchButton
            tableViewCell = cell
         default: fatalError()
         }
         return tableViewCell
      })
      dataSource.defaultRowAnimation = .none
      updateUI(animating: false)
   }
   
   func updateUI(animating:Bool = true, reloadingData:Bool = false) {
      guard let snapshot = currentSnapshot(), dataSource != nil else { return }
      dataSource.apply(snapshot, animatingDifferences: animating, completion: { [weak self] in
         guard let self = self else { return }
         if reloadingData && self.viewDidAppear { self.tableView.reloadData() }
//         if !self.isDownloading {
//            self.handleState()
//            self.stopRefreshers()
//         }
      })
   }
   
   func currentSnapshot() -> Snapshot? {
      var snapshot = Snapshot()
      snapshot.appendSections([.addressName, .mainAddress, .additionalAddress, .defaultAddress])
      snapshot.appendItems(["0"], toSection: .addressName)
      snapshot.appendItems(["1"], toSection: .mainAddress)
      snapshot.appendItems(["2"], toSection: .additionalAddress)
      snapshot.appendItems(["4"], toSection: .defaultAddress)
      return snapshot
   }
   
   @objc
   internal func defaultAddressSwitchStateDidChange(_ sender:UISwitch) {
      address.defaultAddress = sender.isOn
   }
   @objc func addressNameTextFieldDidChange(_ sender: UIControl) {
     guard let textField = sender as? UITextField else { return }
      address.addressName = textField.text
   }
   @objc func secondaryAddressTextFieldDidChange(_ sender: UIControl) {
     guard let textField = sender as? UITextField else { return }
      address.secondAddress = textField.text
   }
   
}
// MARK: - UITableViewDelegate Methods
extension ContactAddressViewController {
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return TextFieldTableViewCell.cellHeight
   }
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if indexPath.section == 1 {
         let autocompleteViewController = GMSAutocompleteViewController()
         autocompleteViewController.delegate = self
         navigationController?.present(autocompleteViewController, animated: true)
      }
   }
//   override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//      section == 3 ? 9 : 0
//   }
}

extension ContactAddressViewController: GMSAutocompleteViewControllerDelegate {
   func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      navigationController?.dismiss(animated: true)
      gmsPlace = place
   }
   
   func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
      navigationController?.dismiss(animated: true)
      showAlert(withErrorMessage: error.localizedDescription)
   }
   
   func wasCancelled(_ viewController: GMSAutocompleteViewController) {
      navigationController?.dismiss(animated: true)
   }
}
